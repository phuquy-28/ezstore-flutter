import 'package:flutter/foundation.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/data/repositories/promotion_repository.dart';
import 'package:ezstore_flutter/data/models/promotion/req_promotion.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart' as models;
import 'package:ezstore_flutter/domain/models/product/product_response.dart';
import 'package:intl/intl.dart';

class EditPromotionViewModel extends ChangeNotifier {
  final PromotionRepository _promotionRepository;
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Form fields
  int? _id;
  String _name = '';
  String _description = '';
  int _discountRate = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  // Categories
  bool _isLoadingCategories = false;
  List<models.Category> _categories = [];
  List<int> _selectedCategoryIds = [];
  int _categoryPage = 0;
  bool _hasMoreCategories = true;

  // Products
  bool _isLoadingProducts = false;
  List<ProductResponse> _products = [];
  List<int> _selectedProductIds = [];
  int _productPage = 0;
  bool _hasMoreProducts = true;
  String _productSearchKeyword = '';

  // Validation errors
  String? _nameErrorText;
  String? _discountRateErrorText;
  String? _dateRangeErrorText;
  String? _selectionErrorText;

  // Biến theo dõi trạng thái đã tải dữ liệu chưa
  bool _isInitialized = false;

  // Constructor
  EditPromotionViewModel(
    this._promotionRepository,
    this._categoryRepository,
    this._productRepository,
  );

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get name => _name;
  String get description => _description;
  int get discountRate => _discountRate;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isInitialized => _isInitialized;

  List<models.Category> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  List<int> get selectedCategoryIds => _selectedCategoryIds;
  bool get hasMoreCategories => _hasMoreCategories;

  List<ProductResponse> get products => _products;
  bool get isLoadingProducts => _isLoadingProducts;
  List<int> get selectedProductIds => _selectedProductIds;
  bool get hasMoreProducts => _hasMoreProducts;

  String? get nameErrorText => _nameErrorText;
  String? get discountRateErrorText => _discountRateErrorText;
  String? get dateRangeErrorText => _dateRangeErrorText;
  String? get selectionErrorText => _selectionErrorText;

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date for API requests (ISO 8601 format with UTC timezone)
  String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Tải thông tin khuyến mãi từ ID
  Future<void> loadPromotionById(int promotionId) async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final promotion =
          await _promotionRepository.getPromotionById(promotionId);

      if (promotion != null) {
        _id = promotion.id;
        _name = promotion.name ?? '';
        _description = promotion.description ?? '';
        _discountRate = promotion.discountRate?.toInt() ?? 0;

        if (promotion.startDate != null) {
          _startDate = DateTime.parse(promotion.startDate!);
        }

        if (promotion.endDate != null) {
          _endDate = DateTime.parse(promotion.endDate!);
        }

        // Tải và chuẩn bị danh sách sản phẩm và danh mục đã chọn
        await _loadInitialData();

        // Thiết lập danh sách đã chọn
        if (promotion.categories != null) {
          _selectedCategoryIds = promotion.categories!
              .where((c) => c.id != null)
              .map((c) => c.id!)
              .toList();
        }

        if (promotion.products != null) {
          _selectedProductIds = promotion.products!
              .where((p) => p.id != null)
              .map((p) => p.id!)
              .toList();
        }

        _isInitialized = true;
      } else {
        _errorMessage = 'Không tìm thấy thông tin khuyến mãi';
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi tải thông tin khuyến mãi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tải dữ liệu ban đầu
  Future<void> _loadInitialData() async {
    await loadCategories(refresh: true);
    await loadProducts(refresh: true);
  }

  // Update methods
  void updateName(String value) {
    _name = value;
    validateName();
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateDiscountRate(String value) {
    if (value.isNotEmpty) {
      _discountRate = int.tryParse(value) ?? 0;
    } else {
      _discountRate = 0;
    }
    validateDiscountRate();
    notifyListeners();
  }

  void updateStartDate(DateTime? date) {
    _startDate = date;
    validateDateRange();
    notifyListeners();
  }

  void updateEndDate(DateTime? date) {
    _endDate = date;
    validateDateRange();
    notifyListeners();
  }

  // Toggle category selection
  void toggleCategorySelection(int categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId);
    }
    validateSelection();
    notifyListeners();
  }

