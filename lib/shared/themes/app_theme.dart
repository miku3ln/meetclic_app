import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.grisOscuro,
      primaryColor: AppColors.azulClic,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.blanco,
          height: 1.3,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.azulClic,
        secondary: AppColors.amarilloVital,
        background: AppColors.grisOscuro,
        surface: AppColors.moradoSuave,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.grisOscuro,
        onBackground: AppColors.blanco,
        onSurface: AppColors.blanco,
        error: AppColors.rojoMarca,
      ),
      textTheme: generateTextTheme(AppColors.blanco),
      iconTheme: const IconThemeData(color: AppColors.blanco),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amarilloVital,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.blanco,
      primaryColor: AppColors.azulClic,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blanco,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
          height: 1.2,
        ),
      ),

      colorScheme: const ColorScheme.light(
        primary: AppColors.azulClic,
        secondary: AppColors.amarilloVital,
        background: AppColors.blanco,
        surface: AppColors.blanco,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.rojoMarca,
      ),

      textTheme: generateTextTheme(AppColors.textPrimaryLight),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blanco,
        selectedItemColor: AppColors.azulClic,
        unselectedItemColor: AppColors.textSecondaryLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amarilloVital,
      ),
    );
  }
}
