import 'dart:async';
import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class VerifyViewModel with ChangeNotifier {
  final AuthRepository authRepository;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String _email = '';
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  String? _verificationCode;

  VerifyViewModel(this.authRepository);

  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  String? get errorMessage => _errorMessage;
  int get resendCooldown => _resendCooldown;
  bool get canResend => _resendCooldown == 0 && !_isResending;
  String get email => _email;
  String? get verificationCode => _verificationCode;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  void startResendCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendCooldown--;
      if (_resendCooldown <= 0) {
        timer.cancel();
        _resendCooldown = 0;
      }
      notifyListeners();
    });
  }

  Future<bool> verifyPasswordReset(String code) async {
    if (_email.isEmpty) {
      _errorMessage = 'Email không được để trống';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Save the code for later use in reset password screen
      _verificationCode = code;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendActivationCode() async {
    if (_email.isEmpty) {
      _errorMessage = 'Email không được để trống';
      notifyListeners();
      return false;
    }

    try {
      _isResending = true;
      _errorMessage = null;
      notifyListeners();

      final success = await authRepository.recoverPassword(_email);

      _isResending = false;
      if (success) {
        startResendCooldown();
      }
      notifyListeners();

      return success;
    } catch (e) {
      _isResending = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
