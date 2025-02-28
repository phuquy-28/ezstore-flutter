import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/user_info_response.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  Future<UserInfoResponse> getUserInfo() async {
    try {
      return await _api.get(
        path: ApiConstants.info,
        fromJson: (json) => UserInfoResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
