import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:ezstore_flutter/data/repositories/dashboard_repository.dart';
import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/ui/auth/login/view_model/login_viewmodel.dart';
import 'package:ezstore_flutter/ui/auth/login/widgets/login_screen.dart';
import 'package:ezstore_flutter/ui/category/widgets/add_category_screen.dart';
import 'package:ezstore_flutter/ui/category/widgets/category_detail_screen.dart';
import 'package:ezstore_flutter/ui/category/widgets/category_screen.dart';
import 'package:ezstore_flutter/ui/core/shared/error_screen.dart';
import 'package:ezstore_flutter/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:ezstore_flutter/ui/dashboard/widgets/dashboard_screen.dart';
import 'package:ezstore_flutter/ui/order/widgets/order_screen.dart';
import 'package:ezstore_flutter/ui/product/widgets/add_product_screen.dart';
import 'package:ezstore_flutter/ui/product/widgets/edit_product_screen.dart';
import 'package:ezstore_flutter/ui/product/widgets/product_detail_screen.dart';
import 'package:ezstore_flutter/ui/product/widgets/product_screen.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/promotion_screen.dart';
import 'package:ezstore_flutter/ui/review/widgets/review_screen.dart';
import 'package:ezstore_flutter/ui/user/view_models/add_user_view_model.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_detail_view_model.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import 'package:ezstore_flutter/ui/user/widgets/add_user_screen.dart';
import 'package:ezstore_flutter/ui/user/widgets/user_detail_screen.dart';
import 'package:ezstore_flutter/ui/user/widgets/user_screen.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_screen_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/add_product_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_detail_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/edit_product_view_model.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_screen_view_model.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_detail_view_model.dart';
import 'package:ezstore_flutter/ui/category/view_models/add_category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String productDetail = '/productDetail';
  static const String editProduct = '/editProduct';
  static const String addProduct = '/addProduct';
  static const String reviews = '/reviews';
  static const String orders = '/orders';
  static const String categories = '/categories';
  static const String categoryDetail = '/categoryDetail';
  static const String addCategory = '/addCategory';
  static const String users = '/users';
  static const String userDetail = '/userDetail';
  static const String addUser = '/addUser';
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
        return MaterialPageRoute(
          builder: (context) {
            final authRepository =
                Provider.of<AuthRepository>(context, listen: false);
            final loginViewModel = LoginViewModel(authRepository);
            return LoginScreen(viewModel: loginViewModel);
          },
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (context) {
            final dashboardRepository =
                Provider.of<DashboardRepository>(context, listen: false);
            final dashboardViewModel = DashboardViewModel(dashboardRepository);
            return DashboardScreen(viewModel: dashboardViewModel);
          },
          settings: settings,
        );

      // Product case
      case products:
        return MaterialPageRoute(
          builder: (context) {
            final productRepository =
                Provider.of<ProductRepository>(context, listen: false);
            final productScreenViewModel =
                ProductScreenViewModel(productRepository);
            return ProductScreen(viewModel: productScreenViewModel);
          },
          settings: settings,
        );
      case productDetail:
        final productId = args?['id'];
        return MaterialPageRoute(
          builder: (context) {
            final productRepository =
                Provider.of<ProductRepository>(context, listen: false);
            final productDetailViewModel =
                ProductDetailViewModel(productRepository);
            return ProductDetailScreen(
              viewModel: productDetailViewModel,
              productId: productId,
            );
          },
          settings: settings,
        );
      case editProduct:
        final productId = args?['id'];
        return MaterialPageRoute(
          builder: (context) {
            final productRepository =
                Provider.of<ProductRepository>(context, listen: false);
            final categoryRepository =
                Provider.of<CategoryRepository>(context, listen: false);
            final editProductViewModel = EditProductViewModel(
              productRepository,
              categoryRepository,
            );
            return EditProductScreen(
              viewModel: editProductViewModel,
              productId: productId,
            );
          },
          settings: settings,
        );
      case addProduct:
        return MaterialPageRoute(
          builder: (context) {
            final productRepository =
                Provider.of<ProductRepository>(context, listen: false);
            final categoryRepository =
                Provider.of<CategoryRepository>(context, listen: false);
            final addProductViewModel = AddProductViewModel(
              productRepository,
              categoryRepository,
            );
            return AddProductScreen(viewModel: addProductViewModel);
          },
          settings: settings,
        );

      // Review case
      case reviews:
        return _createRoute(const ReviewScreen());

      // Order case
      case orders:
        return _createRoute(const OrderScreen());

      // Category case
      case categories:
        return MaterialPageRoute(
          builder: (context) {
            final categoryRepository =
                Provider.of<CategoryRepository>(context, listen: false);
            final categoryScreenViewModel =
                CategoryScreenViewModel(categoryRepository);
            return CategoryScreen(viewModel: categoryScreenViewModel);
          },
          settings: settings,
        );
      case categoryDetail:
        final categoryId = args?['id'];
        return MaterialPageRoute(
          builder: (context) {
            final categoryRepository =
                Provider.of<CategoryRepository>(context, listen: false);
            final categoryDetailViewModel =
                CategoryDetailViewModel(categoryRepository);
            return CategoryDetailScreen(
              viewModel: categoryDetailViewModel,
              isEditMode: false,
              categoryId: categoryId,
            );
          },
          settings: settings,
        );
      case addCategory:
        return MaterialPageRoute(
          builder: (context) {
            final categoryRepository =
                Provider.of<CategoryRepository>(context, listen: false);
            final addCategoryViewModel =
                AddCategoryViewModel(categoryRepository);
            return AddCategoryScreen(viewModel: addCategoryViewModel);
          },
          settings: settings,
        );

      // User case
      case users:
        return MaterialPageRoute(
          builder: (context) {
            final userRepository =
                Provider.of<UserRepository>(context, listen: false);
            final userScreenViewModel = UserScreenViewModel(userRepository);
            return UserScreen(viewModel: userScreenViewModel);
          },
          settings: settings,
        );
      case userDetail:
        final userId = args?['id'];
        return MaterialPageRoute(
          builder: (context) {
            final userRepository =
                Provider.of<UserRepository>(context, listen: false);
            final userDetailViewModel = UserDetailViewModel(userRepository);
            return UserDetailScreen(
              viewModel: userDetailViewModel,
              isEditMode: false,
              userId: userId,
            );
          },
          settings: settings,
        );
      case addUser:
        return MaterialPageRoute(
          builder: (context) {
            final userRepository =
                Provider.of<UserRepository>(context, listen: false);
            final addUserViewModel = AddUserViewModel(userRepository);
            return AddUserScreen(viewModel: addUserViewModel);
          },
          settings: settings,
        );

      // Promotion case
      case promotions:
        return _createRoute(const PromotionScreen());

      // Error case
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
