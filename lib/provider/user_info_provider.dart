import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';
import '../domain/models/user_info_response.dart';

class UserInfoProvider with ChangeNotifier {
  final UserRepository _userRepository;
  UserInfoResponse? _userInfo;

  UserInfoProvider(this._userRepository);

  UserInfoResponse? get userInfo => _userInfo;

  Future<void> fetchUserInfo() async {
    if (_userInfo == null) {
      _userInfo = await _userRepository.getUserInfo();
      notifyListeners();
    }
  }
}
