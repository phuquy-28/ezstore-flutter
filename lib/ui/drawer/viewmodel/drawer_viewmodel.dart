import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class DrawerViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  String? _error;

  DrawerViewModel(this._authRepository);

  String? get error => _error;

  Future<bool> logout() async {
    try {
      await _authRepository.logout();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
