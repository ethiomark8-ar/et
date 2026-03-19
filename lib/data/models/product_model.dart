import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

class ProductLocationModel extends ProductLocation {
  const ProductLocationModel({
    required super.latitude,
    required super.longitude,
    super.address,
    super.city,
  });

  factory ProductLocationModel.fromMap(Map<String, dynamic> map) {
    return ProductLocationModel(
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      address: map['address'] as String?,
      city: map['city'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
      };

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.category,
    required super.imageUrls,
    super.thumbnailUrls,
    required super.sellerId,
    required super.sellerName,
    super.sellerAvatarUrl,
    super.isSellerVerified,
    super.averageRating,
    super.reviewCount,
    required super.createdAt,
    super.updatedAt,
    super.stockCount,
    super.location,
    super.isActive,
    super.isFeatured,
    super.viewCount,
    super.tags,
    super.brand,
    super.condition,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data, doc.id);
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: _parseDouble(map['price']),
      category: map['category'] as String? ?? 'Other',
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
      thumbnailUrls: List<String>.from(map['thumbnailUrls'] as List? ?? []),
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? 'Unknown Seller',
      sellerAvatarUrl: map['sellerAvatarUrl'] as String?,
      isSellerVerified: map['isSellerVerified'] as bool? ?? false,
      averageRating: _parseDouble(map['averageRating']),
      reviewCount: map['reviewCount'] as int? ?? 0,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseTimestamp(map['updatedAt']) : null,
      stockCount: map['stockCount'] as int? ?? 0,
      location: map['location'] != null
          ? ProductLocationModel.fromMap(map['location'] as Map<String, dynamic>)
          : null,
      isActive: map['isActive'] as bool? ?? true,
      isFeatured: map['isFeatured'] as bool? ?? false,
      viewCount: map['viewCount'] as int? ?? 0,
      tags: List<String>.from(map['tags'] as List? ?? []),
      brand: map['brand'] as String?,
      condition: map['condition'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'thumbnailUrls': thumbnailUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatarUrl': sellerAvatarUrl,
      'isSellerVerified': isSellerVerified,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'stockCount': stockCount,
      'location': location != null
          ? ProductLocationModel(
              latitude: location!.latitude,
              longitude: location!.longitude,
              address: location!.address,
              city: location!.city,
            ).toMap()
          : null,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'viewCount': viewCount,
      'tags': tags,
      'brand': brand,
      'condition': condition,
    };
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
