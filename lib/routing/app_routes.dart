import 'package:ezstore_flutter/ui/review/widgets/review_screen.dart';
import 'package:ezstore_flutter/ui/user/widgets/user_detail_screen.dart';
import 'package:flutter/material.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/dashboard/widgets/dashboard_screen.dart';
import '../ui/product/widgets/product_screen.dart';
import '../ui/user/widgets/user_screen.dart';
import '../ui/category/widgets/category_screen.dart';
import '../ui/order/widgets/order_screen.dart';
import '../ui/promotion/widgets/promotion_screen.dart';
import '../ui/core/shared/error_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String reviews = '/reviews';
  static const String orders = '/orders';
  static const String categories = '/categories';
  static const String users = '/users';
  static const String userDetail = '/userDetail';
  static const String promotions = '/promotions';
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
        return _createRoute(const ProductScreen());
      case reviews:
        return _createRoute(const ReviewScreen());
      case orders:
        return _createRoute(const OrderScreen());
      case categories:
        return _createRoute(const CategoryScreen());
      case users:
        return _createRoute(const UserScreen());
      case userDetail:
        final userId = args?['id'];
        return _createRoute(
            UserDetailScreen(isEditMode: false, userId: userId));
      case promotions:
        return _createRoute(const PromotionScreen());
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
