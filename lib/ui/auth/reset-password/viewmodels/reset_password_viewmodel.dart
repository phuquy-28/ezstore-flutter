import 'package:ezstore_flutter/data/models/auth/reset_password_req.dart';
import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class ResetPasswordViewModel with ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;
  String _email = '';
  String? _verificationCode;

  ResetPasswordViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get email => _email;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    if (_email.isEmpty || _verificationCode == null) {
      _errorMessage = 'Thông tin không hợp lệ';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final request = ResetPasswordReq(
        email: _email,
        resetCode: _verificationCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final success = await _authRepository.resetPassword(request);

      _isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
