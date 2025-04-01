import 'package:ezstore_flutter/ui/order/view_models/order_screen_viewmodel.dart';
import 'package:ezstore_flutter/config/translations.dart';
import 'package:flutter/material.dart';

class FilterOrder extends StatelessWidget {
  final dynamic viewModel;
  final bool isOrderScreenViewModel;

  const FilterOrder({
    Key? key,
    required this.viewModel,
  })  : isOrderScreenViewModel = viewModel is OrderScreenViewModel,
        super(key: key);

  String? get paymentStatusFilter => viewModel.paymentStatusFilter;
  String? get orderStatusFilter => viewModel.orderStatusFilter;
  String? get paymentMethodFilter => viewModel.paymentMethodFilter;
  String? get deliveryMethodFilter => viewModel.deliveryMethodFilter;
  bool get hasActiveFilters => viewModel.hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFilterOption(
            context,
            'Trạng thái thanh toán',
            paymentStatusFilter,
            () => _showPaymentStatusFilter(context),
          ),
          _buildFilterOption(
            context,
            'Trạng thái đơn hàng',
            orderStatusFilter,
            () => _showOrderStatusFilter(context),
          ),
          _buildFilterOption(
            context,
            'Phương thức thanh toán',
            paymentMethodFilter,
            () => _showPaymentMethodFilter(context),
          ),
          _buildFilterOption(
            context,
            'Phương thức giao hàng',
            deliveryMethodFilter,
            () => _showDeliveryMethodFilter(context),
          ),
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    viewModel.clearFilters();
                  },
                  child: const Text('Xóa tất cả bộ lọc'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    String? currentValue,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: currentValue != null
          ? Text(
              currentValue,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            )
          : const Text('Tất cả'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showPaymentStatusFilter(BuildContext context) {
    final options = [
      PaymentStatusTranslations.getStatusName('SUCCESS'),
      PaymentStatusTranslations.getStatusName('PENDING'),
      PaymentStatusTranslations.getStatusName('FAILED'),
    ];
    _showFilterOptions(
      context,
      'Trạng thái thanh toán',
      options,
      paymentStatusFilter,
      viewModel.setPaymentStatusFilter,
    );
  }

  void _showOrderStatusFilter(BuildContext context) {
    final options = [
      OrderStatusTranslations.getStatusName('PENDING'),
      OrderStatusTranslations.getStatusName('PROCESSING'),
      OrderStatusTranslations.getStatusName('SHIPPING'),
      OrderStatusTranslations.getStatusName('DELIVERED'),
      OrderStatusTranslations.getStatusName('CANCELLED'),
      OrderStatusTranslations.getStatusName('RETURNED'),
    ];
    _showFilterOptions(
      context,
      'Trạng thái đơn hàng',
      options,
      orderStatusFilter,
      viewModel.setOrderStatusFilter,
    );
  }

  void _showPaymentMethodFilter(BuildContext context) {
    final options = [
      PaymentMethodTranslations.getMethodName('COD'),
      PaymentMethodTranslations.getMethodName('VNPAY'),
    ];
    _showFilterOptions(
      context,
      'Phương thức thanh toán',
      options,
      paymentMethodFilter,
      viewModel.setPaymentMethodFilter,
    );
  }

  void _showDeliveryMethodFilter(BuildContext context) {
    final options = [
      DeliveryMethodTranslations.getMethodName('GHN'),
      DeliveryMethodTranslations.getMethodName('EXPRESS'),
    ];
    _showFilterOptions(
      context,
      'Phương thức giao hàng',
      options,
      deliveryMethodFilter,
      viewModel.setDeliveryMethodFilter,
    );
  }

  void _showFilterOptions(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    Function(String?) setter,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...options.map((option) => ListTile(
                      title: Text(option),
                      trailing: currentValue == option
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setter(option);
                        setState(() {});
                        Navigator.pop(context);
                      },
                    )),
                ListTile(
                  title: const Text('Tất cả',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: currentValue == null
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setter(null);
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
