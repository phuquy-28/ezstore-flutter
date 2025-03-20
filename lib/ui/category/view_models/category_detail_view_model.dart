import 'dart:io';
import 'package:ezstore_flutter/data/models/category/req_category.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/category/category.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  Category? _category;
  bool _isLoading = false;
  String? _errorMessage;

  Category? get category => _category;
  bool get isLoading => _isLoading;
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

  Future<bool> updateCategory(ReqCategory reqCategory, File? imageFile) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (reqCategory.name.isEmpty) {
        throw Exception('Tên danh mục không được để trống');
      }

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
