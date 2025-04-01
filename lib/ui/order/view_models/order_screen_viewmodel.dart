import 'package:ezstore_flutter/domain/models/order/order_response.dart';
import 'package:ezstore_flutter/data/repositories/order_repository.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:ezstore_flutter/config/translations.dart';
import 'package:ezstore_flutter/ui/order/widgets/filter_order.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class OrderScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<OrderResponse> {
  final OrderRepository _orderRepository;
  String? _searchKeyword;
  String? _lastAppliedSearchKeyword;
  bool _isSearching = false;
  Map<String, List<OrderResponse>> _cachedOrders = {};
  final int _cacheTimeInMinutes = 5;
  DateTime? _lastLoadTime;
  final TextEditingController searchController = TextEditingController();

  // Filter states - these will store the English versions for API filtering
  String? _paymentStatusFilter;
  String? _orderStatusFilter;
  String? _paymentMethodFilter;
  String? _deliveryMethodFilter;

  OrderScreenViewModel(this._orderRepository) {
    setPageSize(10); // Set default page size
  }

  String? get searchKeyword => _searchKeyword;
  int get totalOrders => totalItems;
  String? get error => errorMessage;
  bool get hasMorePages => hasMoreData;
  bool get isSearching => _isSearching;

  // These getters will return Vietnamese translations for display
  String? get paymentStatusFilter => _paymentStatusFilter != null
      ? PaymentStatusTranslations.getStatusName(_paymentStatusFilter)
      : null;

  String? get orderStatusFilter => _orderStatusFilter != null
      ? OrderStatusTranslations.getStatusName(_orderStatusFilter)
      : null;

  String? get paymentMethodFilter => _paymentMethodFilter != null
      ? PaymentMethodTranslations.getMethodName(_paymentMethodFilter)
      : null;

  String? get deliveryMethodFilter => _deliveryMethodFilter != null
      ? DeliveryMethodTranslations.getMethodName(_deliveryMethodFilter)
      : null;

  bool get hasActiveFilters =>
      _paymentStatusFilter != null ||
      _orderStatusFilter != null ||
      _paymentMethodFilter != null ||
      _deliveryMethodFilter != null;

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
    return 'page_${page}_keyword_${keyword ?? "all"}_paymentStatus_${_paymentStatusFilter ?? "all"}_orderStatus_${_orderStatusFilter ?? "all"}_paymentMethod_${_paymentMethodFilter ?? "all"}_deliveryMethod_${_deliveryMethodFilter ?? "all"}';
  }

  // Check if cache is still valid
  bool _isCacheValid() {
    if (_lastLoadTime == null) return false;
    final difference = DateTime.now().difference(_lastLoadTime!);
    return difference.inMinutes < _cacheTimeInMinutes;
  }

  @override
  Future<PaginationResult<OrderResponse>?> fetchData(
      int page, int pageSize) async {
    // Check if this is a search operation
    final isNewSearch = _searchKeyword != _lastAppliedSearchKeyword;
    if (isNewSearch) {
      _lastAppliedSearchKeyword = _searchKeyword;
      // Clear cache on new search
      _cachedOrders.clear();
    }

    // Check cache first if not a new search
    final cacheKey = _getCacheKey(page, _searchKeyword);
    if (!isNewSearch &&
        _cachedOrders.containsKey(cacheKey) &&
        _isCacheValid()) {
      final cachedData = _cachedOrders[cacheKey]!;
      return PaginationResult<OrderResponse>(
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

      // Pass filter parameters to the repository
      final result = await _orderRepository.getAllOrders(
        page: page,
        pageSize: pageSize,
        keyword: _searchKeyword,
        paymentStatus: _paymentStatusFilter,
        orderStatus: _orderStatusFilter,
        paymentMethod: _paymentMethodFilter,
        deliveryMethod: _deliveryMethodFilter,
      );

      // Reset searching state
      _isSearching = false;

      if (result != null) {
        // Cache the results
        _cachedOrders[cacheKey] = result.data;
        _lastLoadTime = DateTime.now();

        return PaginationResult<OrderResponse>(
          data: result.data,
          totalItems: result.meta.total,
          totalPages: result.meta.pages,
          currentPage: result.meta.page,
        );
      }
      return null;
    } catch (e) {
      _isSearching = false;
      dev.log('Error loading order list: $e');
      throw Exception('Unable to load orders: $e');
    }
  }

  Future<void> searchOrders(String keyword) async {
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
      _cachedOrders.clear();
      refresh();
    }
  }

  // Filter methods - always store the English version for API filtering
  void setPaymentStatusFilter(String? status) {
    // Convert from Vietnamese display name to English API value
    String? apiStatus = null;
    if (status != null) {
      // Find the English key for the Vietnamese status name
      for (var entry in PaymentStatusTranslations.statusNames.entries) {
        if (entry.value == status) {
          apiStatus = entry.key;
          break;
        }
      }
    }

    if (_paymentStatusFilter != apiStatus) {
      _paymentStatusFilter = apiStatus;
      _cachedOrders.clear();
      refresh();
    }
  }

  void setOrderStatusFilter(String? status) {
    // Convert from Vietnamese display name to English API value
    String? apiStatus = null;
    if (status != null) {
      // Find the English key for the Vietnamese status name
      for (var entry in OrderStatusTranslations.statusNames.entries) {
        if (entry.value == status) {
          apiStatus = entry.key;
          break;
        }
      }
    }

    if (_orderStatusFilter != apiStatus) {
      _orderStatusFilter = apiStatus;
      _cachedOrders.clear();
      refresh();
    }
  }

  void setPaymentMethodFilter(String? method) {
    // Convert from Vietnamese display name to English API value
    String? apiMethod = null;
    if (method != null) {
      // Find the English key for the Vietnamese method name
      for (var entry in PaymentMethodTranslations.methodNames.entries) {
        if (entry.value == method) {
          apiMethod = entry.key;
          break;
        }
      }
    }

    if (_paymentMethodFilter != apiMethod) {
      _paymentMethodFilter = apiMethod;
      _cachedOrders.clear();
      refresh();
    }
  }

  void setDeliveryMethodFilter(String? method) {
    // Convert from Vietnamese display name to English API value
    String? apiMethod = null;
    if (method != null) {
      // Find the English key for the Vietnamese method name
      for (var entry in DeliveryMethodTranslations.methodNames.entries) {
        if (entry.value == method) {
          apiMethod = entry.key;
          break;
        }
      }
    }

    if (_deliveryMethodFilter != apiMethod) {
      _deliveryMethodFilter = apiMethod;
      _cachedOrders.clear();
      refresh();
    }
  }

  void clearFilters() {
    bool hasFilters = _paymentStatusFilter != null ||
        _orderStatusFilter != null ||
        _paymentMethodFilter != null ||
        _deliveryMethodFilter != null;

    if (hasFilters) {
      _paymentStatusFilter = null;
      _orderStatusFilter = null;
      _paymentMethodFilter = null;
      _deliveryMethodFilter = null;
      _cachedOrders.clear();
      refresh();
    }
  }

  List<OrderResponse> getFilteredOrders() {
    if (items == null) return [];

    var filteredItems = List<OrderResponse>.from(items!);

    // Apply additional in-memory filtering if needed
    if (_paymentStatusFilter != null) {
      filteredItems = filteredItems
          .where((order) =>
              order.paymentStatus?.toUpperCase() == _paymentStatusFilter)
          .toList();
    }

    if (_orderStatusFilter != null) {
      filteredItems = filteredItems
          .where(
              (order) => order.orderStatus?.toUpperCase() == _orderStatusFilter)
          .toList();
    }

    if (_paymentMethodFilter != null) {
      filteredItems = filteredItems
          .where((order) =>
              order.paymentMethod?.toUpperCase() == _paymentMethodFilter)
          .toList();
    }

    if (_deliveryMethodFilter != null) {
      filteredItems = filteredItems
          .where((order) =>
              order.deliveryMethod?.toUpperCase() == _deliveryMethodFilter)
          .toList();
    }

    return filteredItems;
  }

  // Method to start loading the first page
  Future<void> loadFirstPage() {
    return loadData(page: 0);
  }

  // Method to load the next page
  Future<void> loadNextPage() {
    return loadMoreData();
  }

  // Override refreshData to handle clearing cache
  @override
  Future<void> refresh() async {
    _cachedOrders.clear();
    _lastLoadTime = null;
    super.refresh();
  }

  // Handle search submission
  void handleSearchSubmitted(String value) {
    searchOrders(value);
  }

  // Handle search clearing
  void handleClearSearch() {
    clearSearch();
  }

  // Handle scrolling to the end
  void handleScrollToEnd() {
    if (!isLoading && hasMoreData) {
      loadMoreData();
    }
  }

  // Handle retry button press
  void handleRetry() {
    _cachedOrders.clear();
    _lastLoadTime = null;
    loadFirstPage();
  }

  // Handle refresh request
  Future<void> handleRefresh() async {
    await refresh();
  }

  // Show filter options
  void showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterOrder(viewModel: this);
      },
    );
  }
}
