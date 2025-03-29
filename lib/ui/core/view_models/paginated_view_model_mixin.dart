import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

mixin PaginatedViewModelMixin<T> on ChangeNotifier {
  List<T>? _items;
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;
  bool _hasMoreData = true;
  String? _errorMessage;
  int _totalItems = 0;
  int _totalPages = 0;

  // Prefetching control
  bool _isPrefetching = false;
  int _prefetchThreshold = 3; // Pages to prefetch before reaching the end
  Timer? _loadingDebouncer;
  Timer? _notifyDebouncer;

  // Cache for already loaded pages
  final Map<int, List<T>> _pageCache = {};
  final List<int> _loadedPages = [];
  final int _maxCachedPages = 5; // Maximum number of pages to keep in memory

  List<T>? get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  void setPageSize(int size) {
    if (_pageSize != size) {
      _pageSize = size;
      _clearCache();
      refresh();
    }
  }

  void setPrefetchThreshold(int threshold) {
    _prefetchThreshold = threshold;
  }

  // Clear the cache
  void _clearCache() {
    _pageCache.clear();
    _loadedPages.clear();
  }

  // Method to prefetch next page in the background
  Future<void> prefetchNextPage() async {
    if (_isPrefetching || !_hasMoreData || _currentPage >= _totalPages - 1)
      return;

    final nextPage = _currentPage + 1;

    // Check if already cached
    if (_pageCache.containsKey(nextPage)) return;

    _isPrefetching = true;

    try {
      final result = await fetchData(nextPage, _pageSize);
      if (result != null && result.data.isNotEmpty) {
        // Cache the result for later use
        _cachePageData(nextPage, result.data);
      }
    } catch (e) {
      dev.log('Lỗi khi prefetch dữ liệu: $e');
    } finally {
      _isPrefetching = false;
    }
  }

  // Cache page data and maintain cache size
  void _cachePageData(int page, List<T> data) {
    // Add to cache
    _pageCache[page] = List.from(data);

    if (!_loadedPages.contains(page)) {
      _loadedPages.add(page);
    }

    // Trim cache if it exceeds the maximum size
    while (_loadedPages.length > _maxCachedPages) {
      final oldestPage = _loadedPages.first;
      _loadedPages.removeAt(0);
      _pageCache.remove(oldestPage);
    }
  }

  // Phương thức trừu tượng cần được triển khai bởi các lớp con
  Future<PaginationResult<T>?> fetchData(int page, int pageSize);

  /// Load data with optimized debouncing
  Future<void> loadData({int page = 0}) async {
    // Cancel any existing loading operations
    _loadingDebouncer?.cancel();

    if (_isLoading) return;

    // Check if data is already cached
    if (page > 0 && _pageCache.containsKey(page)) {
      _items = _pageCache[page];
      _currentPage = page;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    // Use debounce for UI updates to avoid too many rebuilds
    _notifyThrottled();

    try {
      final result = await fetchData(page, _pageSize);

      if (result != null) {
        _items = result.data;
        _currentPage = page;
        _totalItems = result.totalItems;
        _totalPages = result.totalPages;
        _hasMoreData = page < (result.totalPages - 1);

        // Cache the results
        _cachePageData(page, result.data);

        // Prefetch next page if needed
        if (_hasMoreData && page < result.totalPages - _prefetchThreshold) {
          Future.microtask(() => prefetchNextPage());
        }
      } else {
        _errorMessage = 'Không thể tải dữ liệu';
      }
    } catch (e) {
      dev.log('Lỗi khi tải dữ liệu: $e');
      _errorMessage = 'Đã xảy ra lỗi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more data with optimized batching
  Future<void> loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    // Cancel any existing loading requests
    _loadingDebouncer?.cancel();

    // Use debouncer to prevent multiple rapid calls
    _loadingDebouncer = Timer(const Duration(milliseconds: 200), () async {
      if (!_hasMoreData) return;

      _isLoading = true;
      _notifyThrottled();

      try {
        final nextPage = _currentPage + 1;

        // Check if next page is already cached
        if (_pageCache.containsKey(nextPage)) {
          final cachedData = _pageCache[nextPage]!;
          _items = [...(_items ?? []), ...cachedData];
          _currentPage = nextPage;

          // Prefetch next pages
          if (_hasMoreData && nextPage < _totalPages - _prefetchThreshold) {
            Future.microtask(() => prefetchNextPage());
          }
        } else {
          // Fetch new data if not cached
          final result = await fetchData(nextPage, _pageSize);

          if (result != null && result.data.isNotEmpty) {
            _items = [...(_items ?? []), ...result.data];
            _currentPage = nextPage;
            _totalItems = result.totalItems;
            _totalPages = result.totalPages;
            _hasMoreData = nextPage < (result.totalPages - 1);

            // Cache the results
            _cachePageData(nextPage, result.data);

            // Prefetch next page if needed
            if (_hasMoreData &&
                nextPage < result.totalPages - _prefetchThreshold) {
              Future.microtask(() => prefetchNextPage());
            }
          } else {
            _hasMoreData = false;
          }
        }
      } catch (e) {
        dev.log('Lỗi khi tải thêm dữ liệu: $e');
        _errorMessage = 'Đã xảy ra lỗi khi tải thêm: $e';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Use throttled notifier to reduce UI rebuilds
  void _notifyThrottled() {
    _notifyDebouncer?.cancel();
    _notifyDebouncer = Timer(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }

  /// Refresh data with cache clearing
  Future<void> refresh() async {
    _currentPage = 0;
    _hasMoreData = true;
    _clearCache();
    await loadData();
  }

  /// Set items manually
  void setItems(List<T> newItems, int newTotalItems) {
    _items = newItems;
    _totalItems = newTotalItems;
    _clearCache(); // Clear cache when items are manually set
    notifyListeners();
  }

  @override
  void dispose() {
    _loadingDebouncer?.cancel();
    _notifyDebouncer?.cancel();
    _clearCache();
    super.dispose();
  }
}

class PaginationResult<T> {
  final List<T> data;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  PaginationResult({
    required this.data,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });
}
