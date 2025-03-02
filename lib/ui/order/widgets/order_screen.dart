import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Order {
  final String id;
  final DateTime orderDate;
  final String customerName;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;
  final int quantity;
  final String paymentMethod;
  final String deliveryMethod;

  Order({
    required this.id,
    required this.orderDate,
    required this.customerName,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.quantity,
    required this.paymentMethod,
    required this.deliveryMethod,
  });
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<Order> orders = [
    Order(
      id: 'ORD-1734919325123',
      orderDate: DateTime(2024, 12, 23, 9, 2),
      customerName: 'oss sssss',
      totalAmount: 598000,
      paymentStatus: 'Đã thanh toán',
      orderStatus: 'Đang xử lý',
      quantity: 2,
      paymentMethod: 'Thanh toán qua VNPAY',
      deliveryMethod: 'Giao hàng nhanh',
    ),
    Order(
      id: 'ORD-1734915811378',
      orderDate: DateTime(2024, 12, 23, 8, 3),
      customerName: 'oss sssss',
      totalAmount: 299000,
      paymentStatus: 'Chờ thanh toán',
      orderStatus: 'Chờ xác nhận',
      quantity: 1,
      paymentMethod: 'Thanh toán khi nhận hàng',
      deliveryMethod: 'Giao hàng nhanh',
    ),
    // Add more orders as needed
  ];

  String searchQuery = '';

  List<Order> get filteredOrders {
    if (searchQuery.isEmpty) {
      return orders;
    }
    return orders
        .where((order) =>
            order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
            order.customerName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.orders,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.paddingNormal,
              top: AppSizes.paddingNormal,
              right: AppSizes.paddingNormal,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo mã đơn hàng, tên khách hàng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusNormal),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingNormal),
              itemCount: filteredOrders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.paddingSmall),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return OrderCard(order: order);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Add filter options here
              ListTile(
                title: const Text('Trạng thái thanh toán'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show payment status filter options
                },
              ),
              ListTile(
                title: const Text('Trạng thái đơn hàng'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show order status filter options
                },
              ),
              ListTile(
                title: const Text('Phương thức thanh toán'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show payment method filter options
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  Color getStatusColor(String status) {
    switch (status) {
      case 'Đã thanh toán':
        return Colors.green;
      case 'Chờ thanh toán':
        return Colors.orange;
      case 'Thanh toán thất bại':
        return Colors.red;
      case 'Đang xử lý':
        return Colors.blue;
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showOrderDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showActionSheet(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(order.customerName),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'x${order.quantity}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          getStatusColor(order.paymentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: getStatusColor(order.paymentStatus),
                      ),
                    ),
                    child: Text(
                      order.paymentStatus,
                      style: TextStyle(
                        color: getStatusColor(order.paymentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(order.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: getStatusColor(order.orderStatus),
                      ),
                    ),
                    child: Text(
                      order.orderStatus,
                      style: TextStyle(
                        color: getStatusColor(order.orderStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Xem chi tiết'),
                onTap: () {
                  Navigator.pop(context);
                  _showOrderDetails(context);
                },
              ),
              if (order.orderStatus == 'Chờ xác nhận')
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Xác nhận đơn hàng'),
                  onTap: () {
                    Navigator.pop(context);
                    // Confirm order logic
                  },
                ),
              if (order.orderStatus == 'Chờ xác nhận')
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Hủy đơn hàng',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCancelConfirmation(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết đơn hàng',
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
              const SizedBox(height: 16),
              _buildDetailRow('Mã đơn hàng:', order.id),
              _buildDetailRow('Khách hàng:', order.customerName),
              _buildDetailRow(
                'Ngày đặt:',
                DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate),
              ),
              _buildDetailRow(
                'Tổng tiền:',
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                  decimalDigits: 0,
                ).format(order.totalAmount),
              ),
              _buildDetailRow('Số lượng:', '${order.quantity}'),
              _buildDetailRow('Phương thức thanh toán:', order.paymentMethod),
              _buildDetailRow('Phương thức giao hàng:', order.deliveryMethod),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Trạng thái thanh toán:'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          getStatusColor(order.paymentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: getStatusColor(order.paymentStatus),
                      ),
                    ),
                    child: Text(
                      order.paymentStatus,
                      style: TextStyle(
                        color: getStatusColor(order.paymentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Trạng thái đơn hàng:'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(order.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: getStatusColor(order.orderStatus),
                      ),
                    ),
                    child: Text(
                      order.orderStatus,
                      style: TextStyle(
                        color: getStatusColor(order.orderStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: Text('Bạn có chắc chắn muốn hủy đơn hàng ${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Cancel order logic
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
}
