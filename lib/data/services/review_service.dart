import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/review/req_publish_review.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';

class ReviewService {
  final ApiService _api;

  ReviewService(this._api);

  Future<ApiResponse<PaginatedResponse<ReviewResponse>>> getAllReviews({
    int page = 0,
    int pageSize = 10,
    String? keyword,
    int? rating,
    bool? published,
  }) async {
    String path =
        '${ApiConstants.reviews}?page=$page&size=$pageSize&order=createdAt,desc';

    List<String> filters = [];

    if (keyword != null && keyword.isNotEmpty) {
      filters.add("description~'*$keyword*'");
    }

    if (rating != null) {
      filters.add("rating:'$rating'");
    }

    if (published != null) {
      filters.add("published:'$published'");
    }

    if (filters.isNotEmpty) {
      path += "&filter=${filters.join(' and ')}";
    }

    return await _api.get(
      path: path,
      fromJson: (json) => PaginatedResponse<ReviewResponse>.fromJson(
        json,
        (reviewJson) => ReviewResponse.fromJson(reviewJson),
      ),
    );
  }

  Future<ApiResponse<ReviewResponse>> publishReview(
      ReqPublishReview reqPublishReview) async {
    String path = '${ApiConstants.reviews}/publish';
    return await _api.post(
        path: path,
        data: reqPublishReview.toJson(),
        fromJson: (json) => ReviewResponse.fromJson(json));
  }

  Future<ApiResponse<void>> deleteReview(int reviewId) async {
    String path = '${ApiConstants.reviews}/$reviewId';
    return await _api.delete(path: path, fromJson: (json) => null);
  }
}
