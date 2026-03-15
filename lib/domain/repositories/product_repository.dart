import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  /// Get paginated list of products
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
    bool descending = true,
    String? lastDocumentId,
    int limit = 20,
  });

  /// Get a single product by ID
  Future<Either<Failure, ProductEntity>> getProductById(String productId);

  /// Get products by seller
  Future<Either<Failure, List<ProductEntity>>> getProductsBySeller(String sellerId);

  /// Get featured products
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({int limit = 10});

  /// Create a new product
  Future<Either<Failure, ProductEntity>> createProduct({
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

  /// Update an existing product
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String productId,
    String? title,
    String? description,
    double? price,
    String? category,
    List<File>? newImages,
    List<String>? existingImageUrls,
    int? stockCount,
    String? brand,
    String? condition,
    List<String>? tags,
    bool? isActive,
    ProductLocation? location,
  });

  /// Delete a product
  Future<Either<Failure, void>> deleteProduct(String productId);

  /// Increment product view count
  Future<Either<Failure, void>> incrementViewCount(String productId);

  /// Toggle product wishlist
  Future<Either<Failure, bool>> toggleWishlist(String productId, String userId);

  /// Check if product is in wishlist
  Future<Either<Failure, bool>> isInWishlist(String productId, String userId);

  /// Get wishlist products
  Future<Either<Failure, List<ProductEntity>>> getWishlistProducts(String userId);

  /// Stream of product updates
  Stream<ProductEntity> watchProduct(String productId);

  /// Search products
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query, {int limit = 20});
}
