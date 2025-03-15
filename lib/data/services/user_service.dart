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

  // Cập nhật phương thức để hỗ trợ tìm kiếm
  Future<ApiResponse<PaginatedResponse<User>>> getAllUsers({
    int page = 0,
    int pageSize = 10,
    String? keyword,
  }) async {
    String path = '${ApiConstants.users}?page=$page&size=$pageSize';

    // Thêm bộ lọc tìm kiếm nếu có từ khóa
    if (keyword != null && keyword.isNotEmpty) {
      path += "&filter=email~'$keyword' or profile.fullName~'$keyword'";
    }

    return await _api.get(
      path: path,
      fromJson: (json) => PaginatedResponse<User>.fromJson(
        json,
        (userJson) => User.fromJson(userJson),
      ),
    );
  }
}
