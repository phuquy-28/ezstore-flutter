import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class ForgetPasswordViewModel with ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;

  ForgetPasswordViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> recoverPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _authRepository.recoverPassword(email);

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
