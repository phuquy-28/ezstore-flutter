import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/data/repositories/promotion_repository.dart';
import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/promotion/view_models/promotion_screen_viewmodel.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/promotion_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromotionScreen extends StatefulWidget {
  final PromotionScreenViewModel viewModel;

  const PromotionScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  PromotionScreenViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_viewModelListener);

    // Monitor scroll events
    _scrollController.addListener(_handleScroll);

    // Initialize data
    Future.microtask(() {
      viewModel.initData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        _isLoading = viewModel.isLoading;
      });
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      viewModel.handleScrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.promotions,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              viewModel.navigateToAddPromotion(context);
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading when initially loading data
    if (_isLoading && viewModel.items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if there is one
    if (viewModel.error != null) {
      return _buildErrorView();
    }

    // Show promotion list
    return _buildPromotionList();
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
            "An error occurred",
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
              viewModel.error!,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.handleRetry,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionList() {
    return PaginatedListView<PromotionResponse>(
      items: viewModel.items ?? [],
      isLoading: _isLoading,
      hasMoreData: viewModel.hasMorePages,
      onLoadMore: viewModel.loadNextPage,
      onRefresh: viewModel.handleRefresh,
      padding: EdgeInsets.zero,
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(),
      itemBuilder: (context, promotion, index) =>
          _buildPromotionItem(promotion),
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
          hintText: "Tìm kiếm theo tên khuyến mãi",
          initialValue: viewModel.searchKeyword,
          onChanged: (value) {
            // Do nothing on change, just update UI
          },
          onSubmitted: viewModel.handleSearchSubmitted,
          onClear: viewModel.handleClearSearch,
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
            viewModel.searchKeyword != null
                ? "Kết quả tìm kiếm: ${viewModel.totalPromotions} khuyến mãi"
                : "Tổng số: ${viewModel.totalPromotions} khuyến mãi",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (viewModel.searchKeyword != null) ...[
            const SizedBox(width: 8),
            Text(
              "for '${viewModel.searchKeyword}'",
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

  Widget _buildPromotionItem(PromotionResponse promotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
      child: RepaintBoundary(
        child: PromotionCard(
          promotion: promotion,
          onTap: () => _showPromotionDetails(context, promotion),
          onDelete: _handleDeletePromotion,
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Text(
      viewModel.searchKeyword != null
          ? "Hiển thị tất cả ${viewModel.totalPromotions} kết quả tìm kiếm cho '${viewModel.searchKeyword}'"
          : "Hiển thị tất cả ${viewModel.totalPromotions} khuyến mãi",
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void _showPromotionDetails(
      BuildContext context, PromotionResponse promotion) {
    if (promotion.id != null) {
      viewModel.navigateToPromotion(context, promotion.id!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dữ liệu khuyến mãi không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Xử lý khi người dùng muốn xóa một khuyến mãi
  void _handleDeletePromotion(int promotionId) async {
    // Hiển thị loading và vô hiệu hóa tương tác
    bool success = false;

    try {
      // Gọi phương thức xóa từ viewModel
      success = await viewModel.deletePromotion(promotionId);
    } catch (e) {
      success = false;
    }

    // Hiển thị kết quả
    if (mounted) {
      viewModel.showDeleteResult(context, success);
    }
  }
}

// Factory method to create the screen with its dependencies
class PromotionScreenFactory {
  static Widget create(BuildContext context) {
    final repository = Provider.of<PromotionRepository>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => PromotionScreenViewModel(repository),
      child: Consumer<PromotionScreenViewModel>(
        builder: (context, viewModel, _) {
          return PromotionScreen(viewModel: viewModel);
        },
      ),
    );
  }
}
