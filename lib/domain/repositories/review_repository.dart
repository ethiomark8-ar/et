import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/review_entity.dart';

abstract class ReviewRepository {
  /// Submit a review
  Future<Either<Failure, ReviewEntity>> submitReview({
    required String productId,
    required String orderId,
    required double rating,
    required String reviewText,
    List<File>? images,
  });

  /// Get reviews for a product
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
    String productId, {
    String? lastDocumentId,
    int limit = 20,
  });

  /// Get reviews by buyer
  Future<Either<Failure, List<ReviewEntity>>> getBuyerReviews(String buyerId);

  /// Check if buyer has reviewed an order
  Future<Either<Failure, bool>> hasReviewed(String orderId, String productId);

  /// Mark review as helpful
  Future<Either<Failure, void>> markHelpful(String reviewId, String userId);

  /// Stream product reviews
  Stream<List<ReviewEntity>> watchProductReviews(String productId);

  /// Get product rating summary
  Future<Either<Failure, Map<String, dynamic>>> getRatingSummary(String productId);
}
