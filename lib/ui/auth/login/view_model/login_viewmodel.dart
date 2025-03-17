import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../routing/app_routes.dart';
import '../../../../utils/validators.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _error;

  LoginViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get error => _error;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);

  Future<bool> login() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final loginSuccess = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!loginSuccess) {
        _error =
            "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập.";
        return false;
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final success = await login();
      if (success && context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Đã có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
