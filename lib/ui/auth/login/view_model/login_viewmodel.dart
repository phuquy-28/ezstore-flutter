import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/utils/validators.dart';
import 'package:flutter/material.dart';


class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _error;

  LoginViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final loginSuccess = await _authRepository.login(
        email,
        password,
      );

      if (!loginSuccess) {
        _error =
            "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập.";
      } else if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
