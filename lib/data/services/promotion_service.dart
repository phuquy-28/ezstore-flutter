import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/promotion/req_promotion.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';

class PromotionService {
  final ApiService _api;

  PromotionService(this._api);

  Future<ApiResponse<PaginatedResponse<PromotionResponse>>> getAllPromotions({
    int page = 0,
    int pageSize = 10,
    String? keyword,
  }) async {
    String path = '${ApiConstants.promotions}?page=$page&size=$pageSize';

    if (keyword != null && keyword.isNotEmpty) {
      path += "&filter=name~'$keyword'";
    }

    return await _api.get(
      path: path,
      fromJson: (json) => PaginatedResponse<PromotionResponse>.fromJson(
        json,
        (promotionJson) => PromotionResponse.fromJson(promotionJson),
      ),
    );
  }

  Future<ApiResponse<PromotionResponse>> getPromotionById(
      int promotionId) async {
    String path = '${ApiConstants.promotions}/$promotionId';

    return await _api.get(
      path: path,
      fromJson: (json) => PromotionResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PromotionResponse>> createPromotion(
      ReqPromotion promotion) async {
    String path = '${ApiConstants.promotions}';
    return await _api.post(
      path: path,
      data: promotion.toJson(),
      fromJson: (json) => PromotionResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PromotionResponse>> updatePromotion(
      ReqPromotion promotion) async {
    String path = '${ApiConstants.promotions}';
    return await _api.put(
      path: path,
      data: promotion.toJson(),
      fromJson: (json) => PromotionResponse.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deletePromotion(int promotionId) async {
    String path = '${ApiConstants.promotions}/$promotionId';
    return await _api.delete(
      path: path,
      fromJson: (json) => null,
    );
  }
}
