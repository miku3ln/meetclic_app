import 'package:flutter/material.dart';
import '../theme/configuration/app_text_styles.dart';
import '../theme/configuration/app_theme_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final c = AppThemeTokens.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      colorScheme: ColorScheme.light(
        primary: c.primary,
        secondary: c.secondary,
        surface: c.surface,
        error: c.error,
        onPrimary: c.buttonPrimaryForeground,
        onSecondary: c.textPrimary,
        onSurface: c.textPrimary,
        onError: c.textInverse,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: c.textPrimary,
          height: 1.2,
        ),
      ),
      textTheme: generateTextTheme(c.textPrimary),
      iconTheme: IconThemeData(color: c.iconPrimary),
      dividerColor: c.divider,
      cardColor: c.cardBackground,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.secondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.buttonSecondaryForeground,
          side: BorderSide(color: c.border),
          backgroundColor: c.buttonSecondaryBackground,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.primary),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final c = AppThemeTokens.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      colorScheme: ColorScheme.dark(
        primary: c.primary,
        secondary: c.secondary,
        surface: c.surface,
        error: c.error,
        onPrimary: c.buttonPrimaryForeground,
        onSecondary: c.textPrimary,
        onSurface: c.textPrimary,
        onError: c.textInverse,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: c.textPrimary,
          height: 1.3,
        ),
      ),
      textTheme: generateTextTheme(c.textPrimary),
      iconTheme: IconThemeData(color: c.iconPrimary),
      dividerColor: c.divider,
      cardColor: c.cardBackground,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.buttonSecondaryForeground,
          side: BorderSide(color: c.border),
          backgroundColor: c.buttonSecondaryBackground,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.primary),
        ),
      ),
    );
  }
}
