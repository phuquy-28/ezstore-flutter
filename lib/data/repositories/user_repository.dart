import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/domain/models/user_info_response.dart';
import 'dart:developer' as dev;

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<UserInfoResponse?> getUserInfo() async {
    final response = await _userService.getUserInfo();

    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }

    return null;
  }

  // Cập nhật phương thức để gọi API thực tế
  Future<PaginatedResponse<User>?> getAllUsers(
      {int page = 0, int pageSize = 10, String? keyword}) async {
    try {
      final response = await _userService.getAllUsers(
          page: page, pageSize: pageSize, keyword: keyword);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      dev.log('Lỗi khi lấy danh sách người dùng: ${response.message}');
      return null;
    } catch (e) {
      dev.log('Exception khi lấy danh sách người dùng: $e');
      return null;
    }
  }
}
