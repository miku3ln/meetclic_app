import 'package:flutter/material.dart';

class AppThemeTokens {
  final Color primary;
  final Color secondary;

  final Color background;
  final Color surface;
  final Color surfaceMuted;

  final Color textPrimary;
  final Color textSecondary;
  final Color textInverse;

  final Color divider;
  final Color border;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  final Color badge;
  final Color badgeText;

  final Color selectedBackground;
  final Color selectedForeground;

  final Color iconPrimary;
  final Color iconMuted;

  final Color buttonPrimaryBackground;
  final Color buttonPrimaryForeground;

  final Color buttonSecondaryBackground;
  final Color buttonSecondaryForeground;

  const AppThemeTokens({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInverse,
    required this.divider,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.badge,
    required this.badgeText,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.iconPrimary,
    required this.iconMuted,
    required this.buttonPrimaryBackground,
    required this.buttonPrimaryForeground,
    required this.buttonSecondaryBackground,
    required this.buttonSecondaryForeground,
  });

  static const AppThemeTokens light = AppThemeTokens(
    primary: Color(0xFF2E7D32),
    secondary: Color(0xFF4CAF50),

    background: Color(0xFFF7F7F7),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1F1F1),

    textPrimary: Color(0xFF222222),
    textSecondary: Color(0xFF757575),
    textInverse: Color(0xFFFFFFFF),

    divider: Color(0x1F000000),
    border: Color(0x1F000000),

    success: Color(0xFF2E7D32),
    warning: Color(0xFFF9A825),
    error: Color(0xFFC62828),
    info: Color(0xFF1565C0),

    badge: Color(0xFFE8F5E9),
    badgeText: Color(0xFF2E7D32),

    selectedBackground: Color(0x14388E3C),
    selectedForeground: Color(0xFF558B2F),

    iconPrimary: Color(0xFF616161),
    iconMuted: Color(0xFF9E9E9E),

    buttonPrimaryBackground: Color(0xFF2E7D32),
    buttonPrimaryForeground: Color(0xFFFFFFFF),

    buttonSecondaryBackground: Color(0xFFFFFFFF),
    buttonSecondaryForeground: Color(0xFF222222),
  );

  static const AppThemeTokens dark = AppThemeTokens(
    primary: Color(0xFF66BB6A),
    secondary: Color(0xFF81C784),

    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceMuted: Color(0xFF2A2A2A),

    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFBDBDBD),
    textInverse: Color(0xFF121212),

    divider: Color(0x33FFFFFF),
    border: Color(0x33FFFFFF),

    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFCA28),
    error: Color(0xFFEF5350),
    info: Color(0xFF42A5F5),

    badge: Color(0xFF1B5E20),
    badgeText: Color(0xFFC8E6C9),

    selectedBackground: Color(0x2632CD32),
    selectedForeground: Color(0xFFA5D6A7),

    iconPrimary: Color(0xFFE0E0E0),
    iconMuted: Color(0xFF9E9E9E),

    buttonPrimaryBackground: Color(0xFF66BB6A),
    buttonPrimaryForeground: Color(0xFF121212),

    buttonSecondaryBackground: Color(0xFF1E1E1E),
    buttonSecondaryForeground: Color(0xFFF5F5F5),
  );

  static AppThemeTokens of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}


class AppColors {
  // 🎯 Colores principales de marca
  static const Color azulClic = Color(0xFF4C4CFF); // Primary
  static const Color amarilloVital = Color(
    0xFFFFCC00,
  ); // Secondary / Gamificación
  static const Color moradoSuave = Color(0xFF5C5CFF); // Accent
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisOscuro = Color(0xFF2C2C2C);

  // 🧊 Neutros adicionales (por si necesitas)
  static const Color grisMedio = Color(0xFF808080);
  static const Color grisClaro = Color(0xFFE0E0E0);

  // 🎨 Complementarios (basados en teoría de color)
  // Complementarios de azulClic y moradoSuave ≈ amarillos
  static const Color complementoAzul = Color(0xFFFFFE4C); // Amarillo luminoso
  static const Color complementoMorado = Color(
    0xFFFFFE5C,
  ); // Amarillo un poco más cálido

  // Complementario del amarilloVital ≈ azul profundo
  static const Color complementoAmarillo = Color(0xFF0033FF);

  // 🎨 Análogos (±30°)
  // Análogos de azulClic (entre azul-celeste y azul-violeta)
  static const Color analogoAzul1 = Color(0xFF4CA5FF); // Azul más celeste
  static const Color analogoAzul2 = Color(0xFFA54CFF); // Lila/violáceo

  // Análogos de amarilloVital (naranja y verde lima)
  static const Color analogoAmarillo1 = Color(0xFFFF4C00); // Naranja intenso
  static const Color analogoAmarillo2 = Color(0xFFB2FF00); // Verde lima

  // 🎨 Triádicos (triángulo de color respecto a azulClic)
  static const Color triadico1 = Color(0xFFFF4C4C); // Rojo intenso
  static const Color triadico2 = Color(0xFF4CFF4C); // Verde vibrante

  // ⚠️ Colores funcionales (semánticos)
  static const Color rojoMarca = Color(0xFFB80000); // Errores / alertas graves
  static const Color verdeSalud = Color(0xFF28A745); // Éxito / confirmación
  static const Color warning = Color(0xFFFFA000); // Advertencias suaves

  // Neutros para LIGHT (más amables y coherentes con azulClic)
  static const Color textPrimaryLight = Color(0xFF2F3153); // gris azulado
  static const Color textSecondaryLight = Color(0xFF6C7088); // gris suave
  static const Color borderSoft = Color(0xFFE2E4FF); // borde sutil azulado
  // 🌈 Fondo degradado institucional
  static const Gradient fondoGradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azulClic, moradoSuave],
  );
}
