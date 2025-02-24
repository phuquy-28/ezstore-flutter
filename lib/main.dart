import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'data/services/shared_preference_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceService.init();

  final prefService = SharedPreferenceService();
  final initialRoute =
      prefService.isLoggedIn() ? AppRoutes.dashboard : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}
