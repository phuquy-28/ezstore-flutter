import 'package:ezstore_flutter/data/models/order/req_update_order.dart';
import 'package:ezstore_flutter/data/repositories/order_repository.dart';
import 'package:ezstore_flutter/domain/models/order/order_detail_response.dart';
import 'package:flutter/foundation.dart';

class UpdateOrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  OrderDetailResponse? orderDetail;
  String? error;
  bool isLoading = false;

  // New status to apply to the order
  String? _newStatus;
  String? get newStatus => _newStatus;

  // Reason for cancellation or return
  String _reason = '';
  String get reason => _reason;

  UpdateOrderViewModel(this._orderRepository);

  Future<void> loadOrderDetail(int orderId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      orderDetail = await _orderRepository.getOrderDetail(orderId);
      // Initialize new status with current status
      _newStatus = orderDetail?.status;

      // Initialize reason if order is CANCELLED or RETURNED
      if (orderDetail?.status == 'CANCELLED' ||
          orderDetail?.status == 'RETURNED') {
        _reason = orderDetail?.cancelReason ?? '';
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  void updateStatus(String status) {
    _newStatus = status;
    notifyListeners();
  }

  void updateReason(String reason) {
    _reason = reason;
    // No need to notify listeners since this doesn't affect UI directly
  }

  Future<bool> saveChanges() async {
    try {
      if (orderDetail == null || _newStatus == null) {
        error = 'Không thể cập nhật trạng thái đơn hàng';
        notifyListeners();
        return false;
      }

      // Check if status actually changed
      if (_newStatus == orderDetail!.status &&
          (_newStatus != 'CANCELLED' && _newStatus != 'RETURNED' ||
              _reason.isEmpty)) {
        // No changes to save
        return true;
      }

      isLoading = true;
      notifyListeners();

      // Create update request
      final reqUpdateOrder = ReqUpdateOrder(
        orderId: orderDetail!.id!,
        status: _newStatus,
        reason: (_newStatus == 'CANCELLED' || _newStatus == 'RETURNED')
            ? _reason
            : null,
      );

      // Call repository to update the order
      final updatedOrder = await _orderRepository.updateOrder(reqUpdateOrder);

      if (updatedOrder != null) {
        // Update the local order detail with the response
        orderDetail = updatedOrder;

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Không nhận được phản hồi từ máy chủ');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
