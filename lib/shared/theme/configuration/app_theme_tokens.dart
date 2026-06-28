import 'package:flutter/material.dart';

class AppThemeTokens {
  final Color primary;
  final Color secondary;
  final Color accent;

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color cardBackground;

  final Color textPrimary;
  final Color textSecondary;
  final Color textInverse;

  final Color divider;
  final Color border;
  final Color shadow;
  final Color overlay;
  final Color disabled;
  final Color white;

  final Color success;
  final Color successBackground;
  final Color warning;
  final Color warningBackground;
  final Color error;
  final Color errorBackground;
  final Color info;
  final Color infoBackground;

  final Color badge;
  final Color badgeText;

  final Color selectedBackground;
  final Color selectedForeground;
  final Color hoverBackground;

  final Color iconPrimary;
  final Color iconMuted;

  final Color buttonPrimaryBackground;
  final Color buttonPrimaryForeground;
  final Color buttonSecondaryBackground;
  final Color buttonSecondaryForeground;

  final Color inputFill;
  final Color link;

  const AppThemeTokens({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.cardBackground,
    required this.textPrimary,
    required this.white,

    required this.textSecondary,
    required this.textInverse,
    required this.divider,
    required this.border,
    required this.shadow,
    required this.overlay,
    required this.disabled,
    required this.success,
    required this.successBackground,
    required this.warning,
    required this.warningBackground,
    required this.error,
    required this.errorBackground,
    required this.info,
    required this.infoBackground,
    required this.badge,
    required this.badgeText,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.hoverBackground,
    required this.iconPrimary,
    required this.iconMuted,
    required this.buttonPrimaryBackground,
    required this.buttonPrimaryForeground,
    required this.buttonSecondaryBackground,
    required this.buttonSecondaryForeground,
    required this.inputFill,
    required this.link,
  });

  static Color shade(Color color, int percent) {
    assert(percent >= 0 && percent <= 100);

    return Color.lerp(color, Colors.white, percent / 100)!;
  }

  static const AppThemeTokens light = AppThemeTokens(
    white: AppColors.blanco,
    primary: AppColors.azulClic,
    secondary: AppColors.amarilloVital,
    accent: AppColors.moradoSuave,

    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceMuted: AppColors.surfaceMutedLight,
    cardBackground: AppColors.surfaceLight,

    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textInverse: AppColors.blanco,

    divider: AppColors.borderSoftLight,
    border: AppColors.borderSoftLight,
    shadow: Color(0x14000000),
    overlay: Color(0x66000000),
    disabled: Color(0xFFB0B3C7),

    success: AppColors.verdeSalud,
    successBackground: AppColors.successLightBg,
    warning: AppColors.naranjaWarning,
    warningBackground: AppColors.warningLightBg,
    error: AppColors.rojoMarca,
    errorBackground: AppColors.errorLightBg,
    info: AppColors.azulInfo,
    infoBackground: AppColors.infoLightBg,

    badge: Color(0xFFE8EAFF),
    badgeText: AppColors.azulClic,

    selectedBackground: Color(0x144C4CFF),
    selectedForeground: AppColors.azulClic,
    hoverBackground: Color(0x0D4C4CFF),

    iconPrimary: AppColors.textPrimaryLight,
    iconMuted: AppColors.textSecondaryLight,

    buttonPrimaryBackground: AppColors.azulClic,
    buttonPrimaryForeground: AppColors.blanco,
    buttonSecondaryBackground: AppColors.blanco,
    buttonSecondaryForeground: AppColors.textPrimaryLight,

    inputFill: Color(0xFFF6F7FC),
    link: AppColors.azulClic,
  );

  static const AppThemeTokens dark = AppThemeTokens(
    primary: AppColors.amarilloVital,
    secondary: AppColors.azulClic,
    accent: AppColors.moradoSuave,
    white: AppColors.blanco,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceMuted: AppColors.surfaceMutedDark,
    cardBackground: AppColors.surfaceDark,

    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textInverse: AppColors.grisOscuro,

    divider: AppColors.borderSoftDark,
    border: AppColors.borderSoftDark,
    shadow: Color(0x33000000),
    overlay: Color(0x99000000),
    disabled: Color(0xFF6C7088),

    success: Color(0xFF5BD37A),
    successBackground: AppColors.successDarkBg,
    warning: Color(0xFFFFC74D),
    warningBackground: AppColors.warningDarkBg,
    error: Color(0xFFFF7B7B),
    errorBackground: AppColors.errorDarkBg,
    info: Color(0xFF6EB6FF),
    infoBackground: AppColors.infoDarkBg,

    badge: Color(0xFF31365A),
    badgeText: AppColors.amarilloVital,

    selectedBackground: Color(0x26FFCC00),
    selectedForeground: AppColors.amarilloVital,
    hoverBackground: Color(0x14FFFFFF),

    iconPrimary: AppColors.textPrimaryDark,
    iconMuted: AppColors.textSecondaryDark,

    buttonPrimaryBackground: AppColors.amarilloVital,
    buttonPrimaryForeground: AppColors.grisOscuro,
    buttonSecondaryBackground: AppColors.surfaceDark,
    buttonSecondaryForeground: AppColors.textPrimaryDark,

    inputFill: Color(0xFF24283A),
    link: AppColors.amarilloVital,
  );

  static AppThemeTokens of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

class AppColors {
  AppColors._();

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
  static const Color naranjaWarning = Color(0xFFFFA000);
  static const Color azulInfo = Color(0xFF2196F3);

  static const Color borderSoftLight = Color(0xFFE2E4FF);
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMutedLight = Color(0xFFF3F4FA);

  // Dark neutrals
  static const Color textPrimaryDark = Color(0xFFF4F5FF);
  static const Color textSecondaryDark = Color(0xFFB6B9D1);
  static const Color borderSoftDark = Color(0xFF35385A);
  static const Color backgroundDark = Color(0xFF12131C);
  static const Color surfaceDark = Color(0xFF1C1E2B);
  static const Color surfaceMutedDark = Color(0xFF262938);

  // Estados derivados
  static const Color successLightBg = Color(0xFFE8F5E9);
  static const Color warningLightBg = Color(0xFFFFF8E1);
  static const Color errorLightBg = Color(0xFFFFEBEE);
  static const Color infoLightBg = Color(0xFFE3F2FD);

  static const Color successDarkBg = Color(0xFF12351C);
  static const Color warningDarkBg = Color(0xFF3A2C00);
  static const Color errorDarkBg = Color(0xFF3B1212);
  static const Color infoDarkBg = Color(0xFF102A43);

  // 🌈 Fondo degradado institucional
  static const Gradient fondoGradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azulClic, moradoSuave],
  );

  static Color shade(Color color, int percent) {
    assert(percent >= 0 && percent <= 100);

    return Color.lerp(color, Colors.white, percent / 100)!;
  }
}
