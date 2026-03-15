import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  UserRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    Uuid? uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _uuid = uuid ?? const Uuid();

  CollectionReference get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) return Left(const NotFoundFailure('User not found'));
      return Right(UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get user'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    File? avatar,
    String? language,
    bool? notificationsEnabled,
    String? businessName,
    String? businessDescription,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{
        if (fullName != null) 'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (language != null) 'language': language,
        if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
        if (businessName != null) 'businessName': businessName,
        if (businessDescription != null) 'businessDescription': businessDescription,
        if (location != null) 'location': location,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (avatar != null) {
        final imageId = _uuid.v4();
        final ref = _storage.ref().child(
              '${AppConstants.usersStoragePath}/$userId/avatar_$imageId.jpg',
            );
        await ref.putFile(avatar);
        updates['avatarUrl'] = await ref.getDownloadURL();
      }

      await _usersRef.doc(userId).update(updates);
      return getUserById(userId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitSellerVerification({
    required String userId,
    required List<File> documents,
    required String businessName,
    required String businessDescription,
  }) async {
    try {
      final docUrls = <String>[];
      for (final doc in documents) {
        final docId = _uuid.v4();
        final ref = _storage.ref().child(
              '${AppConstants.verificationsStoragePath}/$userId/$docId.pdf',
            );
        await ref.putFile(doc);
        docUrls.add(await ref.getDownloadURL());
      }

      final batch = _firestore.batch();
      batch.update(_usersRef.doc(userId), {
        'sellerVerificationStatus': VerificationStatus.pending.name,
        'businessName': businessName,
        'businessDescription': businessDescription,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(
        _firestore.collection(AppConstants.verificationsCollection).doc(userId),
        {
          'userId': userId,
          'businessName': businessName,
          'businessDescription': businessDescription,
          'documentUrls': docUrls,
          'status': VerificationStatus.pending.name,
          'submittedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to submit verification'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getPendingVerifications() async {
    try {
      final snapshot = await _usersRef
          .where('sellerVerificationStatus', isEqualTo: VerificationStatus.pending.name)
          .get();
      return Right(snapshot.docs
          .map((d) => UserModel.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get verifications'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateVerificationStatus({
    required String userId,
    required VerificationStatus status,
    String? reason,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_usersRef.doc(userId), {
        'sellerVerificationStatus': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(
        _firestore.collection(AppConstants.verificationsCollection).doc(userId),
        {
          'status': status.name,
          if (reason != null) 'rejectionReason': reason,
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );
      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update verification status'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserActive(String userId, bool isActive) async {
    try {
      await _usersRef.doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to toggle user status'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers({
    String? role,
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      Query query = _usersRef.orderBy('createdAt', descending: true);
      if (role != null) query = query.where('role', isEqualTo: role);
      if (lastDocumentId != null) {
        final lastDoc = await _usersRef.doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.limit(limit).get();
      return Right(snapshot.docs
          .map((d) => UserModel.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get users'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> watchUser(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    });
  }

  @override
  Future<Either<Failure, void>> toggleWishlist(String userId, String productId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      final wishlist = List<String>.from(
        (doc.data() as Map<String, dynamic>?)?['wishlist'] as List? ?? [],
      );
      if (wishlist.contains(productId)) {
        await _usersRef.doc(userId).update({
          'wishlist': FieldValue.arrayRemove([productId])
        });
      } else {
        await _usersRef.doc(userId).update({
          'wishlist': FieldValue.arrayUnion([productId])
        });
      }
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to toggle wishlist'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSellerStats(String sellerId) async {
    try {
      final products = await _firestore
          .collection(AppConstants.productsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .where('isActive', isEqualTo: true)
          .get();

      final orders = await _firestore
          .collection(AppConstants.ordersCollection)
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      double revenue = 0;
      int orderCount = 0;
      for (final orderDoc in orders.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final items = (orderData['items'] as List?) ?? [];
        for (final item in items) {
          if ((item as Map<String, dynamic>)['sellerId'] == sellerId) {
            revenue += ((item['price'] as num?)?.toDouble() ?? 0) *
                ((item['quantity'] as int?) ?? 0);
            orderCount++;
          }
        }
      }

      return Right({
        'totalProducts': products.docs.length,
        'totalOrders': orderCount,
        'totalRevenue': revenue,
      });
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get seller stats'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
