import 'package:ezstore_flutter/domain/models/order/order_response.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/action_sheet.dart';
import 'package:flutter/material.dart';

class OrderActionSheet extends ActionSheet<OrderResponse> {
  final Function(String)? onConfirmOrder;
  final Function(String)? onCancelOrder;
  final VoidCallback? onUpdateSuccess;

  const OrderActionSheet({
    Key? key,
    required OrderResponse order,
    this.onConfirmOrder,
    this.onCancelOrder,
    this.onUpdateSuccess,
  }) : super(key: key, item: order);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // View Details option
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Xem chi tiết'),
            onTap: () {
              Navigator.pop(context);
              _viewOrderDetails(context);
            },
          ),
          // Edit option (update order status)
          buildEditTile(context),
          // Additional actions (confirm/cancel)
          ...buildAdditionalActions(context),
        ],
      ),
    );
  }

  void _viewOrderDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.orderDetail,
      arguments: {'id': item.id},
    ).then((result) {
      if (result == true && onUpdateSuccess != null) {
        onUpdateSuccess!();
      }
    });
  }

  @override
  ListTile buildEditTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.edit),
      title: const Text('Cập nhật trạng thái'),
      onTap: () {
        Navigator.pop(context);
        onEdit(context);
      },
    );
  }

  @override
  void onEdit(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.updateOrder,
      arguments: {'id': item.id},
    ).then((result) {
      if (result == true && onUpdateSuccess != null) {
        onUpdateSuccess!();
      }
    });
  }

  List<Widget> buildAdditionalActions(BuildContext context) {
    final List<Widget> actions = [];
    final orderCode = item.orderCode ?? '';
    final canConfirm = item.orderStatus?.toUpperCase() == 'PENDING';
    final canCancel = item.orderStatus?.toUpperCase() == 'PENDING' ||
        item.orderStatus?.toUpperCase() == 'PROCESSING';

    if (canConfirm) {
      actions.add(
        ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('Xác nhận đơn hàng'),
          onTap: () {
            Navigator.pop(context);
            if (onConfirmOrder != null) {
              onConfirmOrder!(orderCode);
            }
          },
        ),
      );
    }

    if (canCancel) {
      actions.add(
        ListTile(
          leading: const Icon(Icons.cancel, color: Colors.red),
          title:
              const Text('Hủy đơn hàng', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            _showCancelConfirmation(context, orderCode);
          },
        ),
      );
    }

    return actions;
  }

  void _showCancelConfirmation(BuildContext context, String orderCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: Text('Bạn có chắc chắn muốn hủy đơn hàng $orderCode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onCancelOrder != null) {
                onCancelOrder!(orderCode);
              }
            },
            child: Text(
              'Có',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildDeleteConfirmationContent() {
    // Orders don't have a delete option in this app
    return const SizedBox.shrink();
  }

  @override
  Future<void> onDelete(BuildContext context) async {
    // Orders don't have a delete option in this app
  }
}
