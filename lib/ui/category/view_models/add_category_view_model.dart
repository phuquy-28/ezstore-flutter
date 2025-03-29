import 'dart:io';
import 'package:ezstore_flutter/data/models/category/req_category.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:flutter/material.dart';

class AddCategoryViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Category? _createdCategory;
  String? _nameErrorText;
  bool _isImageSelected = false;
  String? _imageErrorText;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Category? get createdCategory => _createdCategory;
  String? get nameErrorText => _nameErrorText;
  bool get isImageSelected => _isImageSelected;
  String? get imageErrorText => _imageErrorText;

  AddCategoryViewModel(this._categoryRepository);

  void resetValidation() {
    _nameErrorText = null;
    _imageErrorText = null;
    notifyListeners();
  }

  void updateImageSelected(bool value) {
    _isImageSelected = value;
    if (value) {
      _imageErrorText = null;
    }
    notifyListeners();
  }

  bool validateName(String name) {
    if (name.isEmpty) {
      _nameErrorText = 'Vui lòng nhập tên danh mục';
      notifyListeners();
      return false;
    }
    _nameErrorText = null;
    notifyListeners();
    return true;
  }

  bool validateImage(File? imageFile) {
    if (imageFile == null || !_isImageSelected) {
      _imageErrorText = 'Vui lòng chọn hình ảnh cho danh mục';
      notifyListeners();
      return false;
    }
    _imageErrorText = null;
    notifyListeners();
    return true;
  }

  bool validateAll(String name, File? imageFile) {
    final nameValid = validateName(name);
    final imageValid = validateImage(imageFile);
    return nameValid && imageValid;
  }

  Future<bool> createCategory(String name, File? imageFile) async {
    if (_isLoading) return false;

    if (!validateAll(name, imageFile)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Tạo đối tượng ReqCategory
      final reqCategory = ReqCategory(
        name: name,
      );

      // Gọi repository để tạo danh mục mới
      final newCategory = await _categoryRepository.createCategory(
        imageFile!,
        reqCategory,
      );

      if (newCategory != null) {
        _createdCategory = newCategory;
        return true;
      } else {
        throw Exception('Không thể tạo danh mục mới');
      }
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
