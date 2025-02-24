import 'package:flutter/material.dart';
import 'routing/app_routes.dart';
import 'ui/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, this.initialRoute = AppRoutes.login});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EzStore Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
