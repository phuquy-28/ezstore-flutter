import 'package:ezstore_flutter/config/translations.dart';
import 'package:ezstore_flutter/domain/models/order/order_detail_response.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/order/view_models/order_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderDetailViewModel viewModel;
  final int orderId;

  const OrderDetailScreen({
    Key? key,
    required this.viewModel,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
    _loadData();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    await widget.viewModel.loadOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        title: 'Chi tiết đơn hàng',
        isEditMode: false,
        showEditButton: true,
        onEditToggle: () {
          // Navigate to order update screen
          Navigator.pushNamed(
            context,
            '/updateOrder',
            arguments: {
              'id': widget.orderId,
              // Pass the reason if it exists
              if (widget.viewModel.orderDetail != null &&
                  (widget.viewModel.orderDetail!.status == 'CANCELLED' ||
                      widget.viewModel.orderDetail!.status == 'RETURNED') &&
                  widget.viewModel.orderDetail!.cancelReason != null)
                'reason': widget.viewModel.orderDetail!.cancelReason
            },
          ).then((result) {
            // Refresh data if status was updated
            if (result == true) {
              _loadData();
            }
          });
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              widget.viewModel.error!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final orderDetail = widget.viewModel.orderDetail;
    if (orderDetail == null) {
      return const Center(child: Text('Không tìm thấy thông tin đơn hàng'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfo(orderDetail),
          const SizedBox(height: 12),
          _buildShippingInfo(orderDetail),
          const SizedBox(height: 12),
          _buildProductList(orderDetail),
          const SizedBox(height: 12),
          _buildPriceInfo(orderDetail),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(OrderDetailResponse order) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đơn hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Mã đơn hàng:', order.code ?? 'N/A'),
            _buildInfoRow(
              'Ngày đặt:',
              order.orderDate != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(
                      DateTime.parse(order.orderDate!),
                    )
                  : 'N/A',
            ),
            _buildInfoRow(
              'Hình thức thanh toán:',
              PaymentMethodTranslations.getMethodName(order.paymentMethod),
            ),
            _buildStatusRow(
              'Trạng thái thanh toán:',
              PaymentStatusTranslations.getStatusName(order.paymentStatus),
              PaymentStatusTranslations.getStatusColor(order.paymentStatus),
            ),
            _buildStatusRow(
              'Trạng thái đơn hàng:',
              OrderStatusTranslations.getStatusName(order.status),
              OrderStatusTranslations.getStatusColor(order.status),
            ),
            if (order.status == 'CANCELLED' || order.status == 'RETURNED')
              _buildInfoRow('Lý do:', order.cancelReason ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo(OrderDetailResponse order) {
    final profile = order.shippingProfile;
    if (profile == null) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin giao hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Người nhận:',
              '${profile.firstName} ${profile.lastName}',
            ),
            _buildInfoRow('Số điện thoại:', profile.phoneNumber ?? 'N/A'),
            _buildInfoRow(
              'Địa chỉ:',
              '${profile.address}, ${profile.ward}, ${profile.district}, ${profile.province}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(OrderDetailResponse order) {
    if (order.lineItems == null || order.lineItems!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách sản phẩm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.lineItems!.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[200],
                height: 20,
                thickness: 0.5,
              ),
              itemBuilder: (context, index) {
                final item = order.lineItems![index];
                return _buildProductItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(LineItem item) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    // Calculate discount if any
    final unitPrice = item.unitPrice ?? 0;
    final discount = item.discount ?? 0;
    final originalPrice = unitPrice + discount;
    final quantity = item.quantity ?? 1;
    final totalItemPrice = unitPrice * quantity;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.variantImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.variantImage!,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                  memCacheWidth: 160, // 2x for high-DPI screens
                ),
              )
            else
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_not_supported),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.color != null || item.size != null)
                    Text(
                      'Màu: ${item.color ?? ''}, Kích thước: ${item.size ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (discount > 0)
                        Text(
                          currencyFormat.format(originalPrice),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (discount > 0) const SizedBox(width: 8),
                      Text(
                        currencyFormat.format(unitPrice),
                        style: TextStyle(
                          color: discount > 0 ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'x$quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currencyFormat.format(totalItemPrice),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (discount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Tiết kiệm: ${currencyFormat.format(discount * quantity)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInfo(OrderDetailResponse order) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildPriceRow(
              'Tổng tiền hàng:',
              currencyFormat.format(order.total ?? 0),
            ),
            if (order.discount != null && order.discount! > 0)
              _buildPriceRow(
                'Giảm giá:',
                '- ${currencyFormat.format(order.discount)}',
                textColor: Colors.red,
              ),
            if (order.pointDiscount != null && order.pointDiscount! > 0)
              _buildPriceRow(
                'Giảm giá từ điểm:',
                '- ${currencyFormat.format(order.pointDiscount)}',
                textColor: Colors.red,
              ),
            _buildPriceRow(
              'Phí vận chuyển:',
              currencyFormat.format(order.shippingFee ?? 0),
            ),
            const Divider(),
            _buildPriceRow(
              'Tổng thanh toán:',
              currencyFormat.format(order.finalTotal ?? 0),
              isBold: true,
            ),
            if (order.pointDiscount != null && order.pointDiscount! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Tiết kiệm: ${currencyFormat.format(order.discount ?? 0 + (order.pointDiscount ?? 0))}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Wrap(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
