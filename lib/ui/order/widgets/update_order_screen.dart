import 'package:ezstore_flutter/config/translations.dart';
import 'package:ezstore_flutter/domain/models/order/order_detail_response.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/order/view_models/update_order_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateOrderScreen extends StatefulWidget {
  final UpdateOrderViewModel viewModel;
  final int orderId;

  const UpdateOrderScreen({
    Key? key,
    required this.viewModel,
    required this.orderId,
  }) : super(key: key);

  @override
  State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
}

class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
  // Order status options
  final List<String> orderStatuses = [
    'PENDING', // Chờ xác nhận
    'PROCESSING', // Đã xác nhận
    'SHIPPING', // Đang giao
    'DELIVERED', // Đã giao
    'RETURNED', // Trả hàng
    'CANCELLED', // Đã huỷ
  ];

  // Reason text controller for cancellation or return
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
    _loadData();

    // Initialize reason from route arguments if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the arguments
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null && modalRoute.settings.arguments != null) {
        final arguments = modalRoute.settings.arguments as Map<String, dynamic>;
        if (arguments.containsKey('reason')) {
          final reason = arguments['reason'] as String;
          _reasonController.text = reason;
          widget.viewModel.updateReason(reason);
        }
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
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
        title: 'Cập nhật đơn hàng',
        isEditMode: true,
        showEditButton: false,
        onEditToggle: () {}, // Not used but required by the DetailAppBar
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
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
          _buildOrderSummary(orderDetail),
          const SizedBox(height: 12),
          _buildStatusUpdateSection(orderDetail),
          const SizedBox(height: 12),
          if (_shouldShowReasonField()) _buildReasonField(),
          const SizedBox(height: 12),
          _buildStatusHistory(orderDetail),
        ],
      ),
    );
  }

  bool _shouldShowReasonField() {
    final orderDetail = widget.viewModel.orderDetail;
    if (orderDetail == null) return false;

    // Only show reason field when changing to CANCELLED or RETURNED
    final newStatus = widget.viewModel.newStatus;
    return newStatus == 'CANCELLED' || newStatus == 'RETURNED';
  }

  Widget _buildOrderSummary(OrderDetailResponse order) {
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
              'Khách hàng:',
              order.shippingProfile != null
                  ? '${order.shippingProfile!.firstName} ${order.shippingProfile!.lastName}'
                  : 'N/A',
            ),
            _buildInfoRow(
              'Tổng tiền:',
              currencyFormat.format(order.finalTotal ?? 0),
            ),
            _buildStatusRow(
              'Trạng thái:',
              OrderStatusTranslations.getStatusName(order.status),
              OrderStatusTranslations.getStatusColor(order.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection(OrderDetailResponse order) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cập nhật trạng thái',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusStepper(order),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(OrderDetailResponse order) {
    return Column(
      children: [
        // Status progress visualization
        SizedBox(
          height: 95, // Fixed height for the status stepper
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(orderStatuses.length, (index) {
              final status = orderStatuses[index];
              final isActive = widget.viewModel.newStatus == status;
              final isCurrentStatus = order.status == status;
              final isCompleted = _isStatusCompleted(order.status, status);
              final isDisabled = _isStatusDisabled(order.status, status);

              return Expanded(
                child: Column(
                  children: [
                    // Circle indicator
                    GestureDetector(
                      onTap:
                          isDisabled ? null : () => _handleStatusChange(status),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.blue
                              : isCurrentStatus
                                  ? Colors.blue[100]
                                  : isCompleted
                                      ? Colors.green[100]
                                      : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? Colors.blue
                                : isCurrentStatus
                                    ? Colors.blue
                                    : isCompleted
                                        ? Colors.green
                                        : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getStatusIcon(status),
                            color: isActive
                                ? Colors.white
                                : isCurrentStatus
                                    ? Colors.blue
                                    : isCompleted
                                        ? Colors.green
                                        : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status label
                    Flexible(
                      child: Text(
                        OrderStatusTranslations.getStatusName(status),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive || isCurrentStatus
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isDisabled
                              ? Colors.grey[400]
                              : isActive
                                  ? Colors.blue
                                  : isCurrentStatus
                                      ? Colors.blue
                                      : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // Status selection chips
        const SizedBox(height: 20),
        const Text(
          'Chọn trạng thái mới:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: orderStatuses.map((status) {
            final isSelected = widget.viewModel.newStatus == status;
            final isDisabled = _isStatusDisabled(order.status, status);
            final statusName = OrderStatusTranslations.getStatusName(status);
            final statusColor = OrderStatusTranslations.getStatusColor(status);

            return ChoiceChip(
              label: Text(statusName),
              selected: isSelected,
              onSelected: isDisabled
                  ? null
                  : (selected) {
                      if (selected) {
                        _handleStatusChange(status);
                      }
                    },
              backgroundColor:
                  isDisabled ? Colors.grey[200] : statusColor.withOpacity(0.1),
              selectedColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isDisabled ? Colors.grey[500] : statusColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? statusColor : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    // Initialize the reason controller if it's empty but we have a reason from the viewModel
    if (_reasonController.text.isEmpty && widget.viewModel.reason.isNotEmpty) {
      _reasonController.text = widget.viewModel.reason;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.viewModel.newStatus == 'CANCELLED'
                  ? 'Lý do huỷ đơn'
                  : 'Lý do trả hàng',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: widget.viewModel.newStatus == 'CANCELLED'
                    ? 'Nhập lý do huỷ đơn hàng...'
                    : 'Nhập lý do trả hàng...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                widget.viewModel.updateReason(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistory(OrderDetailResponse order) {
    // This is a placeholder for status history
    // In a real implementation, you would fetch the status history from the API
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử trạng thái',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Placeholder status history
            _buildStatusHistoryItem(
              status: 'PENDING',
              date: order.orderDate ?? '',
              user: 'Hệ thống',
            ),
            // Add more history items here if available
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistoryItem({
    required String status,
    required String date,
    required String user,
  }) {
    final statusName = OrderStatusTranslations.getStatusName(status);
    final statusColor = OrderStatusTranslations.getStatusColor(status);
    final formattedDate = date.isNotEmpty
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date))
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$formattedDate bởi $user',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              style: const TextStyle(fontWeight: FontWeight.w500),
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
            width: 120,
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Huỷ'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Lưu thay đổi',
              onPressed: _handleSaveChanges,
              isLoading: widget.viewModel.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to determine if a status should be disabled for selection
  bool _isStatusDisabled(String? currentStatus, String status) {
    if (currentStatus == null) return false;

    // If already canceled or returned, disable all other statuses
    if (currentStatus == 'CANCELLED' || currentStatus == 'RETURNED') {
      return status != currentStatus;
    }

    // If delivered, only allow RETURNED
    if (currentStatus == 'DELIVERED') {
      return status != 'RETURNED' && status != currentStatus;
    }

    // Always allow cancellation for PENDING orders (not yet confirmed)
    if (currentStatus == 'PENDING' && status == 'CANCELLED') {
      return false;
    }

    // Normal progression logic
    final currentIndex = orderStatuses.indexOf(currentStatus);
    final statusIndex = orderStatuses.indexOf(status);

    // Allow current status and next status in progression
    // Also allow CANCELLED from any state except DELIVERED
    return (statusIndex > currentIndex + 1) ||
        (status == 'RETURNED' && currentStatus != 'DELIVERED') ||
        (statusIndex < currentIndex && status != 'CANCELLED');
  }

  // Helper to determine if a status is completed
  bool _isStatusCompleted(String? currentStatus, String status) {
    if (currentStatus == null) return false;
    if (currentStatus == 'CANCELLED' || currentStatus == 'RETURNED')
      return false;

    final currentIndex = orderStatuses.indexOf(currentStatus);
    final statusIndex = orderStatuses.indexOf(status);

    return statusIndex < currentIndex;
  }

  // Get appropriate icon for each status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'PROCESSING':
        return Icons.settings;
      case 'SHIPPING':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
        return Icons.done_all;
      case 'RETURNED':
        return Icons.assignment_return;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  // Handle status change
  void _handleStatusChange(String status) {
    setState(() {
      widget.viewModel.updateStatus(status);

      // Reset reason if not needed
      if (status != 'CANCELLED' && status != 'RETURNED') {
        _reasonController.clear();
        widget.viewModel.updateReason('');
      }
    });
  }

  // Handle save changes
  Future<void> _handleSaveChanges() async {
    // Check if the reason is required and provided
    if (widget.viewModel.newStatus == 'CANCELLED' ||
        widget.viewModel.newStatus == 'RETURNED') {
      if (_reasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.newStatus == 'CANCELLED'
                ? 'Vui lòng nhập lý do huỷ đơn hàng'
                : 'Vui lòng nhập lý do trả hàng'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final result = await widget.viewModel.saveChanges();

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
            context, true); // Return true to indicate successful update
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.viewModel.error ?? 'Cập nhật đơn hàng thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
