import 'package:ezstore_flutter/domain/enums/delivery_method.dart';
import 'package:ezstore_flutter/domain/enums/order_status.dart';
import 'package:ezstore_flutter/domain/enums/payment_method.dart';
import 'package:ezstore_flutter/domain/enums/payment_status.dart';

class OrderResponse {
  final String orderId;
  final String date;
  final String customer;
  final String total;
  final PaymentStatus? paymentStatus;
  final OrderStatus? orderStatus;
  final String quantity;
  final PaymentMethod? paymentMethod;
  final DeliveryMethod? shippingMethod;

  const OrderResponse({
    required this.orderId,
    required this.date,
    required this.customer,
    required this.total,
    this.paymentStatus,
    this.orderStatus,
    required this.quantity,
    this.paymentMethod,
    this.shippingMethod,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'],
      date: json['date'],
      customer: json['customer'],
      total: json['total'],
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      orderStatus: _parseOrderStatus(json['orderStatus']),
      quantity: json['quantity'],
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      shippingMethod: _parseDeliveryMethod(json['shippingMethod']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'date': date,
      'customer': customer,
      'total': total,
      'paymentStatus': paymentStatus?.toString().split('.').last,
      'orderStatus': orderStatus?.toString().split('.').last,
      'quantity': quantity,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'shippingMethod': shippingMethod?.toString().split('.').last,
    };
  }

  // Helper methods to parse enums from strings
  static PaymentStatus? _parsePaymentStatus(String? value) {
    if (value == null) return null;
    try {
      return PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static OrderStatus? _parseOrderStatus(String? value) {
    if (value == null) return null;
    try {
      return OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static PaymentMethod? _parsePaymentMethod(String? value) {
    if (value == null) return null;
    try {
      return PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static DeliveryMethod? _parseDeliveryMethod(String? value) {
    if (value == null) return null;
    try {
      return DeliveryMethod.values.firstWhere(
        (method) => method.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
