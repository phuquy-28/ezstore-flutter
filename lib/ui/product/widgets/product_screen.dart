import 'dart:async';
import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/product/product_response.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'product_card.dart';

class ProductScreen extends StatefulWidget {
  final ProductScreenViewModel viewModel;

  const ProductScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Theo dõi sự kiện cuộn
    _scrollController.addListener(_handleScroll);

    // Khởi tạo dữ liệu
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
        title: AppStrings.products,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => widget.viewModel.navigateToAddProduct(context),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Hiển thị loading khi đang tải dữ liệu ban đầu
    if (_isLoading && widget.viewModel.items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị lỗi nếu có
    if (widget.viewModel.error != null) {
      return _buildErrorView();
    }

    // Hiển thị danh sách sản phẩm
    return _buildProductList();
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

  Widget _buildProductList() {
    return PaginatedListView<ProductResponse>(
      items: widget.viewModel.getFilteredProducts(),
      isLoading: _isLoading,
      hasMoreData: widget.viewModel.hasMorePages,
      onLoadMore: widget.viewModel.loadNextPage,
      onRefresh: widget.viewModel.handleRefresh,
      padding: EdgeInsets.zero,
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(),
      itemBuilder: (context, product, index) => _buildProductItem(product),
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
          hintText: "Tìm kiếm theo tên sản phẩm",
          initialValue: widget.viewModel.searchKeyword,
          onChanged: (value) {
            // Không làm gì khi thay đổi, chỉ cập nhật UI
          },
          onSubmitted: widget.viewModel.handleSearchSubmitted,
          onClear: widget.viewModel.handleClearSearch,
        ),
        _buildSearchResult(),
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
                ? "Kết quả tìm kiếm: ${widget.viewModel.totalProducts} sản phẩm"
                : "Tổng số: ${widget.viewModel.totalProducts} sản phẩm",
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

  Widget _buildProductItem(ProductResponse product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
      child: RepaintBoundary(
        child: ProductCard(
          product: product,
          onDelete: _handleDeleteProduct,
          onViewDetails: (productId) =>
              widget.viewModel.navigateToProductDetail(context, productId),
          onEditSuccess: widget.viewModel.handleRefresh,
        ),
      ),
    );
  }

  Future<void> _handleDeleteProduct(int productId) async {
    final success = await widget.viewModel.deleteProduct(productId);
    if (mounted) {
      widget.viewModel.showDeleteResult(context, success);
    }
  }

  Widget _buildEndOfList() {
    return Text(
      widget.viewModel.searchKeyword != null
          ? "Đã hiển thị tất cả ${widget.viewModel.totalProducts} kết quả cho '${widget.viewModel.searchKeyword}'"
          : "Đã hiển thị tất cả ${widget.viewModel.totalProducts} sản phẩm",
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
