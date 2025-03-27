import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class UserScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<User> {
  final UserRepository _userRepository;
  String? _searchKeyword;
  bool _isDeletingUser = false;
  String? _deleteErrorMessage;
  final TextEditingController searchController = TextEditingController();

  UserScreenViewModel(this._userRepository) {
    setPageSize(10); // Thiết lập kích thước trang
  }

  String? get searchKeyword => _searchKeyword;
  bool get isDeletingUser => _isDeletingUser;
  String? get deleteErrorMessage => _deleteErrorMessage;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void initData() {
    if (items == null) {
      loadData();
    }
  }

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
    searchController.text = query;
    await refresh();
  }

  // Phương thức xóa tìm kiếm
  Future<void> clearSearch() async {
    _searchKeyword = null;
    searchController.clear();
    await refresh();
  }

  // Phương thức xử lý khi người dùng submit tìm kiếm
  void handleSearchSubmitted(String value) {
    searchUsers(value);
  }

  // Phương thức xử lý khi người dùng xóa tìm kiếm
  void handleClearSearch() {
    clearSearch();
  }

  // Phương thức xử lý khi scroll đến cuối
  void handleScrollToEnd() {
    if (!isLoading && hasMoreData) {
      loadMoreData();
    }
  }

  // Phương thức xử lý khi nhấn nút thử lại
  void handleRetry() {
    loadData();
  }

  // Phương thức xử lý khi cần refresh dữ liệu
  Future<void> handleRefresh() async {
    await refresh();
  }

  // Phương thức xử lý khi chuyển đến màn hình thêm người dùng
  void navigateToAddUser(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addUser);
  }

  // Phương thức xử lý khi chuyển đến màn hình chi tiết người dùng
  void navigateToUserDetail(BuildContext context, int userId) {
    Navigator.pushNamed(
      context,
      AppRoutes.userDetail,
      arguments: {'id': userId},
    );
  }

  // Phương thức xóa người dùng
  Future<bool> deleteUser(int userId) async {
    _isDeletingUser = true;
    _deleteErrorMessage = null;
    notifyListeners();

    try {
      // Gọi API xóa người dùng từ repository
      await _userRepository.deleteUser(userId);

      // Nếu xóa thành công, cập nhật lại danh sách người dùng
      _isDeletingUser = false;
      notifyListeners();

      // Tải lại danh sách người dùng sau khi xóa
      await refresh();

      return true;
    } catch (e) {
      dev.log('Lỗi khi xóa người dùng: $e');

      // Xử lý lỗi
      _isDeletingUser = false;

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

  // Hiển thị thông báo kết quả xóa người dùng
  void showDeleteResult(BuildContext context, bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa người dùng thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteErrorMessage ?? 'Xóa người dùng thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Phương thức xóa người dùng khỏi danh sách cục bộ (nếu cần thiết)
  void removeUserFromLocalList(int userId) {
    if (items != null) {
      final updatedItems = items!.where((user) => user.id != userId).toList();
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
