import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/domain/models/user/user_info_response.dart';
import 'package:flutter/material.dart';

class UserInfoProvider with ChangeNotifier {
  final UserRepository _userRepository;
  UserInfoResponse? _userInfo;
  bool _isLoading = false;
  String? _error;

  UserInfoProvider(this._userRepository);

  UserInfoResponse? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserInfo({bool forceRefresh = false}) async {
    try {
      if (_userInfo == null || forceRefresh) {
        _isLoading = true;
        _error = null;
        notifyListeners();

        _userInfo = await _userRepository.getUserInfo();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
