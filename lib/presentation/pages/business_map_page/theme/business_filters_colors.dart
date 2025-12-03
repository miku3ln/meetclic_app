import 'package:flutter/material.dart';

class BusinessFiltersColors {
  // HEADER
  final Color headerBackgroundColor; // Fondo de la sheet
  final Color headerTitleColor; // Texto "Filtros"
  final Color headerIconColor; // Icono de cerrar (X)
  final Color headerResetColor; // Texto "Restablecer"

  // SECCIÓN DISTANCIA
  final Color distanceTitleColor; // Texto "Distancia"
  final Color distanceSubtitleColor; // Texto descriptivo debajo
  final Color distanceSliderActiveColor; // Track activo del slider
  final Color distanceSliderInactiveColor; // Track inactivo del slider
  final Color distanceSliderThumbColor; // Thumb del slider
  final Color distanceLabelColor; // "1 km" y "30 km"

  // SECCIÓN CATEGORÍAS
  final Color categoriesTitleColor; // Texto "Categorías"
  final Color categoriesSubtitleColor; // Texto descriptivo debajo
  final Color categoryItemTextColor; // Nombre de cada categoría
  final Color categoryIconBackgroundColor; // Fondo circular del icono
  final Color categoryIconColor; // Icono dentro del círculo

  // CHECKBOX
  final Color checkboxActiveColor; // Relleno cuando está seleccionado
  final Color checkboxCheckColor; // Color de la palomita
  final Color checkboxInactiveBorderColor; // Borde cuando está desmarcado

  // BOTÓN APLICAR
  final Color applyButtonBackgroundColor;
  final Color applyButtonTextColor;
  final Color applyButtonDisabledBackgroundColor;
  final Color applyButtonDisabledTextColor;

  const BusinessFiltersColors({
    // HEADER
    required this.headerBackgroundColor,
    required this.headerTitleColor,
    required this.headerIconColor,
    required this.headerResetColor,
    // DISTANCE
    required this.distanceTitleColor,
    required this.distanceSubtitleColor,
    required this.distanceSliderActiveColor,
    required this.distanceSliderInactiveColor,
    required this.distanceSliderThumbColor,
    required this.distanceLabelColor,
    // CATEGORIES
    required this.categoriesTitleColor,
    required this.categoriesSubtitleColor,
    required this.categoryItemTextColor,
    required this.categoryIconBackgroundColor,
    required this.categoryIconColor,
    // CHECKBOX
    required this.checkboxActiveColor,
    required this.checkboxCheckColor,
    required this.checkboxInactiveBorderColor,
    // BUTTON
    required this.applyButtonBackgroundColor,
    required this.applyButtonTextColor,
    required this.applyButtonDisabledBackgroundColor,
    required this.applyButtonDisabledTextColor,
  });

  /// 🧩 Fábrica con valores por defecto basados en el Theme.
  factory BusinessFiltersColors.fromTheme(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.6);
    const headerBackgroundColor = Colors.white;

    return BusinessFiltersColors(
      // HEADER
      headerBackgroundColor: headerBackgroundColor,
      headerTitleColor: primary,
      headerIconColor: onSurface,
      headerResetColor: primary,
      // DISTANCE
      distanceTitleColor: primary,
      distanceSubtitleColor: muted,
      distanceSliderActiveColor: primary,
      distanceSliderInactiveColor: muted.withOpacity(0.3),
      distanceSliderThumbColor: primary,
      distanceLabelColor: muted,
      // CATEGORIES
      categoriesTitleColor: primary,
      categoriesSubtitleColor: muted,
      categoryItemTextColor: onSurface,
      categoryIconBackgroundColor: primary.withOpacity(0.1),
      categoryIconColor: primary,
      // CHECKBOX
      checkboxActiveColor: primary,
      checkboxCheckColor: onPrimary,
      checkboxInactiveBorderColor: muted,
      // BUTTON
      applyButtonBackgroundColor: primary,
      applyButtonTextColor: onPrimary,
      applyButtonDisabledBackgroundColor: muted.withOpacity(0.15),
      applyButtonDisabledTextColor: muted,
    );
  }
}
