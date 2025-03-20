import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';

class ApiConstants {
  // Base URL
  static String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8080/api/v1'
      : 'http://localhost:8080/api/v1';

  // Auth endpoints
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';

  // Workspace endpoints
  static const String login = '/workspace/login';
  static const String dashboard = '/workspace/dashboard';
  static const String revenueByMonth = '/workspace/revenue-by-month';

  // User endpoints
  static const String users = '/users';
  static const String info = '/users/info';
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String uploadImage = '/upload-images';

  // Category endpoints
  static const String categories = '/categories';

  // Product endpoints
  static const String products = '/products';
  static const String productDetail = '/products/'; // + id

  // Order endpoints
  static const String orders = '/orders';
  static const String orderDetail = '/orders/'; // + id
}

class AppColors {
  static const primary = Color(0xFF1E1E1E);
  static const background = Color(0xFFF5F5F5);
  static final secondary = Colors.grey[200]!;

  // Thêm màu mới
  static const surface = Colors.white;
  static const inputBorder = Color(0xFFE0E0E0);
  static const inputBackground = Colors.white;
  static const textPrimary = Color(0xFF1E1E1E);
  static const textSecondary = Color(0xFF757575);

  // Role colors
  static const roleAdmin = Colors.red;
  static const roleManager = Colors.blue;
  static const roleStaff = Colors.grey;
  static const roleUser = Colors.grey;
}

class AppStrings {
  static const appName = 'EzStore';
  static const welcome = 'Xin chào';
  static const dashboard = 'Bảng điều khiển';
  static const products = 'Sản phẩm';
  static const reviews = 'Đánh giá';
  static const orders = 'Đơn hàng';
  static const categories = 'Danh mục';
  static const promotions = 'Khuyến mãi';
  static const users = 'Người dùng';
  static const logout = 'Đăng xuất';

  // User roles
  static const roleAdmin = 'ADMIN';
  static const roleManager = 'MANAGER';
  static const roleStaff = 'STAFF';
  static const roleUser = 'USER';

  // Gender options
  static const genderMale = 'Nam';
  static const genderFemale = 'Nữ';

  // Delete confirmation
  static const deleteUserConfirmation = 'Bạn có chắc chắn muốn xóa người dùng';
}

class AppSizes {
  static const double paddingLarge = 24.0;
  static const double paddingNormal = 16.0;
  static const double paddingSmall = 8.0;

  static const double radiusLarge = 16.0;
  static const double radiusNormal = 8.0;

  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
}

// ANSI escape codes for colors
class AppLogs {
  static const String reset = '\x1B[0m';
  static const String green = '\x1B[32m';
  static const String red = '\x1B[31m';
  static const String cyan = '\x1B[36m';
}

class AppTextStyles {
  static final heading = GoogleFonts.lora(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
}

class AppLists {
  static const userRoles = [
    AppStrings.roleAdmin,
    AppStrings.roleUser,
    AppStrings.roleManager,
    AppStrings.roleStaff
  ];

  static const genders = [AppStrings.genderMale, AppStrings.genderFemale];
}
