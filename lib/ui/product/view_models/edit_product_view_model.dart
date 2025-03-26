import 'package:ezstore_flutter/data/models/product/req_product.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart'
    as category_models;
import 'package:flutter/foundation.dart';
import 'dart:io';

class VariantDetail {
  int? id;
  String size;
  int quantity;
  double priceDifference;

  VariantDetail({
    this.id,
    required this.size,
    required this.quantity,
    required this.priceDifference,
  });
}

class ProductVariant {
  String color;
  List<VariantDetail> sizeDetails;
  File? variantImage;
  String? originalImageUrl;

  ProductVariant({
    required this.color,
    required this.sizeDetails,
    this.variantImage,
    this.originalImageUrl,
  });
}

class EditProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  // Product Data
  int? _productId;
  String _name = '';
  String _description = '';
  double _price = 0;
  String _categoryName = '';
  int _categoryId = 0;
  bool _featured = false;
  List<File> _productImages = [];
  List<String> _originalProductImages = [];
  bool _hasOriginalImages = false;
  List<ProductVariant> _variants = [];
  // Track image operations
  List<Map<String, dynamic>> _productImageOperations = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _shouldValidateVariants = false;
  bool _hasChanges = false;

  // Error handling
  String? _errorMessage;
  String? _nameErrorText;
  String? _descriptionErrorText;
  String? _priceErrorText;
  String? _imagesErrorText;
  String? _categoryErrorText;
  Map<int, Map<String, String?>> _variantErrors = {};
  Map<int, Map<int, Map<String, String?>>> _variantDetailErrors = {};

  // Categories
  List<category_models.Category> _categories = [];

  EditProductViewModel(this._productRepository, this._categoryRepository);

  // Getters
  int? get productId => _productId;
  String get name => _name;
  String get description => _description;
  double get price => _price;
  String get categoryName => _categoryName;
  int get categoryId => _categoryId;
  bool get featured => _featured;
  List<File> get productImages => _productImages;
  List<String> get originalProductImages => _originalProductImages;
  bool get hasOriginalImages => _hasOriginalImages;
  List<ProductVariant> get variants => _variants;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get shouldValidateVariants => _shouldValidateVariants;
  bool get hasChanges => _hasChanges;
  String? get errorMessage => _errorMessage;
  List<category_models.Category> get categories => _categories;

  // Error getters
  String? get nameErrorText => _nameErrorText;
  String? get descriptionErrorText => _descriptionErrorText;
  String? get priceErrorText => _priceErrorText;
  String? get imagesErrorText => _imagesErrorText;
  String? get categoryErrorText => _categoryErrorText;
  Map<int, Map<String, String?>> get variantErrors => _variantErrors;
  Map<int, Map<int, Map<String, String?>>> get variantDetailErrors =>
      _variantDetailErrors;

  // Load product by ID
  Future<void> loadProduct(int productId) async {
    if (productId <= 0) {
      _errorMessage = 'ID sản phẩm không hợp lệ';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _productId = productId;
    try {
      final product = await _productRepository.getProductById(productId);
      if (product != null) {
        // Set basic product information
        _name = product.name ?? '';
        _description = product.description ?? '';
        _price = product.price ?? 0;
        _categoryName = product.categoryName ?? '';
        _categoryId = product.categoryId ?? 0;
        _featured = product.featured ?? false;
        _originalProductImages = product.images ?? [];
        _hasOriginalImages = _originalProductImages.isNotEmpty;

        // Convert variants to our ViewModel format
        _variants = [];
        if (product.variants != null) {
          // Group variants by color
          final Map<String, List<dynamic>> variantsByColor = {};
          for (var variant in product.variants!) {
            final color = variant.color ?? '';
            if (!variantsByColor.containsKey(color)) {
              variantsByColor[color] = [];
            }
            variantsByColor[color]!.add(variant);
          }

          // Create ProductVariant objects for each color
          variantsByColor.forEach((color, colorVariants) {
            List<VariantDetail> sizeDetails = [];

            for (var variant in colorVariants) {
              sizeDetails.add(VariantDetail(
                id: variant.id,
                size: variant.size ?? '',
                quantity: variant.quantity ?? 0,
                priceDifference: variant.differencePrice ?? 0,
              ));
            }

            // Get the variant image URL from the first variant of this color
            final imageUrl = colorVariants.isNotEmpty &&
                    colorVariants.first.images != null &&
                    colorVariants.first.images!.isNotEmpty
                ? colorVariants.first.images!.first
                : null;

            _variants.add(ProductVariant(
              color: color,
              sizeDetails: sizeDetails,
              originalImageUrl: imageUrl,
            ));
          });
        }

        // If there are no variants, add an empty one
        if (_variants.isEmpty) {
          _addEmptyVariant();
        }

        _hasChanges = false;
        _errorMessage = null;
      } else {
        _errorMessage = 'Không tìm thấy thông tin sản phẩm với ID: $productId';
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin sản phẩm: $e';
      print('Error loading product: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      final categoriesResponse = await _categoryRepository.getAllCategories();
      if (categoriesResponse != null) {
        _categories = categoriesResponse.data;
      } else {
        _categories = [];
      }
    } catch (e) {
      _categories = [];
      print('Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Update methods
  void updateName(String value) {
    if (_name != value) {
      _name = value;
      _hasChanges = true;
      _nameErrorText = null;
      notifyListeners();
    }
  }

  void updateDescription(String value) {
    if (_description != value) {
      _description = value;
      _hasChanges = true;
      _descriptionErrorText = null;
      notifyListeners();
    }
  }

  void updatePrice(String value) {
    if (value.isNotEmpty) {
      try {
        final newPrice = double.parse(value);
        if (_price != newPrice) {
          _price = newPrice;
          _hasChanges = true;
          _priceErrorText = null;
          notifyListeners();
        }
      } catch (e) {
        _priceErrorText = 'Giá sản phẩm phải là số';
        notifyListeners();
      }
    } else {
      _price = 0;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void updateCategory(String categoryName) {
    if (_categoryName != categoryName) {
      _categoryName = categoryName;

      // Find the category ID
      final category = _categories.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => category_models.Category(),
      );

      _categoryId = category.id ?? 0;
      _hasChanges = true;
      _categoryErrorText = null;
      notifyListeners();
    }
  }

  void updateFeatured(bool value) {
    if (_featured != value) {
      _featured = value;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void updateProductImages(List<File> images) {
    // Track add operations for any new images
    // Find the images that were not in the previous list
    final List<File> newImages =
        images.where((image) => !_productImages.contains(image)).toList();

    // Add operations for each new image (to be added at the end)
    for (final File image in newImages) {
      _productImageOperations.add({
        'type': 'add',
        'file': image,
      });
    }

    _productImages = images;
    _hasChanges = true;
    _imagesErrorText = null;
    notifyListeners();
  }

  // Variant management
  void addVariant() {
    _addEmptyVariant();
    _hasChanges = true;
    notifyListeners();
  }

  void _addEmptyVariant() {
    _variants.add(ProductVariant(
      color: 'RED',
      sizeDetails: [
        VariantDetail(
          id: null,
          size: 'M',
          quantity: 1,
          priceDifference: 0,
        ),
      ],
    ));
  }

  void removeVariant(int index) {
    if (index >= 0 && index < _variants.length) {
      _variants.removeAt(index);
      _hasChanges = true;
      notifyListeners();
    }
  }

  void updateVariant(int index, ProductVariant updatedVariant) {
    if (index >= 0 && index < _variants.length) {
      _variants[index] = updatedVariant;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void addSizeDetail(int variantIndex) {
    if (variantIndex >= 0 && variantIndex < _variants.length) {
      _variants[variantIndex].sizeDetails.add(VariantDetail(
            id: null,
            size: 'M',
            quantity: 1,
            priceDifference: 0,
          ));
      _hasChanges = true;
      notifyListeners();
    }
  }

  void removeSizeDetail(int variantIndex, int detailIndex) {
    if (variantIndex >= 0 &&
        variantIndex < _variants.length &&
        detailIndex >= 0 &&
        detailIndex < _variants[variantIndex].sizeDetails.length) {
      _variants[variantIndex].sizeDetails.removeAt(detailIndex);
      _hasChanges = true;
      notifyListeners();
    }
  }

  // Validation
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
      _descriptionErrorText = 'Mô tả sản phẩm quá ngắn (tối thiểu 10 ký tự)';
    } else if (_description.length > 1000) {
      _descriptionErrorText = 'Mô tả sản phẩm quá dài (tối đa 1000 ký tự)';
    } else {
      _descriptionErrorText = null;
    }
    notifyListeners();
  }

  void validatePrice() {
    if (_price <= 0) {
      _priceErrorText = 'Giá sản phẩm phải lớn hơn 0';
    } else if (_price > 1000000000) {
      _priceErrorText = 'Giá sản phẩm quá cao';
    } else {
      _priceErrorText = null;
    }
    notifyListeners();
  }

  void validateProductImages() {
    // If we have original images and no new images, we're okay
    if (_hasOriginalImages && _productImages.isEmpty) {
      _imagesErrorText = null;
    } else if (!_hasOriginalImages && _productImages.isEmpty) {
      _imagesErrorText = 'Vui lòng tải lên ít nhất một hình ảnh sản phẩm';
    } else {
      _imagesErrorText = null;
    }
    notifyListeners();
  }

  void validateCategory() {
    if (_categoryName.isEmpty || _categoryId <= 0) {
      _categoryErrorText = 'Vui lòng chọn danh mục sản phẩm';
    } else {
      _categoryErrorText = null;
    }
    notifyListeners();
  }

  void validateAllVariants() {
    _shouldValidateVariants = true;
    _variantErrors = {};
    _variantDetailErrors = {};

    // Kiểm tra xem có ít nhất 1 biến thể
    if (_variants.isEmpty) {
      // Nếu không có biến thể, thêm một biến thể trống và gán lỗi cho nó
      _addEmptyVariant();
      _variantErrors[0] = {
        'color': 'Vui lòng thêm ít nhất một biến thể sản phẩm'
      };
      notifyListeners();
      return;
    }

    // Tạo một Set để kiểm tra màu sắc trùng lặp
    final Set<String> uniqueColors = {};

    for (int i = 0; i < _variants.length; i++) {
      final variant = _variants[i];
      final variantError = <String, String?>{};
      final detailErrors = <int, Map<String, String?>>{};

      // Check the color
      if (variant.color.isEmpty) {
        variantError['color'] = 'Vui lòng chọn màu sắc';
      } else if (uniqueColors.contains(variant.color)) {
        variantError['color'] =
            'Màu sắc này đã được sử dụng, vui lòng chọn màu khác';
      } else {
        uniqueColors.add(variant.color);
      }

      // Check variant image if required
      if (variant.variantImage == null && variant.originalImageUrl == null) {
        variantError['image'] = 'Vui lòng tải lên hình ảnh cho biến thể này';
      }

      // Validate size details
      if (variant.sizeDetails.isEmpty) {
        variantError['sizeDetails'] =
            'Vui lòng thêm ít nhất một kích thước cho biến thể này';
      } else {
        // Check for duplicate sizes
        final Set<String> sizes = {};
        for (int j = 0; j < variant.sizeDetails.length; j++) {
          final detail = variant.sizeDetails[j];
          final detailError = <String, String?>{};

          if (detail.size.isEmpty) {
            detailError['size'] = 'Vui lòng chọn kích thước';
          } else if (sizes.contains(detail.size)) {
            detailError['size'] = 'Kích thước này đã được sử dụng';
          } else {
            sizes.add(detail.size);
          }

          if (detail.quantity <= 0) {
            detailError['quantity'] = 'Số lượng phải lớn hơn 0';
          }

          if (detail.priceDifference < 0) {
            detailError['priceDifference'] = 'Chênh lệch giá không thể âm';
          }

          if (detailError.isNotEmpty) {
            detailErrors[j] = detailError;
          }
        }
      }

      // Add the errors if any
      if (variantError.isNotEmpty) {
        _variantErrors[i] = variantError;
      }

      if (detailErrors.isNotEmpty) {
        _variantDetailErrors[i] = detailErrors;
      }
    }

    notifyListeners();
  }

  void resetValidation() {
    _nameErrorText = null;
    _descriptionErrorText = null;
    _priceErrorText = null;
    _imagesErrorText = null;
    _categoryErrorText = null;
    _variantErrors = {};
    _variantDetailErrors = {};
    _shouldValidateVariants = false;
    notifyListeners();
  }

  // Method to update original product images
  void updateOriginalProductImages(List<String> images) {
    // Create remove operations for images that were in the original list but not in the new list
    final List<String> removedImages = _originalProductImages
        .where((image) => !images.contains(image))
        .toList();

    for (final String removedImage in removedImages) {
      final int index = _originalProductImages.indexOf(removedImage);
      if (index >= 0) {
        _productImageOperations.add({
          'type': 'remove',
          'index': index,
          'url': removedImage,
        });
      }
    }

    _originalProductImages = images;
    _hasOriginalImages = images.isNotEmpty;
    _hasChanges = true;
    _imagesErrorText = null;
    notifyListeners();
  }

  // Method to replace a product image at a specific index
  void replaceProductImage(int index, File newImage) {
    if (index >= 0 && index < _originalProductImages.length) {
      // Store the old URL for reference
      final String oldUrl = _originalProductImages[index];

      // Add a replace operation
      _productImageOperations.add({
        'type': 'replace',
        'index': index,
        'file': newImage,
        'oldUrl': oldUrl
      });

      // For immediate UI feedback, update the original images list
      // to reflect the replacement in the UI (this won't affect the server operation)
      // We'll just remove it so the UI shows the new local image instead
      _originalProductImages.removeAt(index);
      _hasOriginalImages = _originalProductImages.isNotEmpty;

      _hasChanges = true;
      notifyListeners();
    }
  }

  // Method to remove a variant's original image
  void removeVariantOriginalImage(int variantIndex) {
    if (variantIndex >= 0 && variantIndex < _variants.length) {
      _variants[variantIndex].originalImageUrl = null;
      _hasChanges = true;
      notifyListeners();
    }
  }

  // Save updated product
  Future<bool> updateProduct() async {
    _setLoading(true);
    try {
      // Validate all fields first
      validateName();
      validateDescription();
      validatePrice();
      validateProductImages();
      validateCategory();
      validateAllVariants();

      // Check if there are validation errors
      if (_nameErrorText != null ||
          _descriptionErrorText != null ||
          _priceErrorText != null ||
          _imagesErrorText != null ||
          _categoryErrorText != null ||
          _variantErrors.isNotEmpty) {
        _setLoading(false);
        return false;
      }

      // Create list of variant objects for the request
      final List<Variants> reqVariants = [];

      // Tạo map để theo dõi biến thể theo màu sắc
      final Map<String, List<VariantDetail>> colorToSizeDetailsMap = {};

      // Nhóm các biến thể theo màu sắc để đảm bảo tất cả các kích thước của cùng một màu
      // sẽ sử dụng cùng một hình ảnh
      for (final variant in _variants) {
        if (!colorToSizeDetailsMap.containsKey(variant.color)) {
          colorToSizeDetailsMap[variant.color] = [];
        }
        colorToSizeDetailsMap[variant.color]!.addAll(variant.sizeDetails);
      }

      // Tạo các đối tượng Variants cho request
      colorToSizeDetailsMap.forEach((color, sizeDetails) {
        // Tìm biến thể gốc chứa màu này để lấy thông tin hình ảnh
        final originalVariant = _variants.firstWhere((v) => v.color == color);

        for (final detail in sizeDetails) {
          reqVariants.add(Variants(
            id: detail.id,
            color: color,
            size: detail.size,
            quantity: detail.quantity,
            differencePrice: detail.priceDifference,
            images: originalVariant.originalImageUrl != null
                ? [originalVariant.originalImageUrl!]
                : [],
          ));
        }
      });

      // Create the request object
      final reqProduct = ReqProduct(
        id: _productId,
        name: _name,
        description: _description,
        price: _price,
        categoryId: _categoryId,
        isFeatured: _featured,
        images: _originalProductImages, // Original images list
        variants: reqVariants,
      );

      // Prepare map of variant images for upload
      final Map<String, File?> variantImages = {};
      for (final variant in _variants) {
        // Trong TH có hình mới, gửi đi hình mới
        if (variant.variantImage != null) {
          variantImages[variant.color] = variant.variantImage;
        }
        // Trong TH đã xóa hình cũ nhưng không có hình mới, cần báo hiệu xóa hình
        else if (variant.originalImageUrl == null) {
          // Đặt giá trị null để báo hiệu rằng hình ảnh đã bị xóa
          // Repository sẽ nhận được key này và đặt URL thành mảng trống
          variantImages[variant.color] = null;
        }
      }

      // Quyết định cách xử lý hình ảnh sản phẩm
      List<File>? newImages;
      if (_productImages.isNotEmpty) {
        // Nếu có hình ảnh mới, sử dụng chúng
        newImages = _productImages;
      } else if (_originalProductImages.isEmpty) {
        // Nếu không có hình ảnh gốc và không có hình ảnh mới, set null để không cập nhật
        newImages = null;
      } else {
        // Giữ nguyên hình ảnh gốc
        newImages = null;
      }

      // Call the repository to update the product with image operations
      final result = await _productRepository.updateProduct(
        reqProduct: reqProduct,
        newProductImages: newImages,
        newVariantImages: variantImages.isNotEmpty ? variantImages : null,
        productImageOperations:
            _productImageOperations.isNotEmpty ? _productImageOperations : null,
      );

      if (result != null) {
        _hasChanges = false;
        _errorMessage = null;
        _productImageOperations =
            []; // Reset operations after successful update
        return true;
      } else {
        _errorMessage = 'Không thể cập nhật sản phẩm';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật sản phẩm: $e';
      print('Error updating product: $e');
      _setLoading(false);
      return false;
    }
  }

  void resetState() {
    _productId = null;
    _name = '';
    _description = '';
    _price = 0;
    _categoryName = '';
    _categoryId = 0;
    _featured = false;
    _productImages = [];
    _originalProductImages = [];
    _hasOriginalImages = false;
    _variants = [];
    _hasChanges = false;
    _errorMessage = null;
    _productImageOperations = []; // Reset image operations
    resetValidation();

    // Add a default empty variant
    _addEmptyVariant();

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
