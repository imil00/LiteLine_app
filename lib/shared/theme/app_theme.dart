import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: AppColors.chatBackground, // Used for cards, etc.
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.chatBackground,
    ), // <-- Ganti dari bottomAppBarColor ke bottomAppBarTheme
    appBarTheme: AppBarTheme( // <-- Hapus const supaya bisa pakai copyWith
      backgroundColor: AppColors.backgroundColor,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.appBarTitle,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textLight),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryGreen,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textWhite,
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.buttonLarge, // Ganti ke buttonLarge atau yang kamu punya
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: AppTextStyles.buttonLarge.copyWith(fontWeight: FontWeight.normal),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.bubbleReceived,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primaryGreen,
      unselectedLabelColor: AppColors.textLight,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 3.0),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
        .copyWith(
          secondary: AppColors.lightGreen,
          background: AppColors.backgroundColor,
          error: AppColors.error,
        ),
    shadowColor: Colors.black.withOpacity(0.05),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface,
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.darkSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: AppColors.darkText),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.textLight),
      bodySmall: TextStyle(color: AppColors.textLight),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryGreen,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.darkText),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: AppTextStyles.buttonLarge.copyWith(fontWeight: FontWeight.normal, color: AppColors.darkText),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.darkBackground,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.darkText),
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primaryGreen,
      unselectedLabelColor: AppColors.textLight,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 3.0),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
        .copyWith(
          secondary: AppColors.lightGreen,
          background: AppColors.darkBackground,
          error: AppColors.error,
          brightness: Brightness.dark,
        ),
    shadowColor: Colors.black.withOpacity(0.3),
  );
}
