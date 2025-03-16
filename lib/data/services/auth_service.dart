import 'package:ezstore_flutter/domain/models/auth/auth_response.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import 'api_service.dart';
import '../../config/constants.dart';
import 'shared_preference_service.dart';

class AuthService {
  final ApiService _api;
  final SharedPreferenceService _preferenceService;

  AuthService(this._api, this._preferenceService);

  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    return await _api.post(
      path: ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  Future<ApiResponse<void>> logout(String refreshToken) async {
    return await _api.post(
      path: ApiConstants.logout,
      data: {'refresh_token': refreshToken},
      fromJson: (json) => null,
    );
  }

  Future<ApiResponse<AuthResponse>> refreshToken() async {
    String? refreshToken = _preferenceService.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse(
        statusCode: 401,
        error: 'Unauthorized',
        message: 'Refresh token not found',
        data: null,
      );
    }
    
    return await _api.get(
      path: ApiConstants.refresh,
      queryParameters: {'refresh_token': refreshToken},
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }
}
