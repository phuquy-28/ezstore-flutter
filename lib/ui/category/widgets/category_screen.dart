import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:flutter/material.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_screen_view_model.dart';
import 'package:ezstore_flutter/ui/category/widgets/category_card.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryScreenViewModel viewModel;

  const CategoryScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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
        title: AppStrings.categories,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => widget.viewModel.navigateToAddCategory(context),
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

    // Hiển thị danh sách danh mục
    return _buildCategoryList();
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

  Widget _buildCategoryList() {
    return PaginatedListView<Category>(
      items: widget.viewModel.items ?? [],
      isLoading: _isLoading,
      hasMoreData: widget.viewModel.hasMorePages,
      onLoadMore: widget.viewModel.loadNextPage,
      onRefresh: widget.viewModel.handleRefresh,
      padding: EdgeInsets.zero,
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(),
      itemBuilder: (context, category, index) => _buildCategoryItem(category),
      endOfListWidget: _buildEndOfList(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hintText: "Tìm kiếm theo tên danh mục",
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
                ? "Kết quả tìm kiếm: ${widget.viewModel.totalCategories} danh mục"
                : "Tổng số: ${widget.viewModel.totalCategories} danh mục",
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

  Widget _buildCategoryItem(Category category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
      child: RepaintBoundary(
        child: CategoryCard(
          category: category,
          onViewDetails: () =>
              widget.viewModel.navigateToCategory(context, category.id ?? 0),
          onDelete: _handleDeleteCategory,
          onEditSuccess: widget.viewModel.handleRefresh,
        ),
      ),
    );
  }

  Future<void> _handleDeleteCategory(int categoryId) async {
    try {
      final success = await widget.viewModel.deleteCategory(categoryId);
      if (mounted) {
        widget.viewModel.showDeleteResult(context, success);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa danh mục thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEndOfList() {
    return Text(
      widget.viewModel.searchKeyword != null
          ? "Đã hiển thị tất cả ${widget.viewModel.totalCategories} kết quả cho '${widget.viewModel.searchKeyword}'"
          : "Đã hiển thị tất cả ${widget.viewModel.totalCategories} danh mục",
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
