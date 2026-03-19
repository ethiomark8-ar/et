import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/review_repository.dart';
import '../../entities/review_entity.dart';

class SubmitReviewUseCase {
  final ReviewRepository _repository;
  const SubmitReviewUseCase(this._repository);

  Future<Either<Failure, ReviewEntity>> call({
    required String productId,
    required String orderId,
    required double rating,
    required String reviewText,
    List<File>? images,
  }) {
    return _repository.submitReview(
      productId: productId,
      orderId: orderId,
      rating: rating,
      reviewText: reviewText,
      images: images,
    );
  }
}

class GetProductReviewsUseCase {
  final ReviewRepository _repository;
  const GetProductReviewsUseCase(this._repository);

  Future<Either<Failure, List<ReviewEntity>>> call(
    String productId, {
    String? lastDocumentId,
    int limit = 20,
  }) {
    return _repository.getProductReviews(
      productId,
      lastDocumentId: lastDocumentId,
      limit: limit,
    );
  }
}

class CheckHasReviewedUseCase {
  final ReviewRepository _repository;
  const CheckHasReviewedUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderId, String productId) {
    return _repository.hasReviewed(orderId, productId);
  }
}

class MarkReviewHelpfulUseCase {
  final ReviewRepository _repository;
  const MarkReviewHelpfulUseCase(this._repository);

  Future<Either<Failure, void>> call(String reviewId, String userId) {
    return _repository.markHelpful(reviewId, userId);
  }
}
