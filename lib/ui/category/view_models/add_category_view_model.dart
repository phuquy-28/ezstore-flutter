import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/category/req_category.dart';
import '../../../domain/models/category/category.dart';
import '../../../data/repositories/category_repository.dart';

class AddCategoryViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Category? _createdCategory;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Category? get createdCategory => _createdCategory;

  AddCategoryViewModel(this._categoryRepository);

  Future<bool> createCategory(String name, File imageFile) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Kiểm tra dữ liệu đầu vào
      if (name.isEmpty) {
        throw Exception('Tên danh mục không được để trống');
      }
      
      if (imageFile.path.isEmpty) {
        throw Exception('Vui lòng chọn hình ảnh cho danh mục');
      }

      // Tạo đối tượng ReqCategory
      final reqCategory = ReqCategory(
        name: name,
      );

      // Gọi repository để tạo danh mục mới
      final newCategory = await _categoryRepository.createCategory(
        imageFile,
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