import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.grisOscuro,
      primaryColor: AppColors.azulClic,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.blanco,
        elevation: 0,
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
        onSecondary: AppColors.amarilloVital,
        onBackground: AppColors.blanco,
        onSurface: AppColors.blanco,
        error: AppColors.rojoMarca,
      ),
      textTheme: generateTextTheme(AppColors.blanco),
      iconTheme: const IconThemeData(color: AppColors.blanco),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.amarilloVital),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.blanco,
      primaryColor: AppColors.azulClic,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.blanco,
          height: 1.2,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.azulClic,
        secondary: AppColors.amarilloVital,
        background: AppColors.blanco,
        surface: AppColors.moradoSuave,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.grisOscuro,
        onBackground: AppColors.grisOscuro,
        onSurface: AppColors.grisOscuro,
        error: AppColors.rojoMarca,
      ),
      textTheme: generateTextTheme(AppColors.grisOscuro),
      iconTheme: const IconThemeData(color: AppColors.grisOscuro),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.amarilloVital),
    );
  }
}
