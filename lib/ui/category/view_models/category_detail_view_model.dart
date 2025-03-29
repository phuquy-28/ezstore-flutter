import 'dart:io';
import 'package:ezstore_flutter/data/models/category/req_category.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:flutter/material.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  Category? _category;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSubmitting = false;

  Category? get category => _category;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  CategoryDetailViewModel(this._categoryRepository);

  Future<void> getCategoryById(int categoryId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _category = await _categoryRepository.getCategoryById(categoryId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory(String name,
      {File? imageFile, String? currentImageUrl}) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.isEmpty) {
        throw Exception('Tên danh mục không được để trống');
      }

      if (_category == null) {
        throw Exception('Không tìm thấy thông tin danh mục');
      }

      // Tạo đối tượng ReqCategory để cập nhật
      final reqCategory = ReqCategory(
        id: _category!.id,
        name: name,
        imageUrl: imageFile != null ? imageFile.path : currentImageUrl,
      );

      final updatedCategory =
          await _categoryRepository.updateCategory(imageFile, reqCategory);

      if (updatedCategory != null) {
        _category = updatedCategory;
        return true;
      } else {
        throw Exception('Không thể cập nhật danh mục');
      }
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Helper method to handle image picking from ViewModel
  Future<File?> selectImage(Function(String) onError) async {
    try {
      return null; // Return null to let the screen handle the image picking
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      onError(_errorMessage!);
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  // Show success message
  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
