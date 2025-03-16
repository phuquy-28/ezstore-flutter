import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user/req_user.dart';
import '../../../domain/models/user/user.dart';
import '../../../data/repositories/user_repository.dart';

class AddUserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;
  User? _createdUser;

  AddUserViewModel(this._userRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  User? get createdUser => _createdUser;

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    _createdUser = null;
    notifyListeners();
  }

  Future<bool> addUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? birthDate,
    required String gender,
    required int roleId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    _createdUser = null;
    notifyListeners();

    try {
      // Tạo đối tượng ReqUser từ dữ liệu form
      final newUser = ReqUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phoneNumber,
        birthDate: _formatBirthDate(birthDate),
        gender: gender,
        roleId: roleId,
      );

      // Gọi API để tạo người dùng mới
      final createdUser = await _userRepository.createUser(newUser);

      _isLoading = false;

      if (createdUser != null) {
        _isSuccess = true;
        _createdUser = createdUser;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Không thể tạo người dùng mới";
        notifyListeners();
        return false;
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
      return false;
    }
  }

  // Hàm helper để định dạng ngày sinh - giống như trong UserDetailViewModel
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

  // Phương thức kiểm tra tính hợp lệ của email
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  // Phương thức kiểm tra tính hợp lệ của mật khẩu
  bool isValidPassword(String password) {
    // Kiểm tra độ dài tối thiểu
    if (password.length < 8) return false;

    // Kiểm tra có ít nhất 1 chữ hoa
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Kiểm tra có ít nhất 1 chữ thường
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Kiểm tra có ít nhất 1 số
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Kiểm tra có ít nhất 1 ký tự đặc biệt
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  // Phương thức kiểm tra tính hợp lệ của số điện thoại
  bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return true; // Cho phép số điện thoại trống
    final phoneRegExp = RegExp(r'^[0-9]{10,11}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }
}
