import 'package:ezstore_flutter/data/repositories/promotion_repository.dart';
import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class PromotionDetailViewModel extends ChangeNotifier {
  final PromotionRepository _promotionRepository;

  PromotionResponse? _promotion;
  bool _isLoading = false;
  String? _errorMessage;

  PromotionDetailViewModel(this._promotionRepository);

  PromotionResponse? get promotion => _promotion;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Kiểm tra xem khuyến mãi có đang hoạt động không
  bool isActive() {
    if (_promotion?.startDate == null || _promotion?.endDate == null)
      return false;

    final now = DateTime.now();
    final startDate = DateTime.parse(_promotion!.startDate!);
    final endDate = DateTime.parse(_promotion!.endDate!);

    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Lấy thông tin khuyến mãi theo ID
  Future<void> getPromotionById(int promotionId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _promotionRepository.getPromotionById(promotionId);
      _promotion = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      dev.log('Lỗi khi tải thông tin khuyến mãi: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Chuyển đến màn hình chỉnh sửa khuyến mãi
  Future<void> navigateToEditScreen(
      BuildContext context, int promotionId) async {
    final result = await Navigator.pushNamed(context, AppRoutes.editPromotion,
        arguments: {'id': promotionId});

    // Nếu cập nhật thành công, tải lại dữ liệu
    if (result == true) {
      await getPromotionById(promotionId);
    }
  }

  // Lấy định dạng trạng thái khuyến mãi
  String getStatusText() {
    if (isActive()) {
      return 'Đang hoạt động';
    } else {
      if (_promotion?.startDate != null && _promotion?.endDate != null) {
        final now = DateTime.now();
        final startDate = DateTime.parse(_promotion!.startDate!);
        final endDate = DateTime.parse(_promotion!.endDate!);

        if (now.isBefore(startDate)) {
          return 'Chưa bắt đầu';
        } else if (now.isAfter(endDate)) {
          return 'Đã kết thúc';
        }
      }
      return 'Không hoạt động';
    }
  }

  // Lấy màu trạng thái khuyến mãi
  Color getStatusColor() {
    if (isActive()) {
      return Colors.green;
    } else {
      if (_promotion?.startDate != null && _promotion?.endDate != null) {
        final now = DateTime.now();
        final startDate = DateTime.parse(_promotion!.startDate!);

        if (now.isBefore(startDate)) {
          return Colors.orange;
        }
      }
      return Colors.red;
    }
  }
}
