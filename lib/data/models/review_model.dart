import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.orderId,
    required super.buyerId,
    required super.buyerName,
    super.buyerAvatarUrl,
    required super.rating,
    required super.reviewText,
    super.imageUrls,
    required super.createdAt,
    super.updatedAt,
    super.isVerifiedPurchase,
    super.helpfulCount,
    super.helpfulVoters,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap(data, doc.id);
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      productId: map['productId'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? 'Anonymous',
      buyerAvatarUrl: map['buyerAvatarUrl'] as String?,
      rating: _parseDouble(map['rating']),
      reviewText: map['reviewText'] as String? ?? '',
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseTimestamp(map['updatedAt']) : null,
      isVerifiedPurchase: map['isVerifiedPurchase'] as bool? ?? true,
      helpfulCount: map['helpfulCount'] as int? ?? 0,
      helpfulVoters: List<String>.from(map['helpfulVoters'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'orderId': orderId,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerAvatarUrl': buyerAvatarUrl,
        'rating': rating,
        'reviewText': reviewText,
        'imageUrls': imageUrls,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'isVerifiedPurchase': isVerifiedPurchase,
        'helpfulCount': helpfulCount,
        'helpfulVoters': helpfulVoters,
      };

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
