import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/order/order_response.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:ezstore_flutter/ui/order/view_models/order_screen_viewmodel.dart';
import 'package:ezstore_flutter/ui/order/widgets/order_card.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  final OrderScreenViewModel viewModel;

  const OrderScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Track scroll events
    _scrollController.addListener(_handleScroll);

    // Initialize data
    Future.microtask(() {
      widget.viewModel.initData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        _isLoading = widget.viewModel.isLoading;
      });
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.handleScrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.orders,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => widget.viewModel.showFilterOptions(context),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading indicator when initially loading data
    if (_isLoading && widget.viewModel.items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if any
    if (widget.viewModel.error != null) {
      return _buildErrorView();
    }

    // Show order list
    return _buildOrderList();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              widget.viewModel.error!,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.viewModel.handleRetry,
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return PaginatedListView<OrderResponse>(
      items: widget.viewModel.getFilteredOrders(),
      isLoading: _isLoading,
      hasMoreData: widget.viewModel.hasMorePages,
      onLoadMore: widget.viewModel.loadNextPage,
      onRefresh: widget.viewModel.handleRefresh,
      padding: EdgeInsets.zero,
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(),
      itemBuilder: (context, order, index) => _buildOrderItem(order),
      endOfListWidget: _buildEndOfList(),
      useListView: true,
      preloadItemCount: 8,
      loadMoreThreshold: 500,
      initialKeepAliveCount: 5,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hintText: "Tìm kiếm theo mã đơn hàng hoặc tên khách hàng",
          initialValue: widget.viewModel.searchKeyword,
          onChanged: (value) {
            // Only update UI, don't trigger search
          },
          onSubmitted: widget.viewModel.handleSearchSubmitted,
          onClear: widget.viewModel.handleClearSearch,
        ),
        _buildSearchResult(),
        _buildActiveFilters(),
      ],
    );
  }

  Widget _buildSearchResult() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingNormal,
        right: AppSizes.paddingNormal,
        bottom: AppSizes.paddingSmall,
      ),
      child: Row(
        children: [
          Text(
            widget.viewModel.searchKeyword != null
                ? "Kết quả tìm kiếm: ${widget.viewModel.totalOrders} đơn hàng"
                : "Tổng số: ${widget.viewModel.totalOrders} đơn hàng",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (widget.viewModel.searchKeyword != null) ...[
            const SizedBox(width: 8),
            Text(
              "cho '${widget.viewModel.searchKeyword}'",
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final List<Widget> filters = [];

    if (widget.viewModel.paymentStatusFilter != null) {
      filters.add(_buildFilterChip(
        'Thanh toán: ${widget.viewModel.paymentStatusFilter}',
        () => widget.viewModel.setPaymentStatusFilter(null),
      ));
    }

    if (widget.viewModel.orderStatusFilter != null) {
      filters.add(_buildFilterChip(
        'Trạng thái: ${widget.viewModel.orderStatusFilter}',
        () => widget.viewModel.setOrderStatusFilter(null),
      ));
    }

    if (widget.viewModel.paymentMethodFilter != null) {
      filters.add(_buildFilterChip(
        'Phương thức: ${widget.viewModel.paymentMethodFilter}',
        () => widget.viewModel.setPaymentMethodFilter(null),
      ));
    }

    if (widget.viewModel.deliveryMethodFilter != null) {
      filters.add(_buildFilterChip(
        'Giao hàng: ${widget.viewModel.deliveryMethodFilter}',
        () => widget.viewModel.setDeliveryMethodFilter(null),
      ));
    }

    if (filters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingNormal,
        right: AppSizes.paddingNormal,
        bottom: AppSizes.paddingSmall,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters,
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: Colors.blue.withOpacity(0.1),
      deleteIconColor: Colors.blue,
      labelStyle: const TextStyle(color: Colors.blue),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildOrderItem(OrderResponse order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
      child: RepaintBoundary(
        child: OrderCard(
          order: order,
          onViewDetails: (orderId) {
            Navigator.pushNamed(
              context,
              '/orderDetail',
              arguments: {'id': orderId},
            ).then((_) {
              // Refresh the orders list when returning from detail screen
              widget.viewModel.handleRefresh();
            });
          },
          onConfirm: _confirmOrder,
          onCancel: _cancelOrder,
        ),
      ),
    );
  }

  Future<void> _confirmOrder(String orderCode) async {
    // Implement order confirmation logic if needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đơn hàng $orderCode đã được xác nhận'),
        backgroundColor: Colors.green,
      ),
    );
    widget.viewModel.handleRefresh();
  }

  Future<void> _cancelOrder(String orderCode) async {
    // Implement order cancellation logic if needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đơn hàng $orderCode đã bị hủy'),
        backgroundColor: Colors.red,
      ),
    );
    widget.viewModel.handleRefresh();
  }

  Widget _buildEndOfList() {
    return Text(
      widget.viewModel.searchKeyword != null
          ? "Đã hiển thị tất cả ${widget.viewModel.totalOrders} kết quả cho '${widget.viewModel.searchKeyword}'"
          : "Đã hiển thị tất cả ${widget.viewModel.totalOrders} đơn hàng",
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
