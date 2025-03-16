import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/data/models/user/req_user.dart';
import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/domain/models/user/user_info_response.dart';
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

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy danh sách người dùng: $e');
      rethrow;
    }
  }

  Future<User?> getUserById(int userId) async {
    try {
      final response = await _userService.getUserById(userId);
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi lấy người dùng: $e');
      rethrow;
    }
  }

  Future<User?> updateUser(ReqUser user) async {
    try {
      final response = await _userService.updateUser(user);
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi cập nhật người dùng: $e');
      rethrow;
    }
  }

  Future<User?> createUser(ReqUser user) async {
    try {
      final response = await _userService.createUser(user);
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi tạo người dùng: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await _userService.deleteUser(userId);
      if (response.statusCode == 200) {
        return;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi xóa người dùng: $e');
      rethrow;
    }
  }
}
