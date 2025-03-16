import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user/req_user.dart';
import '../../../domain/models/user/user.dart';
import 'package:intl/intl.dart';

class UserDetailViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserDetailViewModel(this._userRepository);

  Future<void> getUserById(int userId) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      final user = await _userRepository.getUserById(userId);

      if (user != null) {
        _user = user;
        _errorMessage = null;
      } else {
        _errorMessage = "Không tìm thấy thông tin người dùng";
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateUser(User user, String? newPassword) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      // Lấy roleId từ user.role.id
      int roleId = user.role.id;

      // Tạo đối tượng ReqUpdateUser
      final reqUpdateUser = ReqUser(
        id: user.id,
        email: user.email,
        password: newPassword?.isNotEmpty == true ? newPassword : null,
        firstName: user.firstName,
        lastName: user.lastName,
        birthDate: _formatBirthDate(user.birthDate),
        phone: user.phoneNumber,
        gender: user.gender,
        roleId: roleId,
      );

      // Gọi API cập nhật người dùng
      final updatedUser = await _userRepository.updateUser(reqUpdateUser);

      _isLoading = false;

      if (updatedUser != null) {
        _user = updatedUser;
        _errorMessage = null;
        notifyListeners();
        return true; // Trả về true nếu cập nhật thành công
      } else {
        _errorMessage = "Không thể cập nhật thông tin người dùng";
        notifyListeners();
        return false; // Trả về false nếu cập nhật thất bại
      }
    } catch (e) {
      _isLoading = false;

      // Trích xuất thông báo lỗi từ Exception
      if (e is Exception) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        _errorMessage = e.toString();
      }

      notifyListeners();
      return false; // Trả về false nếu có lỗi
    }
  }

  // Hàm helper để định dạng ngày sinh
  String? _formatBirthDate(dynamic birthDate) {
    if (birthDate == null) return null;

    if (birthDate is DateTime) {
      return DateFormat('yyyy-MM-dd').format(birthDate);
    }

    if (birthDate is String && birthDate.isNotEmpty) {
      try {
        // Nếu là chuỗi định dạng dd/MM/yyyy, chuyển sang yyyy-MM-dd
        if (birthDate.contains('/')) {
          final date = DateFormat('dd/MM/yyyy').parse(birthDate);
          return DateFormat('yyyy-MM-dd').format(date);
        }
        return birthDate;
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
