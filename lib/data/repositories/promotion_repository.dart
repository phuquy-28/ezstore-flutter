import 'dart:developer' as dev show log;

import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/promotion/req_promotion.dart';
import 'package:ezstore_flutter/data/services/promotion_service.dart';
import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';

class PromotionRepository {
  final PromotionService _promotionService;

  PromotionRepository(this._promotionService);

  Future<PaginatedResponse<PromotionResponse>?> getAllPromotions(
      {int page = 0, int pageSize = 10, String? keyword}) async {
    try {
      final response = await _promotionService.getAllPromotions(
          page: page, pageSize: pageSize, keyword: keyword);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh sách khuyến mãi: $e');
      rethrow;
    }
  }

  Future<PromotionResponse?> getPromotionById(int promotionId) async {
    try {
      final response = await _promotionService.getPromotionById(promotionId);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy chi tiết khuyến mãi: $e');
      rethrow;
    }
  }

  Future<PromotionResponse?> createPromotion(ReqPromotion promotion) async {
    try {
      final response = await _promotionService.createPromotion(promotion);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi tạo khuyến mãi: $e');
      rethrow;
    }
  }

  Future<PromotionResponse?> updatePromotion(ReqPromotion promotion) async {
    try {
      final response = await _promotionService.updatePromotion(promotion);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi cập nhật khuyến mãi: $e');
      rethrow;
    }
  }

  Future<void> deletePromotion(int promotionId) async {
    try {
      final response = await _promotionService.deletePromotion(promotionId);

      if (response.statusCode == 200) {
        return;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi xóa khuyến mãi: $e');
      rethrow;
    }
  }
}
