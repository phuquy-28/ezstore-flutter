import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:ezstore_flutter/data/repositories/dashboard_repository.dart';
import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/data/repositories/order_repository.dart';
import 'package:ezstore_flutter/ui/auth/login/view_model/login_viewmodel.dart';
import 'package:ezstore_flutter/ui/auth/login/widgets/login_screen.dart';
import 'package:ezstore_flutter/ui/category/widgets/add_category_screen.dart';
import 'package:ezstore_flutter/ui/category/widgets/category_detail_screen.dart';
import 'package:ezstore_flutter/ui/category/widgets/category_screen.dart';
import 'package:ezstore_flutter/ui/core/shared/error_screen.dart';
import 'package:ezstore_flutter/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:ezstore_flutter/ui/dashboard/widgets/dashboard_screen.dart';
import 'package:ezstore_flutter/ui/order/view_models/order_detail_viewmodel.dart';
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
import 'package:ezstore_flutter/ui/order/view_models/order_screen_viewmodel.dart';
import 'package:ezstore_flutter/ui/order/widgets/order_detail_screen.dart';
import 'package:ezstore_flutter/ui/order/view_models/update_order_viewmodel.dart';
import 'package:ezstore_flutter/ui/order/widgets/update_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Application routing configuration class
class AppRoutes {
  // Authentication routes
  static const String login = '/login';

  // Main routes
  static const String dashboard = '/dashboard';
  static const String error = '/error';

  // Product routes
  static const String products = '/products';
  static const String productDetail = '/productDetail';
  static const String editProduct = '/editProduct';
  static const String addProduct = '/addProduct';

  // Category routes
  static const String categories = '/categories';
  static const String categoryDetail = '/categoryDetail';
  static const String addCategory = '/addCategory';

  // User routes
  static const String users = '/users';
  static const String userDetail = '/userDetail';
  static const String addUser = '/addUser';

  // Other feature routes
  static const String reviews = '/reviews';
  static const String orders = '/orders';
  static const String orderDetail = '/orderDetail';
  static const String updateOrder = '/updateOrder';
  static const String promotions = '/promotions';

  /// Main route generator function used by the Flutter navigator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    // Helper function to create MaterialPageRoute with consistent settings
    MaterialPageRoute<dynamic> _createRoute(Widget screen) {
      return MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
      );
    }

    switch (settings.name) {
      // Auth routes
      case login:
        return _handleLoginRoute(settings);

      // Main routes
      case dashboard:
        return _handleDashboardRoute(settings);

      // Product routes
      case products:
        return _handleProductsRoute(settings);
      case productDetail:
        return _handleProductDetailRoute(settings, args);
      case editProduct:
        return _handleEditProductRoute(settings, args);
      case addProduct:
        return _handleAddProductRoute(settings);

      // Category routes
      case categories:
        return _handleCategoriesRoute(settings);
      case categoryDetail:
        return _handleCategoryDetailRoute(settings, args);
      case addCategory:
        return _handleAddCategoryRoute(settings);

      // User routes
      case users:
        return _handleUsersRoute(settings);
      case userDetail:
        return _handleUserDetailRoute(settings, args);
      case addUser:
        return _handleAddUserRoute(settings);

      // Simple routes that don't need special handling
      case reviews:
        return _createRoute(const ReviewScreen());
      case orders:
        return _handleOrdersRoute(settings);
      case orderDetail:
        return _handleOrderDetailRoute(settings, args);
      case updateOrder:
        return _handleUpdateOrderRoute(settings, args);
      case promotions:
        return _createRoute(const PromotionScreen());

      // Error handling routes
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

  // Authentication route handlers
  static Route<dynamic> _handleLoginRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final authRepository =
            Provider.of<AuthRepository>(context, listen: false);
        final loginViewModel = LoginViewModel(authRepository);
        return LoginScreen(viewModel: loginViewModel);
      },
      settings: settings,
    );
  }

  // Main route handlers
  static Route<dynamic> _handleDashboardRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final dashboardRepository =
            Provider.of<DashboardRepository>(context, listen: false);
        final dashboardViewModel = DashboardViewModel(dashboardRepository);
        return DashboardScreen(viewModel: dashboardViewModel);
      },
      settings: settings,
    );
  }

  // Product route handlers
  static Route<dynamic> _handleProductsRoute(RouteSettings settings) {
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
  }

  static Route<dynamic> _handleProductDetailRoute(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
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
  }

  static Route<dynamic> _handleEditProductRoute(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
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
  }

  static Route<dynamic> _handleAddProductRoute(RouteSettings settings) {
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
  }

  // Category route handlers
  static Route<dynamic> _handleCategoriesRoute(RouteSettings settings) {
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
  }

  static Route<dynamic> _handleCategoryDetailRoute(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
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
  }

  static Route<dynamic> _handleAddCategoryRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final categoryRepository =
            Provider.of<CategoryRepository>(context, listen: false);
        final addCategoryViewModel = AddCategoryViewModel(categoryRepository);
        return AddCategoryScreen(viewModel: addCategoryViewModel);
      },
      settings: settings,
    );
  }

  // User route handlers
  static Route<dynamic> _handleUsersRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final userRepository =
            Provider.of<UserRepository>(context, listen: false);
        final userScreenViewModel = UserScreenViewModel(userRepository);
        return UserScreen(viewModel: userScreenViewModel);
      },
      settings: settings,
    );
  }

  static Route<dynamic> _handleUserDetailRoute(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
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
  }

  static Route<dynamic> _handleAddUserRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final userRepository =
            Provider.of<UserRepository>(context, listen: false);
        final addUserViewModel = AddUserViewModel(userRepository);
        return AddUserScreen(viewModel: addUserViewModel);
      },
      settings: settings,
    );
  }

  // Add this method for handling orders route
  static Route<dynamic> _handleOrdersRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final orderRepository =
            Provider.of<OrderRepository>(context, listen: false);
        final orderScreenViewModel = OrderScreenViewModel(orderRepository);
        return OrderScreen(viewModel: orderScreenViewModel);
      },
      settings: settings,
    );
  }

  // Add this method for handling order detail route
  static Route<dynamic> _handleOrderDetailRoute(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
    final orderId = args?['id'] as int?;
    return MaterialPageRoute(
      builder: (context) {
        final orderRepository =
            Provider.of<OrderRepository>(context, listen: false);
        final orderDetailViewModel = OrderDetailViewModel(orderRepository);
        return OrderDetailScreen(
          viewModel: orderDetailViewModel,
          orderId: orderId ?? 0,
        );
      },
      settings: settings,
    );
  }

  // Add this method for handling update order route
  static Route<dynamic> _handleUpdateOrderRoute(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
    final orderId = args?['id'] as int?;
    return MaterialPageRoute(
      builder: (context) {
        final orderRepository =
            Provider.of<OrderRepository>(context, listen: false);
        final updateOrderViewModel = UpdateOrderViewModel(orderRepository);
        return UpdateOrderScreen(
          viewModel: updateOrderViewModel,
          orderId: orderId ?? 0,
        );
      },
      settings: settings,
    );
  }
}
