import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import 'package:ezstore_flutter/data/models/order/req_update_order.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/domain/models/order/order_detail_response.dart';
import 'package:ezstore_flutter/domain/models/order/order_response.dart';

class OrderService {
  final ApiService _api;

  OrderService(this._api);

  Future<ApiResponse<PaginatedResponse<OrderResponse>>> getAllOrders({
    int page = 0,
    int pageSize = 10,
    String? keyword,
    String? paymentStatus,
    String? orderStatus,
    String? paymentMethod,
    String? deliveryMethod,
  }) async {
    String path =
        '${ApiConstants.orders}?page=$page&size=$pageSize&sort=createdAt,desc';

    // Thêm bộ lọc tìm kiếm nếu có từ khóa
    List<String> filters = [];

    if (keyword != null && keyword.isNotEmpty) {
      filters.add("code~'$keyword' or shippingInformation.fullName~'$keyword'");
    }

    if (paymentStatus != null) {
      filters.add("paymentStatus~'$paymentStatus'");
    }

    if (orderStatus != null) {
      filters.add("status~'$orderStatus'");
    }

    if (paymentMethod != null) {
      filters.add("paymentMethod~'$paymentMethod'");
    }

    if (deliveryMethod != null) {
      filters.add("deliveryMethod~'$deliveryMethod'");
    }

    if (filters.isNotEmpty) {
      path += "&filter=" + filters.join(" and ");
    }

    return await _api.get(
      path: path,
      fromJson: (json) => PaginatedResponse<OrderResponse>.fromJson(
        json,
        (userJson) => OrderResponse.fromJson(userJson),
      ),
    );
  }

  Future<ApiResponse<OrderDetailResponse>> getOrderDetail(int id) async {
    return await _api.get(
      path: '${ApiConstants.orders}/$id',
      fromJson: (json) => OrderDetailResponse.fromJson(json),
    );
  }

  Future<ApiResponse<OrderDetailResponse>> updateOrder(
      ReqUpdateOrder req) async {
    return await _api.put(
      path: '${ApiConstants.orders}/status',
      data: req.toJson(),
      fromJson: (json) => OrderDetailResponse.fromJson(json),
    );
  }
}
