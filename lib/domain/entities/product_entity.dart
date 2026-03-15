import 'package:equatable/equatable.dart';

class ProductLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;

  const ProductLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
  });

  @override
  List<Object?> get props => [latitude, longitude, address, city];
}

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final List<String> thumbnailUrls;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;
  final bool isSellerVerified;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int stockCount;
  final ProductLocation? location;
  final bool isActive;
  final bool isFeatured;
  final int viewCount;
  final List<String> tags;
  final String? brand;
  final String? condition;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    this.thumbnailUrls = const [],
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    this.isSellerVerified = false,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.stockCount = 0,
    this.location,
    this.isActive = true,
    this.isFeatured = false,
    this.viewCount = 0,
    this.tags = const [],
    this.brand,
    this.condition,
  });

  bool get isInStock => stockCount > 0;
  bool get isLowStock => stockCount > 0 && stockCount <= 5;
  String get mainImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
  String get mainThumbnailUrl =>
      thumbnailUrls.isNotEmpty ? thumbnailUrls.first : mainImageUrl;

  ProductEntity copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    List<String>? imageUrls,
    List<String>? thumbnailUrls,
    String? sellerId,
    String? sellerName,
    String? sellerAvatarUrl,
    bool? isSellerVerified,
    double? averageRating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? stockCount,
    ProductLocation? location,
    bool? isActive,
    bool? isFeatured,
    int? viewCount,
    List<String>? tags,
    String? brand,
    String? condition,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrls: thumbnailUrls ?? this.thumbnailUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatarUrl: sellerAvatarUrl ?? this.sellerAvatarUrl,
      isSellerVerified: isSellerVerified ?? this.isSellerVerified,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stockCount: stockCount ?? this.stockCount,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      brand: brand ?? this.brand,
      condition: condition ?? this.condition,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, price, category, imageUrls,
        thumbnailUrls, sellerId, sellerName, averageRating,
        reviewCount, createdAt, stockCount, isActive,
      ];
}
