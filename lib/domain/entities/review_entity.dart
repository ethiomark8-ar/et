import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String orderId;
  final String buyerId;
  final String buyerName;
  final String? buyerAvatarUrl;
  final double rating;
  final String reviewText;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final List<String> helpfulVoters;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatarUrl,
    required this.rating,
    required this.reviewText,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.isVerifiedPurchase = true,
    this.helpfulCount = 0,
    this.helpfulVoters = const [],
  });

  @override
  List<Object?> get props => [id, productId, buyerId, rating, createdAt];
}
