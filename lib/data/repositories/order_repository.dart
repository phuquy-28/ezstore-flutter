import 'package:ezstore_flutter/data/models/order/req_update_order.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/services/order_service.dart';
import 'package:ezstore_flutter/domain/models/order/order_detail_response.dart';
import 'package:ezstore_flutter/domain/models/order/order_response.dart';

import 'dart:developer' as dev;

class OrderRepository {
  final OrderService _orderService;

  OrderRepository(this._orderService);

  Future<PaginatedResponse<OrderResponse>?> getAllOrders({
    int page = 0,
    int pageSize = 10,
    String? keyword,
    String? paymentStatus,
    String? orderStatus,
    String? paymentMethod,
    String? deliveryMethod,
  }) async {
    try {
      final response = await _orderService.getAllOrders(
        page: page,
        pageSize: pageSize,
        keyword: keyword,
        paymentStatus: paymentStatus,
        orderStatus: orderStatus,
        paymentMethod: paymentMethod,
        deliveryMethod: deliveryMethod,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh sách đơn hàng: $e');
      rethrow;
    }
  }

  Future<OrderDetailResponse?> getOrderDetail(int id) async {
    try {
      final response = await _orderService.getOrderDetail(id);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy thông tin đơn hàng: $e');
      rethrow;
    }
  }

  Future<OrderDetailResponse?> updateOrder(ReqUpdateOrder req) async {
    try {
      final response = await _orderService.updateOrder(req);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi cập nhật đơn hàng: $e');
      rethrow;
    }
  }
}
