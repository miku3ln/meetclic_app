import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🎨 Estilos tipográficos base sin color aplicado
class AppTextStyles {
  static const TextStyle bodyMedium = TextStyle(fontSize: 14.0, height: 1.4);
  static const TextStyle titleLarge = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, height: 1.3);
  static const TextStyle displayLarge = TextStyle(fontSize: 57.0, height: 1.12);
  static const TextStyle displayMedium = TextStyle(fontSize: 45.0, height: 1.15);
  static const TextStyle displaySmall = TextStyle(fontSize: 36.0, height: 1.2);
  static const TextStyle headlineLarge = TextStyle(fontSize: 32.0, height: 1.25);
  static const TextStyle headlineMedium = TextStyle(fontSize: 28.0, height: 1.28);
  static const TextStyle headlineSmall = TextStyle(fontSize: 24.0, height: 1.3);
  static const TextStyle titleMedium = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle titleSmall = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16.0, height: 1.4);
  static const TextStyle bodySmall = TextStyle(fontSize: 12.0, height: 1.3);
  static const TextStyle labelLarge = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelMedium = TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, height: 1.3);
  static const TextStyle labelSmall = TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, height: 1.3);
}

/// 🎨 Genera el TextTheme aplicando el color recibido
TextTheme generateTextTheme(Color color) {
  return TextTheme(
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: color),
    titleLarge: AppTextStyles.titleLarge.copyWith(color: color),
    displayLarge: AppTextStyles.displayLarge.copyWith(color: color),
    displayMedium: AppTextStyles.displayMedium.copyWith(color: color),
    displaySmall: AppTextStyles.displaySmall.copyWith(color: color),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(color: color),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(color: color),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(color: color),
    titleMedium: AppTextStyles.titleMedium.copyWith(color: color),
    titleSmall: AppTextStyles.titleSmall.copyWith(color: color),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: color),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: color),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: color),
    labelMedium: AppTextStyles.labelMedium.copyWith(color: color),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: color),
  );
}
