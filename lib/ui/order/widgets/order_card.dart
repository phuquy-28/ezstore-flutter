import 'package:ezstore_flutter/config/translations.dart';
import 'package:ezstore_flutter/domain/models/order/order_response.dart';
import 'package:ezstore_flutter/ui/order/widgets/order_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderResponse order;
  final Function(int)? onViewDetails;
  final Function(String)? onConfirm;
  final Function(String)? onCancel;

  const OrderCard({
    Key? key,
    required this.order,
    this.onViewDetails,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    final orderCode = order.orderCode ?? 'N/A';
    final createdDate =
        order.orderDate != null ? DateTime.tryParse(order.orderDate!) : null;
    final formattedDate = createdDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdDate)
        : 'N/A';
    final total = order.total ?? 0;
    final paymentStatusText =
        PaymentStatusTranslations.getStatusName(order.paymentStatus);
    final orderStatusText =
        OrderStatusTranslations.getStatusName(order.orderStatus);
    final customerName = order.customerName ?? 'Không xác định';
    final paymentMethod =
        PaymentMethodTranslations.getMethodName(order.paymentMethod);
    final deliveryMethod =
        DeliveryMethodTranslations.getMethodName(order.deliveryMethod);

    final paymentStatusColor =
        PaymentStatusTranslations.getStatusColor(order.paymentStatus);
    final orderStatusColor =
        OrderStatusTranslations.getStatusColor(order.orderStatus);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (onViewDetails != null) {
            onViewDetails!(order.id ?? 0);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      child: const Icon(Icons.more_vert),
                      onTap: () {
                        _showActionSheet(context, orderCode);
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(customerName),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(formattedDate),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payment, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    paymentMethod,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_shipping, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    deliveryMethod,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tổng tiền: ' + currencyFormat.format(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusChip(paymentStatusText, paymentStatusColor),
                  _buildStatusChip(orderStatusText, orderStatusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, String orderCode) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return OrderActionSheet(
          order: order,
          onConfirmOrder: onConfirm,
          onCancelOrder: onCancel,
          onUpdateSuccess: () {
            // Refresh the order card data if needed
            if (onViewDetails != null) {
              onViewDetails!(order.id ?? 0);
            }
          },
        );
      },
    );
  }
}
