import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/domain/models/user_info_response.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<UserInfoResponse> getUserInfo() async {
    return await _userService.getUserInfo();
  }

  // Phương thức này sẽ được thay thế bằng mock data trong ViewModel
  Future<PaginatedResponse<User>> getAllUsers({int page = 0}) async {
    // Phương thức này sẽ không được gọi vì chúng ta đang sử dụng mock data
    throw UnimplementedError('Đang sử dụng mock data, không gọi API thực tế');
  }
}