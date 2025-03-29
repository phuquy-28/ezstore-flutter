import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart' as models;
import 'package:flutter/material.dart';

// Class để lưu thông tin chi tiết của mỗi kích thước trong một biến thể
class VariantDetail {
  String size;
  int quantity;
  double priceDifference;

  VariantDetail({
    this.size = 'S',
    this.quantity = 0,
    this.priceDifference = 0,
  });

  // Validate the variant detail and return error messages
  Map<String, String?> validate() {
    final errors = <String, String?>{};

    if (quantity <= 0) {
      errors['quantity'] = 'Số lượng phải lớn hơn 0';
    }

    return errors;
  }
}

class ProductVariant {
  String color;
  List<VariantDetail> sizeDetails;
  File? variantImage;

  ProductVariant({
    this.color = 'BLACK',
    List<VariantDetail>? sizeDetails,
    this.variantImage,
  }) : sizeDetails = sizeDetails ?? [VariantDetail()];

  // Validate the variant and return error messages
  Map<String, String?> validate({bool requireImage = false}) {
    final errors = <String, String?>{};

    if (sizeDetails.isEmpty) {
      errors['sizeDetails'] = 'Cần ít nhất một kích thước cho biến thể';
    }

    if (requireImage && variantImage == null) {
      errors['image'] = 'Vui lòng chọn hình ảnh biến thể';
    }

    return errors;
  }
}

class AddProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductVariant> _variants = [ProductVariant()]; // Default one variant
  Map<int, Map<String, String?>> _variantErrors = {};
  Map<int, Map<int, Map<String, String?>>> _variantDetailErrors =
      {}; // New errors for variant details
  bool _shouldValidateVariants = false;

  // Danh sách danh mục
  List<models.Category> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesErrorMessage;

  // Form validation flags and errors
  String? _imagesErrorText;
  String? _categoryErrorText;
  String? _nameErrorText;
  String? _priceErrorText;
  String? _descriptionErrorText;

  // Product fields
  String _name = '';
  String _description = '';
  String _category = '';
  int _categoryId = 0;
  double _price = 0;
  bool _isFeatured = false;
  List<File> _productImages = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductVariant> get variants => _variants;
  Map<int, Map<String, String?>> get variantErrors => _variantErrors;
  Map<int, Map<int, Map<String, String?>>> get variantDetailErrors =>
      _variantDetailErrors;
  bool get shouldValidateVariants => _shouldValidateVariants;

  // Getters cho danh mục
  List<models.Category> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesErrorMessage => _categoriesErrorMessage;

  // Form errors getters
  String? get imagesErrorText => _imagesErrorText;
  String? get categoryErrorText => _categoryErrorText;
  String? get nameErrorText => _nameErrorText;
  String? get priceErrorText => _priceErrorText;
  String? get descriptionErrorText => _descriptionErrorText;

  // Product fields getters
  String get name => _name;
  String get description => _description;
  String get category => _category;
  double get price => _price;
  bool get isFeatured => _isFeatured;
  List<File> get productImages => _productImages;

  // Constructor with repository dependency
  AddProductViewModel(this._productRepository, this._categoryRepository);

  // Phương thức để tải danh sách danh mục
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    try {
      // Tải danh sách danh mục với kích thước lớn để lấy tất cả
      final result = await _categoryRepository.getAllCategories(
        page: 0,
        pageSize: 100, // Kích thước lớn để lấy tất cả danh mục
      );

      if (result != null) {
        _categories = result.data;

        // Nếu đã có danh mục và chưa chọn danh mục nào, chọn danh mục đầu tiên
        if (_categories.isNotEmpty && _category.isEmpty) {
          _category = _categories.first.name ?? '';
          _categoryId = _categories.first.id!;
        }
      } else {
        _categoriesErrorMessage = 'Không thể tải danh sách danh mục';
      }
    } catch (e) {
      _categoriesErrorMessage = 'Lỗi khi tải danh sách danh mục: $e';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Update methods for product fields
  void updateName(String value) {
    _name = value;
    if (_shouldValidateVariants) {
      validateName();
    }
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    if (_shouldValidateVariants) {
      validateDescription();
    }
    notifyListeners();
  }

  void updateCategory(String value) {
    _category = value;

    // Tìm categoryId từ danh sách categories đã tải
    if (_categories.isNotEmpty) {
      final selectedCategory = _categories.firstWhere(
        (category) => category.name == value,
        orElse: () => models.Category(id: 0, name: value),
      );
      _categoryId = selectedCategory.id ?? 0;
    } else {
      // Fallback nếu không tìm thấy danh mục
      final Map<String, int> categoryMap = {
        'Áo Cardigan & Áo len': 1,
        'Áo khoác & Áo khoác dài': 2,
        'Áo phông': 3,
        'Quần jean': 4,
        'Đầm': 5,
      };
      _categoryId = categoryMap[value] ?? 0;
    }

    _categoryErrorText = null;
    notifyListeners();
  }

  void updatePrice(String value) {
    if (value.isNotEmpty) {
      _price = double.tryParse(value) ?? 0;
    } else {
      _price = 0;
    }
    if (_shouldValidateVariants) {
      validatePrice();
    }
    notifyListeners();
  }

  void updateFeatured(bool value) {
    _isFeatured = value;
    notifyListeners();
  }

  void updateProductImages(List<File> images) {
    _productImages = images;
    _imagesErrorText = null;
    notifyListeners();
  }

  // Methods for variant management
  void addVariant() {
    _variants.add(ProductVariant());
    notifyListeners();
  }

  void removeVariant(int index) {
    if (index >= 0 && index < _variants.length) {
      _variants.removeAt(index);
      _variantErrors.remove(index);
      _variantDetailErrors.remove(index);

      // Rebuild the variant errors map with new indices
      final newErrorMap = <int, Map<String, String?>>{};
      _variantErrors.forEach((oldIndex, errorMap) {
        if (oldIndex > index) {
          newErrorMap[oldIndex - 1] = errorMap;
        } else if (oldIndex < index) {
          newErrorMap[oldIndex] = errorMap;
        }
      });
      _variantErrors = newErrorMap;

      // Rebuild the variant detail errors map with new indices
      final newDetailErrorMap = <int, Map<int, Map<String, String?>>>{};
      _variantDetailErrors.forEach((oldIndex, detailErrorMap) {
        if (oldIndex > index) {
          newDetailErrorMap[oldIndex - 1] = detailErrorMap;
        } else if (oldIndex < index) {
          newDetailErrorMap[oldIndex] = detailErrorMap;
        }
      });
      _variantDetailErrors = newDetailErrorMap;

      notifyListeners();
    }
  }

  void updateVariant(int index, ProductVariant variant) {
    if (index >= 0 && index < _variants.length) {
      _variants[index] = variant;

      // If we are validating, update the validation state
      if (_shouldValidateVariants) {
        validateVariant(index);
      }

      notifyListeners();
    }
  }

  // Phương thức để thêm chi tiết kích thước vào một biến thể
  void addSizeDetail(int variantIndex) {
    if (variantIndex >= 0 && variantIndex < _variants.length) {
      _variants[variantIndex].sizeDetails.add(VariantDetail());
      notifyListeners();
    }
  }

  // Phương thức để xóa chi tiết kích thước từ một biến thể
  void removeSizeDetail(int variantIndex, int detailIndex) {
    if (variantIndex >= 0 && variantIndex < _variants.length) {
      if (detailIndex >= 0 &&
          detailIndex < _variants[variantIndex].sizeDetails.length) {
        _variants[variantIndex].sizeDetails.removeAt(detailIndex);

        // Xóa lỗi tương ứng nếu có
        if (_variantDetailErrors.containsKey(variantIndex)) {
          _variantDetailErrors[variantIndex]?.remove(detailIndex);

          // Rebuild the size detail errors map with new indices
          if (_variantDetailErrors[variantIndex] != null) {
            final newSizeDetailErrorMap = <int, Map<String, String?>>{};
            _variantDetailErrors[variantIndex]!.forEach((oldIndex, errorMap) {
              if (oldIndex > detailIndex) {
                newSizeDetailErrorMap[oldIndex - 1] = errorMap;
              } else if (oldIndex < detailIndex) {
                newSizeDetailErrorMap[oldIndex] = errorMap;
              }
            });
            _variantDetailErrors[variantIndex] = newSizeDetailErrorMap;
          }
        }

        notifyListeners();
      }
    }
  }

  // Phương thức để cập nhật chi tiết kích thước trong một biến thể
  void updateSizeDetail(
      int variantIndex, int detailIndex, VariantDetail detail) {
    if (variantIndex >= 0 && variantIndex < _variants.length) {
      if (detailIndex >= 0 &&
          detailIndex < _variants[variantIndex].sizeDetails.length) {
        _variants[variantIndex].sizeDetails[detailIndex] = detail;

        // If we are validating, update the validation state
        if (_shouldValidateVariants) {
          validateSizeDetail(variantIndex, detailIndex);
        }

        notifyListeners();
      }
    }
  }

  // Validation methods
  void validateName() {
    if (_name.isEmpty) {
      _nameErrorText = 'Vui lòng nhập tên sản phẩm';
    } else if (_name.length < 3) {
      _nameErrorText = 'Tên sản phẩm quá ngắn (tối thiểu 3 ký tự)';
    } else if (_name.length > 100) {
      _nameErrorText = 'Tên sản phẩm quá dài (tối đa 100 ký tự)';
    } else {
      _nameErrorText = null;
    }
    notifyListeners();
  }

  void validateDescription() {
    if (_description.isEmpty) {
      _descriptionErrorText = 'Vui lòng nhập mô tả sản phẩm';
    } else if (_description.length < 10) {
      _descriptionErrorText = 'Mô tả quá ngắn (tối thiểu 10 ký tự)';
    } else if (_description.length > 1000) {
      _descriptionErrorText = 'Mô tả quá dài (tối đa 1000 ký tự)';
    } else {
      _descriptionErrorText = null;
    }
    notifyListeners();
  }

  void validatePrice() {
    if (_price <= 0) {
      _priceErrorText = 'Giá phải lớn hơn 0';
    } else {
      _priceErrorText = null;
    }
    notifyListeners();
  }

  void validateProductImages() {
    if (_productImages.isEmpty) {
      _imagesErrorText = 'Vui lòng chọn ít nhất một hình ảnh cho sản phẩm';
    } else {
      _imagesErrorText = null;
    }
    notifyListeners();
  }

  void validateCategory() {
    if (_category.isEmpty) {
      _categoryErrorText = 'Vui lòng chọn danh mục sản phẩm';
    } else if (_categoryId == 0) {
      _categoryErrorText = 'Danh mục không hợp lệ';
    } else {
      _categoryErrorText = null;
    }
    notifyListeners();
  }

  void validateVariant(int index) {
    if (index >= 0 && index < _variants.length) {
      final errors = _variants[index].validate(requireImage: true);
      _variantErrors[index] = errors;

      // Validate each size detail
      if (!_variantDetailErrors.containsKey(index)) {
        _variantDetailErrors[index] = {};
      }

      for (int i = 0; i < _variants[index].sizeDetails.length; i++) {
        validateSizeDetail(index, i);
      }
    }
    notifyListeners();
  }

  void validateSizeDetail(int variantIndex, int detailIndex) {
    if (variantIndex >= 0 && variantIndex < _variants.length) {
      if (detailIndex >= 0 &&
          detailIndex < _variants[variantIndex].sizeDetails.length) {
        final errors =
            _variants[variantIndex].sizeDetails[detailIndex].validate();

        if (!_variantDetailErrors.containsKey(variantIndex)) {
          _variantDetailErrors[variantIndex] = {};
        }

        _variantDetailErrors[variantIndex]![detailIndex] = errors;
      }
    }
    notifyListeners();
  }

  bool validateAllVariants() {
    _shouldValidateVariants = true;
    bool isValid = true;

    // Clear previous errors
    _variantErrors.clear();
    _variantDetailErrors.clear();

    // Validate each variant
    for (int i = 0; i < _variants.length; i++) {
      final errors = _variants[i].validate(requireImage: true);
      if (errors.isNotEmpty) {
        isValid = false;
        _variantErrors[i] = errors;
      }

      // Validate each size detail in this variant
      _variantDetailErrors[i] = {};
      for (int j = 0; j < _variants[i].sizeDetails.length; j++) {
        final detailErrors = _variants[i].sizeDetails[j].validate();
        if (detailErrors.isNotEmpty) {
          isValid = false;
          _variantDetailErrors[i]![j] = detailErrors;
        }
      }
    }

    notifyListeners();
    return isValid;
  }

  bool validateAll() {
    _shouldValidateVariants = true;

    // Validate all fields
    validateName();
    validateDescription();
    validatePrice();
    validateProductImages();
    validateCategory();

    // Validate variants
    final variantsValid = validateAllVariants();

    // Check if any validation failed
    final formValid = _nameErrorText == null &&
        _descriptionErrorText == null &&
        _priceErrorText == null &&
        _imagesErrorText == null &&
        _categoryErrorText == null;

    return formValid && variantsValid;
  }

  // Reset all state to default values
  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _variants = [ProductVariant()]; // Reset with one default variant
    _variantErrors = {};
    _variantDetailErrors = {};
    _shouldValidateVariants = false;

    // Reset validation errors
    _imagesErrorText = null;
    _categoryErrorText = null;
    _nameErrorText = null;
    _priceErrorText = null;
    _descriptionErrorText = null;

    // Reset product fields
    _name = '';
    _description = '';
    _category = '';
    _categoryId = 0;
    _price = 0;
    _isFeatured = false;
    _productImages = [];

    // Không reset danh mục, chỉ tải lại nếu cần
    if (_categories.isEmpty) {
      loadCategories();
    }

    notifyListeners();
  }

  // Reset validation state
  void resetValidation() {
    _shouldValidateVariants = false;
    _variantErrors.clear();
    _variantDetailErrors.clear();
    _nameErrorText = null;
    _descriptionErrorText = null;
    _priceErrorText = null;
    _imagesErrorText = null;
    _categoryErrorText = null;
    notifyListeners();
  }

  Future<bool> createProduct() async {
    // Always run validation
    if (!validateAll()) {
      // Nếu có lỗi xác thực, trả về thông báo lỗi
      _errorMessage = _getFirstValidationError();
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Chuyển đổi danh sách ProductVariant thành danh sách Map<String, dynamic>
      final List<Map<String, dynamic>> variantMaps = [];

      // Chuyển đổi mô hình biến thể mới sang định dạng cũ để gửi đến repository
      for (var variant in _variants) {
        for (var sizeDetail in variant.sizeDetails) {
          variantMaps.add({
            'color': variant.color,
            'size': sizeDetail.size,
            'quantity': sizeDetail.quantity,
            'priceDifference': sizeDetail.priceDifference,
            'variantImage': variant.variantImage,
          });
        }
      }

      // Gọi repository để tạo sản phẩm và tải lên hình ảnh
      final result = await _productRepository.createProduct(
        name: _name,
        description: _description,
        price: _price,
        categoryId: _categoryId,
        isFeatured: _isFeatured,
        productImages: _productImages,
        variants: variantMaps,
      );

      if (result != null) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Không thể tạo sản phẩm mới';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Không thể tạo sản phẩm mới: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? _getFirstValidationError() {
    if (_nameErrorText != null) return _nameErrorText;
    if (_descriptionErrorText != null) return _descriptionErrorText;
    if (_priceErrorText != null) return _priceErrorText;
    if (_imagesErrorText != null) return _imagesErrorText;
    if (_categoryErrorText != null) return _categoryErrorText;

    // Check variant errors
    for (var entry in _variantErrors.entries) {
      final errors = entry.value;
      if (errors.containsKey('image')) {
        return 'Vui lòng chọn hình ảnh cho tất cả biến thể';
      }
      if (errors.containsKey('sizeDetails')) {
        return 'Mỗi biến thể cần có ít nhất một kích thước';
      }
    }

    // Check variant detail errors
    for (var variantEntry in _variantDetailErrors.entries) {
      for (var detailEntry in variantEntry.value.entries) {
        final errors = detailEntry.value;
        if (errors.containsKey('quantity')) {
          return 'Số lượng biến thể phải lớn hơn 0';
        }
      }
    }

    if (_variants.isEmpty) {
      return 'Sản phẩm phải có ít nhất một biến thể';
    }

    return 'Vui lòng kiểm tra lại thông tin sản phẩm';
  }
}
