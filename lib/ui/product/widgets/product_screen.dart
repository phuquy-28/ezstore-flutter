import 'dart:async';
import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ gọi loadData một lần sau khi widget được khởi tạo
    if (!_isInitialized) {
      _isInitialized = true;
      // Sử dụng Future.microtask để đảm bảo gọi sau khi build hoàn tất
      Future.microtask(() {
        Provider.of<ProductScreenViewModel>(context, listen: false)
            .loadFirstPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for more targeted rebuilds
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.products,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addProduct);
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Consumer<ProductScreenViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.items == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.error != null) {
            return _buildErrorView(viewModel.error!);
          } else {
            return _buildProductList(viewModel);
          }
        },
      ),
    );
  }

  Widget _buildProductList(ProductScreenViewModel viewModel) {
    return PaginatedListView(
      items: viewModel.getFilteredProducts(),
      isLoading: viewModel.isLoading,
      hasMoreData: viewModel.hasMorePages,
      onLoadMore: () => viewModel.loadNextPage(),
      onRefresh: () => viewModel.refresh(),
      padding: EdgeInsets.zero,
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(viewModel),
      itemBuilder: (context, product, index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
          child: RepaintBoundary(
            child: ProductCard(
              product: product,
              onDelete: (productId) async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final success = await viewModel.deleteProduct(productId);
                if (mounted) {
                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Xóa sản phẩm thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Không thể xóa sản phẩm. Vui lòng thử lại sau.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
      endOfListWidget: Text(
        viewModel.searchKeyword != null
            ? "Đã hiển thị tất cả ${viewModel.totalProducts} kết quả cho '${viewModel.searchKeyword}'"
            : "Đã hiển thị tất cả ${viewModel.totalProducts} sản phẩm",
        style: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildHeader(ProductScreenViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hintText: "Tìm kiếm theo tên sản phẩm",
          initialValue: viewModel.searchKeyword,
          onChanged: (value) {
            // Không làm gì khi thay đổi, chỉ cập nhật UI
          },
          onSubmitted: (value) {
            // Gọi tìm kiếm khi người dùng nhấn Enter
            viewModel.searchProducts(value);
          },
          onClear: () {
            // Xóa tìm kiếm và tải lại dữ liệu ban đầu
            viewModel.clearSearch();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingNormal,
            right: AppSizes.paddingNormal,
            bottom: AppSizes.paddingSmall,
          ),
          child: Row(
            children: [
              Text(
                viewModel.searchKeyword != null
                    ? "Kết quả tìm kiếm: ${viewModel.totalProducts} sản phẩm"
                    : "Tổng số: ${viewModel.totalProducts} sản phẩm",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (viewModel.searchKeyword != null) ...[
                const SizedBox(width: 8),
                Text(
                  "cho '${viewModel.searchKeyword}'",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String errorMessage) {
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
              errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProductScreenViewModel>(context, listen: false)
                  .refresh();
            },
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }
}
