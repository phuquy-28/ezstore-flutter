import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.heading,
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),
        ),
      );

  static ThemeData get dark => ThemeData.dark();
}
