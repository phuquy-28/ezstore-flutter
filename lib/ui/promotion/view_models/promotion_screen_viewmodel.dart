import 'package:ezstore_flutter/data/repositories/promotion_repository.dart';
import 'package:ezstore_flutter/domain/models/promotion/promotion_response.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:ezstore_flutter/routing/app_routes.dart';

class PromotionScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<PromotionResponse> {
  final PromotionRepository _promotionRepository;
  String? _searchKeyword;
  bool _isDeletingPromotion = false;
  String? _deleteErrorMessage;
  final TextEditingController searchController = TextEditingController();

  // Cache management
  Map<String, List<PromotionResponse>> _cachedPromotions = {};
  final int _cacheTimeInMinutes = 5;
  DateTime? _lastLoadTime;

  PromotionScreenViewModel(this._promotionRepository) {
    setPageSize(10); // Set page size
  }

  String? get searchKeyword => _searchKeyword;
  bool get isDeletingPromotion => _isDeletingPromotion;
  String? get deleteErrorMessage => _deleteErrorMessage;
  int get totalPromotions => totalItems;
  String? get error => errorMessage;
  bool get hasMorePages => hasMoreData;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void initData() {
    if (items == null) {
      loadFirstPage();
    }
  }

  // Cache key generation
  String _getCacheKey(int page, String? keyword) {
    return 'page_${page}_keyword_${keyword ?? "all"}';
  }

  // Check if cache is still valid
  bool _isCacheValid() {
    if (_lastLoadTime == null) return false;
    final difference = DateTime.now().difference(_lastLoadTime!);
    return difference.inMinutes < _cacheTimeInMinutes;
  }

  @override
  Future<PaginationResult<PromotionResponse>?> fetchData(
      int page, int pageSize) async {
    // Check if this is a search operation
    final isNewSearch =
        _searchKeyword != null && searchController.text != _searchKeyword;

    // Check cache first if not a new search
    final cacheKey = _getCacheKey(page, _searchKeyword);
    if (!isNewSearch &&
        _cachedPromotions.containsKey(cacheKey) &&
        _isCacheValid()) {
      final cachedData = _cachedPromotions[cacheKey]!;
      return PaginationResult<PromotionResponse>(
        data: cachedData,
        totalItems: totalItems, // Use existing total
        totalPages: totalPages, // Use existing pages
        currentPage: page,
      );
    }

    try {
      final result = await _promotionRepository.getAllPromotions(
        page: page,
        pageSize: pageSize,
        keyword: _searchKeyword,
      );

      if (result != null) {
        // Cache the results
        _cachedPromotions[cacheKey] = result.data;
        _lastLoadTime = DateTime.now();

        return PaginationResult<PromotionResponse>(
          data: result.data,
          totalItems: result.meta.total,
          totalPages: result.meta.pages,
          currentPage: result.meta.page,
        );
      }
      return null;
    } catch (e) {
      dev.log('Error when loading promotions list: $e');
      rethrow;
    }
  }

  // Method to load first page
  Future<void> loadFirstPage() {
    return loadData(page: 0);
  }

  // Method to load next page
  Future<void> loadNextPage() {
    return loadMoreData();
  }

  // Update search method
  Future<void> searchPromotions(String query) async {
    if (_searchKeyword == query) {
      return;
    }

    _searchKeyword = query.isNotEmpty ? query : null;
    searchController.text = query;

    // Clear cache on new search
    _cachedPromotions.clear();
    await refresh();
  }

  // Method to clear search
  Future<void> clearSearch() async {
    if (_searchKeyword == null) {
      return;
    }

    _searchKeyword = null;
    searchController.clear();

    // Clear cache when search is cleared
    _cachedPromotions.clear();
    await refresh();
  }

  // Override refreshData to handle clearing cache
  @override
  Future<void> refresh() async {
    _cachedPromotions.clear();
    _lastLoadTime = null;
    super.refresh();
  }

  // Handle when user submits search
  void handleSearchSubmitted(String value) {
    searchPromotions(value);
  }

  // Handle when user clears search
  void handleClearSearch() {
    clearSearch();
  }

  // Handle when scrolling to end
  void handleScrollToEnd() {
    if (!isLoading && hasMoreData) {
      loadMoreData();
    }
  }

  // Handle retry button
  void handleRetry() {
    _cachedPromotions.clear();
    _lastLoadTime = null;
    loadFirstPage();
  }

  // Handle refresh data
  Future<void> handleRefresh() async {
    await refresh();
  }

  // Navigate to add promotion screen
  void navigateToAddPromotion(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addPromotion);
  }

  // Navigate to promotion detail screen
  Future<void> navigateToPromotion(
      BuildContext context, int promotionId) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.promotionDetail,
      arguments: {'id': promotionId},
    );

    // Nếu trả về true, đã có thay đổi, cập nhật lại danh sách
    if (result == true) {
      // Làm mới danh sách để hiển thị thông tin mới nhất
      await refresh();
    }
  }

  // Delete promotion
  Future<bool> deletePromotion(int? promotionId) async {
    if (promotionId == null) {
      _deleteErrorMessage = "Invalid promotion ID";
      notifyListeners();
      return false;
    }

    try {
      _isDeletingPromotion = true;
      _deleteErrorMessage = null;
      notifyListeners();

      // Call API to delete promotion from repository
      await _promotionRepository.deletePromotion(promotionId);

      // If deletion is successful, update local promotion list
      _isDeletingPromotion = false;

      // Update local list
      if (items != null) {
        final updatedItems = List<PromotionResponse>.from(items!)
            .where((promotion) => promotion.id != promotionId)
            .toList();

        // Update list and total count without reloading
        setItems(updatedItems, totalItems - 1);
      }

      notifyListeners();
      return true;
    } catch (e) {
      dev.log('Error when deleting promotion: $e');

      // Handle error
      _isDeletingPromotion = false;

      // Extract error message from Exception
      if (e is Exception) {
        _deleteErrorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        _deleteErrorMessage = e.toString();
      }

      notifyListeners();
      return false;
    }
  }

  // Hiển thị thông báo kết quả xóa
  void showDeleteResult(BuildContext context, bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khuyến mãi thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteErrorMessage ??
              'Không thể xóa khuyến mãi. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Reset delete error message
  void resetDeleteError() {
    _deleteErrorMessage = null;
    notifyListeners();
  }
}
