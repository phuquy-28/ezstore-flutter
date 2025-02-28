import '../services/auth_service.dart';
import '../services/shared_preference_service.dart';

class AuthRepository {
  final AuthService _authService;
  final SharedPreferenceService _preferenceService;

  AuthRepository(this._authService, this._preferenceService);

  Future<void> login(String email, String password) async {
    final authData = await _authService.login(email, password);
    await _preferenceService.setTokens(
      authData.accessToken,
      authData.refreshToken,
    );
  }

  Future<void> logout() async {
    final refreshToken = _preferenceService.getRefreshToken();
    if (refreshToken != null) {
      await _authService.logout(refreshToken);
    }
    await _preferenceService.clearTokens();
  }
}
