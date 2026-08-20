import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutral50,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.secondary500,
        surface: AppColors.neutral50,
        error: AppColors.error500,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.neutral900,
        onError: AppColors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: AppColors.neutral900),
        displayMedium: AppTextStyles.h1.copyWith(color: AppColors.neutral900),
        displaySmall: AppTextStyles.h2.copyWith(color: AppColors.neutral900),
        headlineLarge: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
        headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.neutral900),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.neutral700),
        bodyMedium: AppTextStyles.body.copyWith(color: AppColors.neutral700),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.white),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
        iconTheme: const IconThemeData(color: AppColors.neutral900),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
