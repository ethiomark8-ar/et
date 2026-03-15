import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  ReviewRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
    Uuid? uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth,
        _uuid = uuid ?? const Uuid();

  CollectionReference get _reviewsRef =>
      _firestore.collection(AppConstants.reviewsCollection);

  @override
  Future<Either<Failure, ReviewEntity>> submitReview({
    required String productId,
    required String orderId,
    required double rating,
    required String reviewText,
    List<File>? images,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return Left(const AuthFailure('Not authenticated'));

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};

      // Upload images if provided
      final imageUrls = <String>[];
      if (images != null) {
        for (final image in images) {
          final imageId = _uuid.v4();
          final ref = _storage.ref().child('reviews/$productId/$imageId.jpg');
          await ref.putFile(image);
          imageUrls.add(await ref.getDownloadURL());
        }
      }

      final docRef = _reviewsRef.doc();
      final now = DateTime.now();
      final review = ReviewModel(
        id: docRef.id,
        productId: productId,
        orderId: orderId,
        buyerId: userId,
        buyerName: userData['fullName'] as String? ?? 'Anonymous',
        buyerAvatarUrl: userData['avatarUrl'] as String?,
        rating: rating,
        reviewText: reviewText,
        imageUrls: imageUrls,
        createdAt: now,
        isVerifiedPurchase: true,
      );

      final batch = _firestore.batch();
      batch.set(docRef, review.toMap());

      // Update order hasBeenReviewed flag
      batch.update(
        _firestore.collection(AppConstants.ordersCollection).doc(orderId),
        {'hasBeenReviewed': true},
      );

      // Recalculate product average rating
      final existingReviews = await _reviewsRef
          .where('productId', isEqualTo: productId)
          .get();

      final allRatings = existingReviews.docs
          .map((d) => ((d.data() as Map<String, dynamic>)['rating'] as num?)?.toDouble() ?? 0.0)
          .toList()
        ..add(rating);

      final avgRating = allRatings.reduce((a, b) => a + b) / allRatings.length;

      batch.update(
        _firestore.collection(AppConstants.productsCollection).doc(productId),
        {
          'averageRating': avgRating,
          'reviewCount': FieldValue.increment(1),
        },
      );

      await batch.commit();
      return Right(review);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to submit review'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
    String productId, {
    String? lastDocumentId,
    int limit = 20,
  }) async {
    try {
      Query query = _reviewsRef
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _reviewsRef.doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return Right(snapshot.docs
          .map((d) => ReviewModel.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get reviews'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getBuyerReviews(String buyerId) async {
    try {
      final snapshot = await _reviewsRef
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();
      return Right(snapshot.docs
          .map((d) => ReviewModel.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get buyer reviews'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasReviewed(String orderId, String productId) async {
    try {
      final snapshot = await _reviewsRef
          .where('orderId', isEqualTo: orderId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();
      return Right(snapshot.docs.isNotEmpty);
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> markHelpful(String reviewId, String userId) async {
    try {
      await _reviewsRef.doc(reviewId).update({
        'helpfulVoters': FieldValue.arrayUnion([userId]),
        'helpfulCount': FieldValue.increment(1),
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to mark helpful'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<List<ReviewEntity>> watchProductReviews(String productId) {
    return _reviewsRef
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                ReviewModel.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRatingSummary(String productId) async {
    try {
      final snapshot = await _reviewsRef
          .where('productId', isEqualTo: productId)
          .get();
      final ratings = snapshot.docs
          .map((d) => ((d.data() as Map<String, dynamic>)['rating'] as num?)?.toDouble() ?? 0.0)
          .toList();

      if (ratings.isEmpty) {
        return Right({'average': 0.0, 'count': 0, 'distribution': {}});
      }

      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final r in ratings) {
        distribution[r.round()] = (distribution[r.round()] ?? 0) + 1;
      }

      return Right({'average': avg, 'count': ratings.length, 'distribution': distribution});
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get rating summary'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
