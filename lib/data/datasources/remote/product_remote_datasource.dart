import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../../domain/entities/product_entity.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
    bool descending = true,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });
  Future<ProductModel> getProductById(String productId);
  Future<List<ProductModel>> getProductsBySeller(String sellerId);
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10});
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required List<File> images,
    required int stockCount,
    String? brand,
    String? condition,
    List<String>? tags,
    ProductLocation? location,
  });
  Future<ProductModel> updateProduct({
    required String productId,
    Map<String, dynamic> updates,
    List<File>? newImages,
    List<String>? existingImageUrls,
  });
  Future<void> deleteProduct(String productId);
  Future<void> incrementViewCount(String productId);
  Future<bool> toggleWishlist(String productId, String userId);
  Future<List<ProductModel>> getWishlistProducts(String userId);
  Future<List<ProductModel>> searchProducts(String query, {int limit = 20});
  Stream<ProductModel> watchProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  ProductRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
    Uuid? uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth,
        _uuid = uuid ?? const Uuid();

  CollectionReference get _productsRef =>
      _firestore.collection(AppConstants.productsCollection);

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
    bool descending = true,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = _productsRef.where('isActive', isEqualTo: true);

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final orderField = sortBy ?? 'createdAt';
      query = query.orderBy(orderField, descending: descending);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get products', code: e.code);
    }
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    try {
      final doc = await _productsRef.doc(productId).get();
      if (!doc.exists) throw const NotFoundException(message: 'Product not found');
      return ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get product', code: e.code);
    }
  }

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _productsRef
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get seller products', code: e.code);
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      final snapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get featured products', code: e.code);
    }
  }

  @override
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required List<File> images,
    required int stockCount,
    String? brand,
    String? condition,
    List<String>? tags,
    ProductLocation? location,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw const AuthException(message: 'User not authenticated');

      // Get seller info
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final userModel = UserModel.fromFirestore(userDoc);

      // Upload images
      final imageUrls = <String>[];
      final thumbnailUrls = <String>[];

      for (final image in images) {
        final imageId = _uuid.v4();
        final imageRef = _storage.ref().child(
              '${AppConstants.productsStoragePath}/$userId/$imageId.jpg',
            );
        await imageRef.putFile(image);
        final url = await imageRef.getDownloadURL();
        imageUrls.add(url);
        thumbnailUrls.add(url); // In production, Cloud Functions generate thumbnails
      }

      final docRef = _productsRef.doc();
      final now = DateTime.now();

      final productModel = ProductModel(
        id: docRef.id,
        title: title,
        description: description,
        price: price,
        category: category,
        imageUrls: imageUrls,
        thumbnailUrls: thumbnailUrls,
        sellerId: userId,
        sellerName: userModel.fullName,
        sellerAvatarUrl: userModel.avatarUrl,
        isSellerVerified: userModel.isVerifiedSeller,
        stockCount: stockCount,
        brand: brand,
        condition: condition,
        tags: tags ?? [],
        location: location,
        createdAt: now,
      );

      await docRef.set(productModel.toMap());
      return productModel;
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create product', code: e.code);
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required String productId,
    Map<String, dynamic> updates = const {},
    List<File>? newImages,
    List<String>? existingImageUrls,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw const AuthException(message: 'User not authenticated');

      final allImageUrls = <String>[...?existingImageUrls];

      if (newImages != null && newImages.isNotEmpty) {
        for (final image in newImages) {
          final imageId = _uuid.v4();
          final imageRef = _storage.ref().child(
                '${AppConstants.productsStoragePath}/$userId/$imageId.jpg',
              );
          await imageRef.putFile(image);
          final url = await imageRef.getDownloadURL();
          allImageUrls.add(url);
        }
      }

      final finalUpdates = {
        ...updates,
        if (newImages != null || existingImageUrls != null) 'imageUrls': allImageUrls,
        if (newImages != null || existingImageUrls != null) 'thumbnailUrls': allImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _productsRef.doc(productId).update(finalUpdates);
      return getProductById(productId);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update product', code: e.code);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).update({'isActive': false});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete product', code: e.code);
    }
  }

  @override
  Future<void> incrementViewCount(String productId) async {
    try {
      await _productsRef.doc(productId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  @override
  Future<bool> toggleWishlist(String productId, String userId) async {
    try {
      final userRef = _firestore.collection(AppConstants.usersCollection).doc(userId);
      final userDoc = await userRef.get();
      final wishlist = List<String>.from(
        (userDoc.data() as Map<String, dynamic>?)?['wishlist'] as List? ?? [],
      );

      final isInWishlist = wishlist.contains(productId);
      if (isInWishlist) {
        await userRef.update({
          'wishlist': FieldValue.arrayRemove([productId])
        });
      } else {
        await userRef.update({
          'wishlist': FieldValue.arrayUnion([productId])
        });
      }
      return !isInWishlist;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update wishlist', code: e.code);
    }
  }

  @override
  Future<List<ProductModel>> getWishlistProducts(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final wishlist = List<String>.from(
        (userDoc.data() as Map<String, dynamic>?)?['wishlist'] as List? ?? [],
      );
      if (wishlist.isEmpty) return [];

      final products = <ProductModel>[];
      for (final productId in wishlist) {
        try {
          final product = await getProductById(productId);
          products.add(product);
        } catch (_) {}
      }
      return products;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get wishlist', code: e.code);
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query, {int limit = 20}) async {
    try {
      // Basic Firestore search - in production use Algolia/Typesense
      final snapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Search failed', code: e.code);
    }
  }

  @override
  Stream<ProductModel> watchProduct(String productId) {
    return _productsRef
        .doc(productId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>));
  }
}
