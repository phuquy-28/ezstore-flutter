import 'package:ezstore_flutter/data/repositories/dashboard_repository.dart';
import 'package:ezstore_flutter/data/services/dashboard_service.dart';
import 'package:ezstore_flutter/data/services/user_service.dart';
import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/services/shared_preference_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../ui/auth/login/view_model/login_viewmodel.dart';
import '../data/repositories/user_repository.dart';
import '../ui/drawer/viewmodel/drawer_viewmodel.dart';
import '../ui/dashboard/view_model/dashboard_viewmodel.dart';

List<SingleChildWidget> get providers {
  return [
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
    ChangeNotifierProvider(
        create: (context) => LoginViewModel(
              context.read<AuthRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => DrawerViewModel(
              context.read<AuthRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => UserInfoProvider(
              context.read<UserRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => DashboardViewModel(
              context.read<DashboardRepository>(),
            )),
    ChangeNotifierProvider(
        create: (context) => UserScreenViewModel(
              context.read<UserRepository>(),
            )),
  ];
}
