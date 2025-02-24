import 'package:flutter/material.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/dashboard/widgets/dashboard_screen.dart';
import '../ui/product/widgets/product_screen.dart';
import '../ui/core/shared/error_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String reviews = '/reviews';
  static const String orders = '/orders';
  static const String categories = '/categories';
  static const String users = '/users';
  static const String error = '/error';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    MaterialPageRoute _createRoute(Widget screen) {
      return MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
      );
    }

    switch (settings.name) {
      case login:
        return _createRoute(const LoginScreen());
      case dashboard:
        return _createRoute(const DashboardScreen());
      case products:
        return _createRoute(const ProductsScreen());
      // case reviews:
      //   return _createRoute(const ReviewsScreen());
      // case orders:
      //   return _createRoute(const OrdersScreen());
      // case categories:
      //   return _createRoute(const CategoriesScreen());
      // case users:
      //   return _createRoute(const UsersScreen());
      case error:
        return _createRoute(ErrorScreen(
          title: args?['title'] as String?,
          message: args?['message'] as String?,
        ));
      default:
        return _createRoute(const ErrorScreen(
          title: 'Không tìm thấy trang',
          message: 'Trang bạn đang tìm kiếm không tồn tại.',
        ));
    }
  }
}
