import 'package:ezstore_flutter/data/models/product/req_product.dart';
import 'package:ezstore_flutter/domain/models/product/product_response.dart'
    hide Variants;
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  ProductResponse? _product;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChanges = false;

  // Lưu trữ dữ liệu biến thể
  List<dynamic>? _originalVariants;
  List<Map<String, dynamic>> _updatedVariants = [];
  Map<String, File?> _newVariantImages = {};
  List<File> _newProductImages = [];
  bool _imagesChanged = false;

  // Map to group variants by color
  final Map<String, List<dynamic>> _groupedVariants = {};

  ProductDetailViewModel(this._productRepository);

  ProductResponse? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasChanges => _hasChanges;
  bool get imagesChanged => _imagesChanged;
  Map<String, List<dynamic>> get groupedVariants => _groupedVariants;

  // Getter cho các biến thể
  List<dynamic>? get originalVariants => _originalVariants;
  List<Map<String, dynamic>> get updatedVariants => _updatedVariants;
  Map<String, File?> get newVariantImages => _newVariantImages;
  List<File> get newProductImages => _newProductImages;

  // Group variants by color for display
  void groupVariantsByColor() {
    final variants = _product?.variants;
    if (variants == null || variants.isEmpty) return;

    _groupedVariants.clear();
    for (var variant in variants) {
      final color = variant.color ?? '';
      if (!_groupedVariants.containsKey(color)) {
        _groupedVariants[color] = [];
      }
      _groupedVariants[color]!.add(variant);
    }
    notifyListeners();
  }

  Future<void> getProductById(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await _productRepository.getProductById(productId);
      if (product != null) {
        _product = product;
        _originalVariants = product.variants;
        _hasChanges = false;
        _imagesChanged = false;
        _newVariantImages.clear();
        _newProductImages.clear();
        _updatedVariants.clear();
        groupVariantsByColor();

        // Copy variants to updatedVariants
        if (_originalVariants != null) {
          for (var variant in _originalVariants!) {
            _updatedVariants.add({
              'id': variant.id,
              'color': variant.color,
              'size': variant.size,
              'quantity': variant.quantity,
              'differencePrice': variant.differencePrice,
              'images': variant.images,
            });
          }
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin sản phẩm: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProductField(String field, dynamic value) {
    if (_product == null) return;

    bool changed = false;

    switch (field) {
      case 'name':
        if (_product!.name != value) {
          _product!.name = value;
          changed = true;
        }
        break;
      case 'description':
        if (_product!.description != value) {
          _product!.description = value;
          changed = true;
        }
        break;
      case 'price':
        if (_product!.price != value) {
          _product!.price = value;
          changed = true;
        }
        break;
      case 'categoryId':
        if (_product!.categoryId != value) {
          _product!.categoryId = value;
          changed = true;
        }
        break;
      case 'featured':
        if (_product!.featured != value) {
          _product!.featured = value;
          changed = true;
        }
        break;
    }

    if (changed) {
      _hasChanges = true;
      notifyListeners();
    }
  }

  void updateProductImages(List<File> images) {
    _newProductImages = images;
    _imagesChanged = true;
    _hasChanges = true;
    notifyListeners();
  }

  void updateVariantImage(String color, File? image) {
    _newVariantImages[color] = image;
    _imagesChanged = true;
    _hasChanges = true;
    notifyListeners();
  }

  void updateVariant(int index, Map<String, dynamic> updatedVariant) {
    if (index >= 0 && index < _updatedVariants.length) {
      // Compare to see if there are actual changes
      final oldVariant = _updatedVariants[index];
      bool hasChanges = false;

      for (var key in ['color', 'size', 'quantity', 'differencePrice']) {
        if (oldVariant[key] != updatedVariant[key]) {
          hasChanges = true;
          break;
        }
      }

      if (hasChanges) {
        _updatedVariants[index] = updatedVariant;
        _hasChanges = true;
        notifyListeners();
      }
    }
  }

  void addVariant(Map<String, dynamic> newVariant) {
    _updatedVariants.add(newVariant);
    _hasChanges = true;
    notifyListeners();
  }

  void removeVariant(int index) {
    if (index >= 0 && index < _updatedVariants.length) {
      _updatedVariants.removeAt(index);
      _hasChanges = true;
      notifyListeners();
    }
  }

  void navigateToEditScreen(BuildContext context, int productId) {
    Navigator.pushNamed(
      context,
      '/editProduct',
      arguments: {'id': productId},
    );
  }

  Future<bool> updateProduct() async {
    if (_product == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Chuyển đổi các biến thể đã cập nhật sang định dạng Variants
      final List<Variants> updatedVariantsList = [];
      for (var variant in _updatedVariants) {
        updatedVariantsList.add(Variants(
          id: variant['id'],
          color: variant['color'],
          size: variant['size'],
          quantity: variant['quantity'],
          differencePrice: variant['differencePrice'],
          images: variant['images'] != null
              ? List<String>.from(variant['images'])
              : [],
        ));
      }

      // Tạo đối tượng ReqProduct
      final reqProduct = ReqProduct(
        id: _product!.id,
        name: _product!.name,
        description: _product!.description,
        price: _product!.price,
        categoryId: _product!.categoryId,
        isFeatured: _product!.featured,
        images: _product!.images,
        variants: updatedVariantsList,
      );

      // Cập nhật sản phẩm
      final result = await _productRepository.updateProduct(
        reqProduct: reqProduct,
        newProductImages: _imagesChanged && _newProductImages.isNotEmpty
            ? _newProductImages
            : null,
        newVariantImages: _imagesChanged && _newVariantImages.isNotEmpty
            ? _newVariantImages
            : null,
      );

      if (result != null) {
        _product = result;
        _originalVariants = result.variants;
        _hasChanges = false;
        _imagesChanged = false;
        _newVariantImages.clear();
        _newProductImages.clear();
        groupVariantsByColor();

        // Reset updatedVariants
        _updatedVariants.clear();
        if (_originalVariants != null) {
          for (var variant in _originalVariants!) {
            _updatedVariants.add({
              'id': variant.id,
              'color': variant.color,
              'size': variant.size,
              'quantity': variant.quantity,
              'differencePrice': variant.differencePrice,
              'images': variant.images,
            });
          }
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Không thể cập nhật sản phẩm';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Không thể cập nhật sản phẩm: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
