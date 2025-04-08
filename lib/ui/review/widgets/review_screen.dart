import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/review/view_models/review_screen_viewmodel.dart';
import 'package:ezstore_flutter/ui/review/widgets/review_card.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final ReviewScreenViewModel viewModel;

  const ReviewScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
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
        title: AppStrings.reviews,
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

    // Show review list
    return _buildReviewList();
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

  Widget _buildReviewList() {
    return PaginatedListView<ReviewResponse>(
      items: widget.viewModel.getFilteredReviews(),
      isLoading: _isLoading,
      hasMoreData: widget.viewModel.hasMorePages,
      onLoadMore: widget.viewModel.loadNextPage,
      onRefresh: widget.viewModel.handleRefresh,
      padding: EdgeInsets.zero,
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(),
      itemBuilder: (context, review, index) => _buildReviewItem(review),
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
          hintText: "Tìm kiếm theo nội dung hoặc email người dùng",
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
                ? "Kết quả tìm kiếm: ${widget.viewModel.totalReviews} đánh giá"
                : "Tổng số: ${widget.viewModel.totalReviews} đánh giá",
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

    if (widget.viewModel.ratingFilter != null) {
      filters.add(_buildFilterChip(
        'Đánh giá: ${widget.viewModel.ratingFilter} sao',
        () => widget.viewModel.setRatingFilter(null),
      ));
    }

    if (widget.viewModel.publishedFilter != null) {
      filters.add(_buildFilterChip(
        'Trạng thái: ${widget.viewModel.publishedFilter! ? "Công khai" : "Ẩn"}',
        () => widget.viewModel.setPublishedFilter(null),
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

  Widget _buildReviewItem(ReviewResponse review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
      child: ReviewCard(
        review: review,
        onViewDetails: () => _navigateToDetailScreen(review),
        onTogglePublished: () => widget.viewModel.togglePublished(review),
        onDelete: () => widget.viewModel.deleteReview(review),
      ),
    );
  }

  void _navigateToDetailScreen(ReviewResponse review) {
    Navigator.pushNamed(
      context,
      AppRoutes.reviewDetail,
      arguments: {'review': review},
    );
  }

  Widget _buildEndOfList() {
    return Text(
      widget.viewModel.searchKeyword != null
          ? "Đã hiển thị tất cả ${widget.viewModel.totalReviews} kết quả cho '${widget.viewModel.searchKeyword}'"
          : "Đã hiển thị tất cả ${widget.viewModel.totalReviews} đánh giá",
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
