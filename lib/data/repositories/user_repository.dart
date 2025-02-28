import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/domain/models/user_info_response.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<UserInfoResponse> getUserInfo() async {
    return await _userService.getUserInfo();
  }
}