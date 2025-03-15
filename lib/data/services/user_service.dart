import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/user_info_response.dart';
import 'package:ezstore_flutter/data/models/paginated_response.dart';
import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  Future<ApiResponse<UserInfoResponse>> getUserInfo() async {
    return await _api.get(
      path: ApiConstants.info,
      fromJson: (json) => UserInfoResponse.fromJson(json),
    );
  }

  // Phương thức này sẽ được thêm vào nhưng không được sử dụng vì chúng ta đang dùng mock data
  Future<ApiResponse<PaginatedResponse<User>>> getAllUsers({int page = 0}) async {
    // Phương thức này sẽ không được gọi vì chúng ta đang sử dụng mock data
    return ApiResponse(
      statusCode: 501,
      error: 'Not Implemented',
      message: 'Đang sử dụng mock data, không gọi API thực tế',
      data: null,
    );
  }
}
