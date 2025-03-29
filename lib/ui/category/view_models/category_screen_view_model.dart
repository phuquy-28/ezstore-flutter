import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:ezstore_flutter/routing/app_routes.dart';

class CategoryScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<Category> {
  final CategoryRepository _categoryRepository;
  String? _searchKeyword;
  bool _isDeletingCategory = false;
  String? _deleteErrorMessage;
  final TextEditingController searchController = TextEditingController();

  // Cache management
  Map<String, List<Category>> _cachedCategories = {};
  final int _cacheTimeInMinutes = 5;
  DateTime? _lastLoadTime;

  CategoryScreenViewModel(this._categoryRepository) {
    setPageSize(10); // Thiết lập kích thước trang
  }

  String? get searchKeyword => _searchKeyword;
  bool get isDeletingCategory => _isDeletingCategory;
  String? get deleteErrorMessage => _deleteErrorMessage;
  int get totalCategories => totalItems;
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
  Future<PaginationResult<Category>?> fetchData(int page, int pageSize) async {
    // Check if this is a search operation
    final isNewSearch =
        _searchKeyword != null && searchController.text != _searchKeyword;

    // Check cache first if not a new search
    final cacheKey = _getCacheKey(page, _searchKeyword);
    if (!isNewSearch &&
        _cachedCategories.containsKey(cacheKey) &&
        _isCacheValid()) {
      final cachedData = _cachedCategories[cacheKey]!;
      return PaginationResult<Category>(
        data: cachedData,
        totalItems: totalItems, // Use existing total
        totalPages: totalPages, // Use existing pages
        currentPage: page,
      );
    }

    try {
      final result = await _categoryRepository.getAllCategories(
        page: page,
        pageSize: pageSize,
        keyword: _searchKeyword,
      );

      if (result != null) {
        // Cache the results
        _cachedCategories[cacheKey] = result.data;
        _lastLoadTime = DateTime.now();

        return PaginationResult<Category>(
          data: result.data,
          totalItems: result.meta.total,
          totalPages: result.meta.pages,
          currentPage: result.meta.page,
        );
      }
      return null;
    } catch (e) {
      dev.log('Lỗi khi tải danh sách danh mục: $e');
      rethrow;
    }
  }

  // Phương thức để bắt đầu tải trang đầu tiên
  Future<void> loadFirstPage() {
    return loadData(page: 0);
  }

  // Phương thức để tải trang tiếp theo
  Future<void> loadNextPage() {
    return loadMoreData();
  }

  // Cập nhật phương thức tìm kiếm danh mục
  Future<void> searchCategories(String query) async {
    if (_searchKeyword == query) {
      return;
    }

    _searchKeyword = query.isNotEmpty ? query : null;
    searchController.text = query;

    // Clear cache on new search
    _cachedCategories.clear();
    await refresh();
  }

  // Phương thức xóa tìm kiếm
  Future<void> clearSearch() async {
    if (_searchKeyword == null) {
      return;
    }

    _searchKeyword = null;
    searchController.clear();

    // Clear cache when search is cleared
    _cachedCategories.clear();
    await refresh();
  }

  // Override refreshData to handle clearing cache
  @override
  Future<void> refresh() async {
    _cachedCategories.clear();
    _lastLoadTime = null;
    super.refresh();
  }

  // Phương thức xử lý khi người dùng submit tìm kiếm
  void handleSearchSubmitted(String value) {
    searchCategories(value);
  }

  // Phương thức xử lý khi người dùng xóa tìm kiếm
  void handleClearSearch() {
    clearSearch();
  }

  // Phương thức xử lý khi scroll đến cuối
  void handleScrollToEnd() {
    if (!isLoading && hasMoreData) {
      loadMoreData();
    }
  }

  // Phương thức xử lý khi nhấn nút thử lại
  void handleRetry() {
    _cachedCategories.clear();
    _lastLoadTime = null;
    loadFirstPage();
  }

  // Phương thức xử lý khi cần refresh dữ liệu
  Future<void> handleRefresh() async {
    await refresh();
  }

  // Phương thức chuyển đến màn hình thêm danh mục
  void navigateToAddCategory(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addCategory);
  }

  // Phương thức chuyển đến màn hình chi tiết danh mục
  void navigateToCategory(BuildContext context, int categoryId) {
    Navigator.pushNamed(
      context,
      AppRoutes.categoryDetail,
      arguments: {'id': categoryId},
    );
  }

  // Phương thức xóa danh mục
  Future<bool> deleteCategory(int? categoryId) async {
    if (categoryId == null) {
      _deleteErrorMessage = "ID danh mục không hợp lệ";
      notifyListeners();
      return false;
    }

    try {
      _isDeletingCategory = true;
      _deleteErrorMessage = null;
      notifyListeners();

      // Gọi API xóa danh mục từ repository
      await _categoryRepository.deleteCategory(categoryId);

      // Nếu xóa thành công, cập nhật lại danh sách danh mục cục bộ
      _isDeletingCategory = false;

      // Cập nhật danh sách cục bộ
      if (items != null) {
        final updatedItems = List<Category>.from(items!)
            .where((category) => category.id != categoryId)
            .toList();

        // Cập nhật danh sách và số lượng tổng mà không tải lại
        setItems(updatedItems, totalItems - 1);
      }

      notifyListeners();
      return true;
    } catch (e) {
      dev.log('Lỗi khi xóa danh mục: $e');

      // Xử lý lỗi
      _isDeletingCategory = false;

      // Trích xuất thông báo lỗi từ Exception
      if (e is Exception) {
        _deleteErrorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        _deleteErrorMessage = e.toString();
      }

      notifyListeners();
      return false;
    }
  }

  // Hiển thị thông báo kết quả xóa danh mục
  void showDeleteResult(BuildContext context, bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa danh mục thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteErrorMessage ??
              'Không thể xóa danh mục. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Đặt lại thông báo lỗi xóa
  void resetDeleteError() {
    _deleteErrorMessage = null;
    notifyListeners();
  }
}
