import 'package:ezstore_flutter/domain/enums/delivery_method.dart';
import 'package:ezstore_flutter/domain/enums/order_status.dart';
import 'package:ezstore_flutter/domain/enums/payment_method.dart';
import 'package:ezstore_flutter/domain/enums/payment_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_response.g.dart';

@JsonSerializable()
class OrderResponse {
  final String orderId;
  final String date;
  final String customer;
  final String total;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final String quantity;
  final PaymentMethod paymentMethod;
  final DeliveryMethod shippingMethod;

  const OrderResponse({
    required this.orderId,
    required this.date,
    required this.customer,
    required this.total,
    required this.paymentStatus,
    required this.orderStatus,
    required this.quantity,
    required this.paymentMethod,
    required this.shippingMethod,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}
