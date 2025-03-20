import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/category_repository.dart';
import 'dart:developer' as dev;

class CategoryScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<Category> {
  final CategoryRepository _categoryRepository;
  String? _searchKeyword;
  bool _isDeletingCategory = false;
  String? _deleteErrorMessage;

  CategoryScreenViewModel(this._categoryRepository) {
    setPageSize(10); // Thiết lập kích thước trang
  }

  String? get searchKeyword => _searchKeyword;
  bool get isDeletingCategory => _isDeletingCategory;
  String? get deleteErrorMessage => _deleteErrorMessage;

  @override
  Future<PaginationResult<Category>?> fetchData(int page, int pageSize) async {
    try {
      final result = await _categoryRepository.getAllCategories(
        page: page,
        pageSize: pageSize,
        keyword: _searchKeyword,
      );

      if (result != null) {
        return PaginationResult<Category>(
          data: result.data,
          totalItems: result.meta.total,
          totalPages: result.meta.pages,
          currentPage: result.meta.page,
        );
      }
      return null;
    } catch (e) {
      dev.log('Lỗi khi tải danh sách danh mục: $e');
      rethrow;
    }
  }

  // Cập nhật phương thức tìm kiếm danh mục
  Future<void> searchCategories(String query) async {
    _searchKeyword = query.isNotEmpty ? query : null;
    await refresh();
  }

  // Phương thức xóa tìm kiếm
  Future<void> clearSearch() async {
    _searchKeyword = null;
    await refresh();
  }

  // Phương thức xóa danh mục
  Future<bool> deleteCategory(int? categoryId) async {
    if (categoryId == null) {
      _deleteErrorMessage = "ID danh mục không hợp lệ";
      notifyListeners();
      return false;
    }

    _isDeletingCategory = true;
    _deleteErrorMessage = null;
    notifyListeners();

    try {
      // Gọi API xóa danh mục từ repository
      await _categoryRepository.deleteCategory(categoryId);

      // Nếu xóa thành công, cập nhật lại danh sách danh mục
      _isDeletingCategory = false;
      notifyListeners();

      // Tải lại danh sách danh mục sau khi xóa
      await refresh();

      return true;
    } catch (e) {
      dev.log('Lỗi khi xóa danh mục: $e');

      // Xử lý lỗi
      _isDeletingCategory = false;

      // Trích xuất thông báo lỗi từ Exception
      if (e is Exception) {
        _deleteErrorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        _deleteErrorMessage = e.toString();
      }

      notifyListeners();
      return false;
    }
  }

  // Phương thức xóa danh mục khỏi danh sách cục bộ (nếu cần thiết)
  void removeCategoryFromLocalList(int? categoryId) {
    if (categoryId != null && items != null) {
      final updatedItems =
          items!.where((category) => category.id != categoryId).toList();
      setItems(updatedItems, totalItems - 1);
      notifyListeners();
    }
  }

  // Đặt lại thông báo lỗi xóa
  void resetDeleteError() {
    _deleteErrorMessage = null;
    notifyListeners();
  }
}
