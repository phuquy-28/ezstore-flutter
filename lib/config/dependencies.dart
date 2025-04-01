import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/data/repositories/dashboard_repository.dart';
import 'package:ezstore_flutter/data/repositories/order_repository.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/data/services/auth_service.dart';
import 'package:ezstore_flutter/data/services/category_service.dart';
import 'package:ezstore_flutter/data/services/dashboard_service.dart';
import 'package:ezstore_flutter/data/services/order_service.dart';
import 'package:ezstore_flutter/data/services/product_service.dart';
import 'package:ezstore_flutter/data/services/shared_preference_service.dart';
import 'package:ezstore_flutter/data/services/upload_service.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:ezstore_flutter/ui/drawer/viewmodel/drawer_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providers {
  return [
    // Services
    Provider(create: (context) => SharedPreferenceService()),
    Provider(
        create: (context) =>
            ApiService(context.read<SharedPreferenceService>())),
    Provider(
        create: (context) => AuthService(
              context.read<ApiService>(),
              context.read<SharedPreferenceService>(),
            )),
    Provider(create: (context) => UserService(context.read<ApiService>())),
    Provider(create: (context) => DashboardService(context.read<ApiService>())),
    Provider(create: (context) => CategoryService(context.read<ApiService>())),
    Provider(
        create: (context) => UploadService(
              context.read<ApiService>(),
            )),
    Provider(create: (context) => ProductService(context.read<ApiService>())),
    Provider(create: (context) => OrderService(context.read<ApiService>())),

    // Repositories
    Provider(
        create: (context) => AuthRepository(
              context.read<AuthService>(),
              context.read<SharedPreferenceService>(),
            )),
    Provider(
        create: (context) => UserRepository(
              context.read<UserService>(),
            )),
    Provider(
        create: (context) => DashboardRepository(
              context.read<DashboardService>(),
            )),
    Provider(
        create: (context) => CategoryRepository(
              context.read<CategoryService>(),
              context.read<UploadService>(),
            )),
    Provider(
        create: (context) => ProductRepository(
              context.read<ProductService>(),
              context.read<UploadService>(),
            )),
    Provider(
        create: (context) => OrderRepository(
              context.read<OrderService>(),
            )),

    // ViewModels
    ChangeNotifierProvider(
        create: (context) => DrawerViewModel(
              context.read<AuthRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => UserInfoProvider(
              context.read<UserRepository>(),
            )),
  ];
}