  // Toggle product selection
  void toggleProductSelection(int productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }
    validateSelection();
    notifyListeners();
  }

  // Load categories with pagination
  Future<void> loadCategories({bool refresh = false}) async {
    if (refresh) {
      _categoryPage = 0;
      _categories = [];
      _hasMoreCategories = true;
    }

    if (!_hasMoreCategories || _isLoadingCategories) return;

    _isLoadingCategories = true;
    notifyListeners();

    try {
      final result = await _categoryRepository.getAllCategories(
        page: _categoryPage,
        pageSize: 10,
      );

      if (result != null) {
        if (result.data.isEmpty) {
          _hasMoreCategories = false;
        } else {
          _categories.addAll(result.data);
          _categoryPage++;
        }
      }
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách danh mục: $e';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Search and load products with pagination
  Future<void> loadProducts({bool refresh = false, String? keyword}) async {
    if (refresh) {
      _productPage = 0;
      _products = [];
      _hasMoreProducts = true;
      if (keyword != null) {
        _productSearchKeyword = keyword;
      }
    }

    if (!_hasMoreProducts || _isLoadingProducts) return;

    _isLoadingProducts = true;
    notifyListeners();

    try {
      final result = await _productRepository.getAllProducts(
        page: _productPage,
        pageSize: 10,
        keyword: _productSearchKeyword,
      );

      if (result != null) {
        if (result.data.isEmpty) {
          _hasMoreProducts = false;
        } else {
          _products.addAll(result.data);
          _productPage++;
        }
      }
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách sản phẩm: $e';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // Validation methods
  void validateName() {
    if (_name.isEmpty) {
      _nameErrorText = 'Vui lòng nhập tên khuyến mãi';
    } else if (_name.length < 3) {
      _nameErrorText = 'Tên khuyến mãi quá ngắn (tối thiểu 3 ký tự)';
    } else if (_name.length > 100) {
      _nameErrorText = 'Tên khuyến mãi quá dài (tối đa 100 ký tự)';
    } else {
      _nameErrorText = null;
    }
  }

  void validateDiscountRate() {
    if (_discountRate <= 0) {
      _discountRateErrorText = 'Giảm giá phải lớn hơn 0%';
    } else if (_discountRate > 100) {
      _discountRateErrorText = 'Giảm giá không thể vượt quá 100%';
    } else {
      _discountRateErrorText = null;
    }
  }

  void validateDateRange() {
    if (_startDate == null) {
      _dateRangeErrorText = 'Vui lòng chọn ngày bắt đầu';
    } else if (_endDate == null) {
      _dateRangeErrorText = 'Vui lòng chọn ngày kết thúc';
    } else if (_endDate!.isBefore(_startDate!)) {
      _dateRangeErrorText = 'Ngày kết thúc phải sau ngày bắt đầu';
    } else {
      _dateRangeErrorText = null;
    }
  }

  void validateSelection() {
    if (_selectedCategoryIds.isEmpty && _selectedProductIds.isEmpty) {
      _selectionErrorText = 'Vui lòng chọn ít nhất một danh mục hoặc sản phẩm';
    } else {
      _selectionErrorText = null;
    }
  }

  bool validateAll() {
    validateName();
    validateDiscountRate();
    validateDateRange();
    validateSelection();

    return _nameErrorText == null &&
        _discountRateErrorText == null &&
        _dateRangeErrorText == null &&
        _selectionErrorText == null;
  }

  // Update promotion
  Future<bool> updatePromotion() async {
    if (!validateAll()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final reqPromotion = ReqPromotion(
        id: _id,
        name: _name,
        description: _description,
        discountRate: _discountRate,
        startDate: formatDateForApi(_startDate!),
        endDate: formatDateForApi(_endDate!),
        categoryIds:
            _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
        productIds: _selectedProductIds.isNotEmpty ? _selectedProductIds : null,
      );

      final result = await _promotionRepository.updatePromotion(reqPromotion);

      if (result != null) {
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Không thể cập nhật khuyến mãi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset validation state
  void resetValidation() {
    _nameErrorText = null;
    _discountRateErrorText = null;
    _dateRangeErrorText = null;
    _selectionErrorText = null;
    notifyListeners();
  }
}
