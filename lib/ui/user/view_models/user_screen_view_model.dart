import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import 'dart:developer' as dev;

class UserScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<User> {
  final UserRepository _userRepository;
  String? _searchKeyword;

  UserScreenViewModel(this._userRepository) {
    setPageSize(10); // Thiết lập kích thước trang
  }

  String? get searchKeyword => _searchKeyword;

  @override
  Future<PaginationResult<User>?> fetchData(int page, int pageSize) async {
    try {
      final result = await _userRepository.getAllUsers(
        page: page, 
        pageSize: pageSize,
        keyword: _searchKeyword,
      );
      
      if (result != null) {
        return PaginationResult<User>(
          data: result.data,
          totalItems: result.meta.total,
          totalPages: result.meta.pages,
          currentPage: result.meta.page,
        );
      }
      return null;
    } catch (e) {
      dev.log('Lỗi khi tải danh sách người dùng: $e');
      rethrow;
    }
  }

  // Cập nhật phương thức tìm kiếm người dùng
  Future<void> searchUsers(String query) async {
    _searchKeyword = query.isNotEmpty ? query : null;
    await refresh();
  }

  // Phương thức xóa tìm kiếm
  Future<void> clearSearch() async {
    _searchKeyword = null;
    await refresh();
  }
}
