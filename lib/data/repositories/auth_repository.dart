import '../services/auth_service.dart';
import '../services/shared_preference_service.dart';
import 'dart:developer' as dev;

class AuthRepository {
  final AuthService _authService;
  final SharedPreferenceService _preferenceService;

  AuthRepository(this._authService, this._preferenceService);

  Future<bool> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);

      if (response.statusCode == 200 && response.data != null) {
        await _preferenceService.setTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
        );
        return true;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi đăng nhập: $e');
      rethrow;
    }
  }

  Future<bool> logout() async {
    final refreshToken = _preferenceService.getRefreshToken();
    if (refreshToken != null) {
      await _authService.logout(refreshToken);
    }

    await _preferenceService.clearTokens();
    return true;
  }

  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();

      if (response.statusCode == 200 && response.data != null) {
        await _preferenceService.setTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
        );
        return true;
      }

      final errors = response.message.split(',');
      throw Exception(errors.first);
    } catch (e) {
      dev.log('Exception khi làm mới token: $e');
      rethrow;
    }
  }

  bool isLoggedIn() {
    return _preferenceService.getAccessToken() != null;
  }
}
