import 'dart:developer' as dev;
import 'dart:io';

import 'package:ezstore_flutter/data/models/category/req_category.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/upload/req_upload_image.dart';
import 'package:ezstore_flutter/data/services/category_service.dart';
import 'package:ezstore_flutter/data/services/upload_service.dart';
import 'package:ezstore_flutter/domain/models/category/category.dart';

class CategoryRepository {
  final CategoryService _categoryService;
  final UploadService _uploadService;

  CategoryRepository(this._categoryService, this._uploadService);

  Future<PaginatedResponse<Category>?> getAllCategories(
      {int page = 0, int pageSize = 10, String? keyword}) async {
    try {
      final response = await _categoryService.getAllCategories(
          page: page, pageSize: pageSize, keyword: keyword);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh sách danh mục: $e');
      rethrow;
    }
  }

  Future<Category?> getCategoryById(int categoryId) async {
    try {
      final response = await _categoryService.getCategoryById(categoryId);
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh mục: $e');
      rethrow;
    }
  }

  // Phương thức riêng để tải lên hình ảnh
  Future<String?> _uploadImage(File imageFile, String categoryName) async {
    try {
      // Tạo tên file với timestamp để tránh trùng lặp
      final originalFileName = imageFile.path.split('/').last;
      final extension = originalFileName.split('.').last;
      final fileName =
          '${categoryName.replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Tạo yêu cầu để lấy URL đã ký
      final reqUploadImage = ReqUploadImage(fileName: fileName);

      // Lấy URL đã ký để tải lên
      final uploadUrlResponse =
          await _uploadService.getUploadImageUrl(reqUploadImage);

      if (uploadUrlResponse.statusCode != 201 ||
          uploadUrlResponse.data == null) {
        throw Exception('Không thể lấy URL để tải lên hình ảnh');
      }

      // Lấy URL đã ký từ phản hồi
      final signedUrl = uploadUrlResponse.data!.signedUrl!;

      // Tải hình ảnh lên Google Storage
      final uploadResult =
          await _uploadService.uploadFileToStorage(imageFile, signedUrl);

      if (uploadResult == null) {
        throw Exception('Không thể tải lên hình ảnh');
      }

      // Trả về URL công khai của hình ảnh
      return uploadResult;
    } catch (e) {
      dev.log('Exception khi tải lên hình ảnh: $e');
      rethrow;
    }
  }

  Future<Category?> updateCategory(
      File? imageFile, ReqCategory reqCategory) async {
    try {
      String? imageUrl = reqCategory.imageUrl;

      // Nếu có file hình ảnh mới, tải lên trước
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, reqCategory.name);
      }

      // Cập nhật thông tin danh mục với URL hình ảnh mới (nếu có)
      final updatedCategory = ReqCategory(
        id: reqCategory.id,
        name: reqCategory.name,
        imageUrl: imageUrl, // Chỉ cập nhật URL nếu có hình ảnh mới
      );

      // Gọi API để cập nhật danh mục
      final response = await _categoryService.updateCategory(updatedCategory);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi cập nhật danh mục: $e');
      rethrow;
    }
  }

  Future<Category?> createCategory(
      File? imageFile, ReqCategory reqCategory) async {
    try {
      String? imageUrl;

      // Nếu có file hình ảnh mới, tải lên trước
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, reqCategory.name);
      }

      final newCategory = ReqCategory(
        name: reqCategory.name,
        imageUrl: imageUrl,
      );

      final response = await _categoryService.createCategory(newCategory);

      if (response.statusCode == 201 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi tạo danh mục: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await _categoryService.deleteCategory(categoryId);
      if (response.statusCode == 200) {
        return;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi xóa danh mục: $e');
      rethrow;
    }
  }
}
