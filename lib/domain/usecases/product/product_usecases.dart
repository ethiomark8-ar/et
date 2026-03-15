import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/product_repository.dart';
import '../../entities/product_entity.dart';

class GetProductsUseCase {
  final ProductRepository _repository;
  const GetProductsUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    String? category,
    String? searchQuery,
    String? sortBy,
    bool descending = true,
    String? lastDocumentId,
    int limit = 20,
  }) {
    return _repository.getProducts(
      category: category,
      searchQuery: searchQuery,
      sortBy: sortBy,
      descending: descending,
      lastDocumentId: lastDocumentId,
      limit: limit,
    );
  }
}

class GetProductByIdUseCase {
  final ProductRepository _repository;
  const GetProductByIdUseCase(this._repository);

  Future<Either<Failure, ProductEntity>> call(String productId) {
    return _repository.getProductById(productId);
  }
}

class GetProductsBySellerUseCase {
  final ProductRepository _repository;
  const GetProductsBySellerUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call(String sellerId) {
    return _repository.getProductsBySeller(sellerId);
  }
}

class GetFeaturedProductsUseCase {
  final ProductRepository _repository;
  const GetFeaturedProductsUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call({int limit = 10}) {
    return _repository.getFeaturedProducts(limit: limit);
  }
}

class CreateProductUseCase {
  final ProductRepository _repository;
  const CreateProductUseCase(this._repository);

  Future<Either<Failure, ProductEntity>> call({
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
  }) {
    return _repository.createProduct(
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
  }
}

class UpdateProductUseCase {
  final ProductRepository _repository;
  const UpdateProductUseCase(this._repository);

  Future<Either<Failure, ProductEntity>> call({
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
  }) {
    return _repository.updateProduct(
      productId: productId,
      title: title,
      description: description,
      price: price,
      category: category,
      newImages: newImages,
      existingImageUrls: existingImageUrls,
      stockCount: stockCount,
      brand: brand,
      condition: condition,
      tags: tags,
      isActive: isActive,
      location: location,
    );
  }
}

class DeleteProductUseCase {
  final ProductRepository _repository;
  const DeleteProductUseCase(this._repository);

  Future<Either<Failure, void>> call(String productId) {
    return _repository.deleteProduct(productId);
  }
}

class SearchProductsUseCase {
  final ProductRepository _repository;
  const SearchProductsUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call(
    String query, {
    int limit = 20,
  }) {
    return _repository.searchProducts(query, limit: limit);
  }
}

class ToggleWishlistUseCase {
  final ProductRepository _repository;
  const ToggleWishlistUseCase(this._repository);

  Future<Either<Failure, bool>> call(String productId, String userId) {
    return _repository.toggleWishlist(productId, userId);
  }
}

class GetWishlistProductsUseCase {
  final ProductRepository _repository;
  const GetWishlistProductsUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call(String userId) {
    return _repository.getWishlistProducts(userId);
  }
}
