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

  List<T>? get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  void setPageSize(int size) {
    _pageSize = size;
  }

  // Phương thức trừu tượng cần được triển khai bởi các lớp con
  Future<PaginationResult<T>?> fetchData(int page, int pageSize);

  Future<void> loadData({int page = 0}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await fetchData(page, _pageSize);

      if (result != null) {
        _items = result.data;
        _currentPage = page;
        _totalItems = result.totalItems;
        _totalPages = result.totalPages;
        _hasMoreData = page < (result.totalPages - 1);
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

  Future<void> loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await fetchData(nextPage, _pageSize);

      if (result != null && result.data.isNotEmpty) {
        // Thêm dữ liệu mới vào danh sách hiện tại
        _items = [...(_items ?? []), ...result.data];
        _currentPage = nextPage;
        _totalItems = result.totalItems;
        _totalPages = result.totalPages;
        _hasMoreData = nextPage < (result.totalPages - 1);
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      dev.log('Lỗi khi tải thêm dữ liệu: $e');
      _errorMessage = 'Đã xảy ra lỗi khi tải thêm: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    _hasMoreData = true;
    await loadData();
  }

  void setItems(List<T> newItems, int newTotalItems) {
    _items = newItems;
    _totalItems = newTotalItems;
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
