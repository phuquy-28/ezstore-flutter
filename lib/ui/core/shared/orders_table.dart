import 'package:flutter/material.dart';
import '../../../domain/models/order/order_response.dart';
import '../../../domain/enums/payment_status.dart';
import '../../../domain/enums/order_status.dart';
import '../../../domain/enums/payment_method.dart';
import '../../../domain/enums/delivery_method.dart';

class OrdersTable extends StatelessWidget {
  final List<OrderResponse> orders;

  const OrdersTable({
    super.key,
    required this.orders,
  });

  static List<OrderResponse> getMockOrders() {
    return [
      const OrderResponse(
        orderId: 'ORD-1734919325123',
        date: '23/12/2024 09:02',
        customer: 'oss sssss',
        total: '598.000 ₫',
        paymentStatus: PaymentStatus.SUCCESS,
        orderStatus: OrderStatus.PROCESSING,
        quantity: '2',
        paymentMethod: PaymentMethod.VNPAY,
        shippingMethod: DeliveryMethod.GHN,
      ),
      const OrderResponse(
        orderId: 'ORD-1734915811378',
        date: '23/12/2024 08:03',
        customer: 'oss sssss',
        total: '299.000 ₫',
        paymentStatus: PaymentStatus.PENDING,
        orderStatus: OrderStatus.PENDING,
        quantity: '1',
        paymentMethod: PaymentMethod.COD,
        shippingMethod: DeliveryMethod.EXPRESS,
      ),
      const OrderResponse(
        orderId: 'ORD-1734912905386',
        date: '23/12/2024 07:15',
        customer: 'oss sssss',
        total: '299.000 ₫',
        paymentStatus: PaymentStatus.FAILED,
        orderStatus: OrderStatus.CANCELLED,
        quantity: '1',
        paymentMethod: PaymentMethod.VNPAY,
        shippingMethod: DeliveryMethod.GHN,
      ),
    ];
  }

  Color _getPaymentStatusColor(PaymentStatus? status) {
    if (status == null) return Colors.grey;
    
    switch (status) {
      case PaymentStatus.SUCCESS:
        return Colors.green;
      case PaymentStatus.PENDING:
        return Colors.orange;
      case PaymentStatus.FAILED:
        return Colors.red;
    }
  }

  Color _getOrderStatusColor(OrderStatus? status) {
    if (status == null) return Colors.grey;
    
    switch (status) {
      case OrderStatus.PROCESSING:
        return Colors.blue;
      case OrderStatus.PENDING:
        return Colors.yellow;
      case OrderStatus.SHIPPING:
        return Colors.lightBlue;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
      case OrderStatus.RETURNED:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            columns: const [
              DataColumn(label: Text('Mã đơn hàng')),
              DataColumn(label: Text('Ngày đặt')),
              DataColumn(label: Text('Khách hàng')),
              DataColumn(label: Text('Tổng tiền')),
              DataColumn(label: Text('Trạng thái thanh toán')),
              DataColumn(label: Text('Trạng thái đơn hàng')),
              DataColumn(label: Text('Số lượng')),
              DataColumn(label: Text('Phương thức thanh toán')),
              DataColumn(label: Text('Phương thức giao hàng')),
            ],
            rows: orders.map((order) => _buildOrderRow(order)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildOrderRow(OrderResponse order) {
    return DataRow(
      cells: [
        DataCell(Text(order.orderId)),
        DataCell(Text(order.date)),
        DataCell(Text(order.customer)),
        DataCell(Text(order.total)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _getPaymentStatusColor(order.paymentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.paymentStatus?.toString().split('.').last ?? 'UNKNOWN',
              style: TextStyle(
                color: _getPaymentStatusColor(order.paymentStatus),
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getOrderStatusColor(order.orderStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.orderStatus?.toString().split('.').last ?? 'UNKNOWN',
              style: TextStyle(
                color: _getOrderStatusColor(order.orderStatus),
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(order.quantity)),
        DataCell(Text(order.paymentMethod?.toString().split('.').last ?? 'UNKNOWN')),
        DataCell(Text(order.shippingMethod?.toString().split('.').last ?? 'UNKNOWN')),
      ],
    );
  }
}
