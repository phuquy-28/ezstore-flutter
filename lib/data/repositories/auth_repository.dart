import '../services/auth_service.dart';
import '../services/shared_preference_service.dart';

class AuthRepository {
  final AuthService _authService;
  final SharedPreferenceService _preferenceService;

  AuthRepository(this._authService, this._preferenceService);

  Future<bool> login(String email, String password) async {
    final response = await _authService.login(email, password);
    
    if (response.statusCode == 200 && response.data != null) {
      await _preferenceService.setTokens(
        response.data!.accessToken,
        response.data!.refreshToken,
      );
      return true;
    }
    
    return false;
  }

  Future<bool> logout() async {
    final refreshToken = _preferenceService.getRefreshToken();
    if (refreshToken != null) {
      final response = await _authService.logout(refreshToken);
      if (response.statusCode != 200) {
        // Vẫn xóa token ngay cả khi API thất bại
        await _preferenceService.clearTokens();
        return false;
      }
    }
    
    await _preferenceService.clearTokens();
    return true;
  }
  
  Future<bool> refreshToken() async {
    final response = await _authService.refreshToken();
    
    if (response.statusCode == 200 && response.data != null) {
      await _preferenceService.setTokens(
        response.data!.accessToken,
        response.data!.refreshToken,
      );
      return true;
    }
    
    return false;
  }
  
  bool isLoggedIn() {
    return _preferenceService.getAccessToken() != null;
  }
}
