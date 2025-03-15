import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/domain/models/user_info_response.dart';

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

  // Phương thức này sẽ được thay thế bằng mock data trong ViewModel
  Future<PaginatedResponse<User>?> getAllUsers({int page = 0}) async {
    final response = await _userService.getAllUsers(page: page);
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    
    // Phương thức này sẽ không được gọi vì chúng ta đang sử dụng mock data
    return null;
  }
}