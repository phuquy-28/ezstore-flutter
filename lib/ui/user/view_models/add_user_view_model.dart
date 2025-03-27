import 'package:ezstore_flutter/data/models/user/req_user.dart';
import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddUserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;
  User? _createdUser;
  bool _isPasswordVisible = false;

  // Maps for handling dropdown values
  final Map<String, dynamic> genderMap = {
    'Nam': 'MALE',
    'Nữ': 'FEMALE',
    'Khác': 'OTHER',
  };

  final Map<String, int> roleMap = {
    'Admin': 1,
    'User': 2,
    'Staff': 3,
    'Manager': 4,
  };

  AddUserViewModel(this._userRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  User? get createdUser => _createdUser;
  bool get isPasswordVisible => _isPasswordVisible;
  Map<String, dynamic> get getGenderMap => genderMap;
  Map<String, int> get getRoleMap => roleMap;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

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

  // Generate random password
  String generateRandomPassword() {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String digits = '0123456789';
    const String special = '@#\$%!';

    String password = '';
    password +=
        upper[(DateTime.now().millisecondsSinceEpoch % upper.length).toInt()];
    password +=
        lower[(DateTime.now().millisecondsSinceEpoch % lower.length).toInt()];
    password +=
        digits[(DateTime.now().millisecondsSinceEpoch % digits.length).toInt()];
    password += special[
        (DateTime.now().millisecondsSinceEpoch % special.length).toInt()];

    // Thêm các ký tự ngẫu nhiên khác để đạt độ dài tối thiểu (ví dụ: 8 ký tự)
    const String allChars = upper + lower + digits + special;
    for (int i = 4; i < 8; i++) {
      password += allChars[
          (DateTime.now().millisecondsSinceEpoch % allChars.length).toInt()];
    }

    // Trộn mật khẩu và trả về dưới dạng chuỗi
    return (password.split('')..shuffle()).join();
  }

  // Copy user credentials to clipboard
  void copyCredentialsToClipboard(String email, String password) {
    final clipboardData = 'Email: $email\nMật khẩu: $password';
    Clipboard.setData(ClipboardData(text: clipboardData));
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

  // Validator functions
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      final phoneRegExp = RegExp(r'^[0-9]{10,11}$');
      if (!phoneRegExp.hasMatch(value)) {
        return 'Số điện thoại không hợp lệ';
      }
    }
    return null;
  }
}
