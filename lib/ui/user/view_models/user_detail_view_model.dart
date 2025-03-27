import 'package:ezstore_flutter/data/models/user/req_user.dart';
import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UserDetailViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
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

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  Map<String, dynamic> get getGenderMap => genderMap;
  Map<String, int> get getRoleMap => roleMap;

  UserDetailViewModel(this._userRepository);

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> getUserById(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
    }
  }

  Future<bool> updateUser(User user, String? newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
    return (password.split('')..shuffle()).join(); // Trả về chuỗi đã trộn
  }

  // Copy user credentials to clipboard
  void copyCredentialsToClipboard(String email, String password) {
    final clipboardData = 'Email: $email\nMật khẩu: $password';
    Clipboard.setData(ClipboardData(text: clipboardData));
  }

  // Get gender display value from database value
  String getGenderDisplayValue(String? databaseValue) {
    if (databaseValue == null) return 'Nam';

    final genderEntry = genderMap.entries.firstWhere(
      (entry) =>
          entry.value.toString().toUpperCase() == databaseValue.toUpperCase(),
      orElse: () => const MapEntry('Nam', 'MALE'),
    );

    return genderEntry.key;
  }

  // Get role display value from role id
  String getRoleDisplayValue(int roleId) {
    final roleEntry = roleMap.entries.firstWhere(
      (entry) => entry.value == roleId,
      orElse: () => const MapEntry('User', 2),
    );

    return roleEntry.key;
  }

  // Format birthdate from database format to display format
  String formatBirthDateForDisplay(dynamic birthDate) {
    if (birthDate == null) return '';

    if (birthDate is String) {
      try {
        if (birthDate.contains('-')) {
          // Format from yyyy-MM-dd to dd/MM/yyyy
          final date = DateFormat('yyyy-MM-dd').parse(birthDate);
          return DateFormat('dd/MM/yyyy').format(date);
        } else if (birthDate.contains('/')) {
          // Already in dd/MM/yyyy format
          return birthDate;
        }
      } catch (e) {
        return birthDate;
      }
    } else if (birthDate is DateTime) {
      return DateFormat('dd/MM/yyyy').format(birthDate);
    }

    return '';
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
