import 'package:ezstore_flutter/domain/models/product/product_response.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ProductScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<ProductResponse> {
  final ProductRepository _productRepository;
  String? _searchKeyword;
  String? _lastAppliedSearchKeyword;
  bool _isSearching = false;
  String? _deleteErrorMessage;
  Map<String, List<ProductResponse>> _cachedProducts = {};
  final int _cacheTimeInMinutes = 5;
  DateTime? _lastLoadTime;
  final TextEditingController searchController = TextEditingController();

  ProductScreenViewModel(this._productRepository) {
    setPageSize(10); // Thiết lập kích thước trang
  }

  String? get searchKeyword => _searchKeyword;
  int get totalProducts => totalItems;
  String? get error => errorMessage;
  bool get hasMorePages => hasMoreData;
  bool get isSearching => _isSearching;
  String? get deleteErrorMessage => _deleteErrorMessage;

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
  Future<PaginationResult<ProductResponse>?> fetchData(
      int page, int pageSize) async {
    // Check if this is a search operation
    final isNewSearch = _searchKeyword != _lastAppliedSearchKeyword;
    if (isNewSearch) {
      _lastAppliedSearchKeyword = _searchKeyword;
      // Clear cache on new search
      _cachedProducts.clear();
    }

    // Check cache first if not a new search
    final cacheKey = _getCacheKey(page, _searchKeyword);
    if (!isNewSearch &&
        _cachedProducts.containsKey(cacheKey) &&
        _isCacheValid()) {
      final cachedData = _cachedProducts[cacheKey]!;
      return PaginationResult<ProductResponse>(
        data: cachedData,
        totalItems: totalItems, // Use existing total
        totalPages: totalPages, // Use existing pages
        currentPage: page,
      );
    }

    try {
      // Set searching state
      if (_searchKeyword != null) {
        _isSearching = true;
        notifyListeners();
      }

      final result = await _productRepository.getAllProducts(
        page: page,
        pageSize: pageSize,
        keyword: _searchKeyword,
      );

      // Reset searching state
      _isSearching = false;

      if (result != null) {
        // Cache the results
        _cachedProducts[cacheKey] = result.data;
        _lastLoadTime = DateTime.now();

        return PaginationResult<ProductResponse>(
          data: result.data,
          totalItems: result.meta.total,
          totalPages: result.meta.pages,
          currentPage: result.meta.page,
        );
      }
      return null;
    } catch (e) {
      _isSearching = false;
      dev.log('Lỗi khi tải danh sách sản phẩm: $e');
      throw Exception('Không thể tải danh sách sản phẩm: $e');
    }
  }

  Future<void> searchProducts(String keyword) async {
    // Only trigger search if keyword actually changed
    if (_searchKeyword == keyword && _lastAppliedSearchKeyword == keyword) {
      return;
    }

    _searchKeyword = keyword.isNotEmpty ? keyword : null;
    searchController.text = keyword;
    await refresh();
  }

  void clearSearch() {
    // Only refresh if we were actually searching
    if (_searchKeyword != null) {
      _searchKeyword = null;
      _lastAppliedSearchKeyword = null;
      searchController.clear();
      _cachedProducts.clear();
      refresh();
    }
  }

  List<ProductResponse> getFilteredProducts() {
    return items ?? [];
  }

  // Phương thức để bắt đầu tải trang đầu tiên
  Future<void> loadFirstPage() {
    return loadData(page: 0);
  }

  // Phương thức để tải trang tiếp theo
  Future<void> loadNextPage() {
    return loadMoreData();
  }

  // Override refreshData to handle clearing cache
  @override
  Future<void> refresh() async {
    _cachedProducts.clear();
    _lastLoadTime = null;
    super.refresh();
  }

  // Phương thức xử lý khi người dùng submit tìm kiếm
  void handleSearchSubmitted(String value) {
    searchProducts(value);
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
    _cachedProducts.clear();
    _lastLoadTime = null;
    loadFirstPage();
  }

  // Phương thức xử lý khi cần refresh dữ liệu
  Future<void> handleRefresh() async {
    await refresh();
  }

  // Phương thức chuyển đến màn hình thêm sản phẩm
  void navigateToAddProduct(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addProduct);
  }

  // Phương thức chuyển đến màn hình chi tiết sản phẩm
  void navigateToProductDetail(BuildContext context, int productId) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: {'id': productId},
    );
  }

  Future<bool> deleteProduct(int productId) async {
    bool isCurrentlyLoading = isLoading;
    _deleteErrorMessage = null;

    try {
      // Đánh dấu đang tải
      if (!isCurrentlyLoading) {
        // isLoading là getter từ mixin, nên không thể gán trực tiếp
        // Thay vào đó sử dụng biến tạm và notifyListeners thủ công
        notifyListeners(); // Thông báo bắt đầu tải
      }

      // Gọi API xóa sản phẩm từ repository
      await _productRepository.deleteProduct(productId);

      // Cập nhật danh sách sản phẩm sau khi xóa
      if (items != null) {
        final updatedItems =
            items!.where((product) => product.id != productId).toList();
        setItems(updatedItems, totalItems - 1);

        // Clear relevant cache entries
        _cachedProducts.clear();
      }

      if (!isCurrentlyLoading) {
        notifyListeners(); // Thông báo kết thúc tải
      }
      return true;
    } catch (e) {
      dev.log('Lỗi khi xóa sản phẩm: $e');

      // Trích xuất thông báo lỗi từ Exception
      if (e is Exception) {
        _deleteErrorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        _deleteErrorMessage = e.toString();
      }

      if (!isCurrentlyLoading) {
        notifyListeners();
      }
      return false;
    }
  }

  // Hiển thị thông báo kết quả xóa sản phẩm
  void showDeleteResult(BuildContext context, bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa sản phẩm thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteErrorMessage ??
              'Không thể xóa sản phẩm. Vui lòng thử lại sau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
