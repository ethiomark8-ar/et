import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  const ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
    bool descending = true,
    String? lastDocumentId,
    int limit = 20,
  }) async {
    try {
      final products = await _remoteDataSource.getProducts(
        category: category,
        searchQuery: searchQuery,
        sortBy: sortBy,
        descending: descending,
        limit: limit,
      );
      return Right(products);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String productId) async {
    try {
      final product = await _remoteDataSource.getProductById(productId);
      return Right(product);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsBySeller(String sellerId) async {
    try {
      final products = await _remoteDataSource.getProductsBySeller(sellerId);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({int limit = 10}) async {
    try {
      final products = await _remoteDataSource.getFeaturedProducts(limit: limit);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final product = await _remoteDataSource.createProduct(
        title: title,
        description: description,
        price: price,
        category: category,
        images: images,
        stockCount: stockCount,
        brand: brand,
        condition: condition,
        tags: tags,
        location: location,
      );
      return Right(product);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final updates = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (category != null) 'category': category,
        if (stockCount != null) 'stockCount': stockCount,
        if (brand != null) 'brand': brand,
        if (condition != null) 'condition': condition,
        if (tags != null) 'tags': tags,
        if (isActive != null) 'isActive': isActive,
        if (location != null) 'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
          'city': location.city,
        },
      };
      final product = await _remoteDataSource.updateProduct(
        productId: productId,
        updates: updates,
        newImages: newImages,
        existingImageUrls: existingImageUrls,
      );
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await _remoteDataSource.deleteProduct(productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String productId) async {
    try {
      await _remoteDataSource.incrementViewCount(productId);
      return const Right(null);
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist(String productId, String userId) async {
    try {
      final result = await _remoteDataSource.toggleWishlist(productId, userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String productId, String userId) async {
    try {
      final products = await _remoteDataSource.getWishlistProducts(userId);
      return Right(products.any((p) => p.id == productId));
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlistProducts(String userId) async {
    try {
      final products = await _remoteDataSource.getWishlistProducts(userId);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<ProductEntity> watchProduct(String productId) {
    return _remoteDataSource.watchProduct(productId);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query, {
    int limit = 20,
  }) async {
    try {
      final products = await _remoteDataSource.searchProducts(query, limit: limit);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
