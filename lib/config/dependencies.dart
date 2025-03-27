import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:ezstore_flutter/data/repositories/category_repository.dart';
import 'package:ezstore_flutter/data/repositories/dashboard_repository.dart';
import 'package:ezstore_flutter/data/repositories/product_repository.dart';
import 'package:ezstore_flutter/data/repositories/user_repository.dart';
import 'package:ezstore_flutter/data/services/api_service.dart';
import 'package:ezstore_flutter/data/services/auth_service.dart';
import 'package:ezstore_flutter/data/services/category_service.dart';
import 'package:ezstore_flutter/data/services/dashboard_service.dart';
import 'package:ezstore_flutter/data/services/product_service.dart';
import 'package:ezstore_flutter/data/services/shared_preference_service.dart';
import 'package:ezstore_flutter/data/services/upload_service.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:ezstore_flutter/ui/category/view_models/add_category_view_model.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_detail_view_model.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_screen_view_model.dart';
import 'package:ezstore_flutter/ui/drawer/viewmodel/drawer_viewmodel.dart';
import 'package:ezstore_flutter/ui/product/view_models/add_product_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/edit_product_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_detail_view_model.dart';
import 'package:ezstore_flutter/ui/product/view_models/product_screen_view_model.dart';
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

    // ViewModels
    ChangeNotifierProvider(
        create: (context) => DrawerViewModel(
              context.read<AuthRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => UserInfoProvider(
              context.read<UserRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => CategoryScreenViewModel(
              context.read<CategoryRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => CategoryDetailViewModel(
              context.read<CategoryRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => AddCategoryViewModel(
              context.read<CategoryRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => ProductScreenViewModel(
              context.read<ProductRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => ProductDetailViewModel(
              context.read<ProductRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => EditProductViewModel(
              context.read<ProductRepository>(),
              context.read<CategoryRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => AddProductViewModel(
              context.read<ProductRepository>(),
              context.read<CategoryRepository>(),
            )),
  ];
}
