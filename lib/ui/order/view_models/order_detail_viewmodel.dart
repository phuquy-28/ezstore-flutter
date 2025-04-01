import 'package:ezstore_flutter/data/repositories/order_repository.dart';
import 'package:ezstore_flutter/domain/models/order/order_detail_response.dart';
import 'package:flutter/foundation.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  OrderDetailResponse? orderDetail;
  String? error;
  bool isLoading = false;

  OrderDetailViewModel(this._orderRepository);

  Future<void> loadOrderDetail(int orderId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      orderDetail = await _orderRepository.getOrderDetail(orderId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
