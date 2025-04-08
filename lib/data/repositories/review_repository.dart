import 'dart:developer' as dev;

import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/review/req_publish_review.dart';
import 'package:ezstore_flutter/data/services/review_service.dart';
import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';

class ReviewRepository {
  final ReviewService _reviewService;

  ReviewRepository(this._reviewService);

  Future<PaginatedResponse<ReviewResponse>?> getAllReviews({
    int page = 0,
    int pageSize = 10,
    String? keyword,
    int? rating,
    bool? published,
  }) async {
    try {
      final response = await _reviewService.getAllReviews(
        page: page,
        pageSize: pageSize,
        keyword: keyword,
        rating: rating,
        published: published,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh sách đánh giá: $e');
      rethrow;
    }
  }

  Future<ReviewResponse?> publishReview(
      ReqPublishReview reqPublishReview) async {
    try {
      final response = await _reviewService.publishReview(reqPublishReview);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi xuất bản đánh giá: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await _reviewService.deleteReview(reviewId);

      if (response.statusCode == 200) {
        return;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi xoá đánh giá: $e');
      rethrow;
    }
  }
}
