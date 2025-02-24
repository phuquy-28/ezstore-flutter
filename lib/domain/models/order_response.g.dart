// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      orderId: json['orderId'] as String,
      date: json['date'] as String,
      customer: json['customer'] as String,
      total: json['total'] as String,
      paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
      orderStatus: $enumDecode(_$OrderStatusEnumMap, json['orderStatus']),
      quantity: json['quantity'] as String,
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      shippingMethod:
          $enumDecode(_$DeliveryMethodEnumMap, json['shippingMethod']),
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'date': instance.date,
      'customer': instance.customer,
      'total': instance.total,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'orderStatus': _$OrderStatusEnumMap[instance.orderStatus]!,
      'quantity': instance.quantity,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'shippingMethod': _$DeliveryMethodEnumMap[instance.shippingMethod]!,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.PENDING: 'PENDING',
  PaymentStatus.SUCCESS: 'SUCCESS',
  PaymentStatus.FAILED: 'FAILED',
};

const _$OrderStatusEnumMap = {
  OrderStatus.PENDING: 'PENDING',
  OrderStatus.PROCESSING: 'PROCESSING',
  OrderStatus.SHIPPING: 'SHIPPING',
  OrderStatus.DELIVERED: 'DELIVERED',
  OrderStatus.CANCELLED: 'CANCELLED',
  OrderStatus.RETURNED: 'RETURNED',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.COD: 'COD',
  PaymentMethod.VNPAY: 'VNPAY',
};

const _$DeliveryMethodEnumMap = {
  DeliveryMethod.GHN: 'GHN',
  DeliveryMethod.EXPRESS: 'EXPRESS',
};
