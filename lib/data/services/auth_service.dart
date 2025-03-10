import 'package:ezstore_flutter/domain/models/auth_response.dart';
import 'api_service.dart';
import '../../config/constants.dart';
import 'shared_preference_service.dart';

class AuthService {
  final ApiService _api;
  final SharedPreferenceService _preferenceService;

  AuthService(this._api, this._preferenceService);

  Future<AuthResponse> login(String email, String password) async {
    try {
      return await _api.post(
        path: ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _api.post(
        path: ApiConstants.logout,
        data: {'refresh_token': refreshToken},
        fromJson: (json) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> refreshToken(String token) async {
    try {
      String? refreshToken = _preferenceService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Refresh token not found');
      }
      return await _api.get(
        path: ApiConstants.refresh,
        queryParameters: {'refresh_token': refreshToken},
        fromJson: (json) => AuthResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
