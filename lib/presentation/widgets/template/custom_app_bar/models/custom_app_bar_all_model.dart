// =====================
// ENUM + MODELOS LAYOUT
// =====================
import 'package:flutter/material.dart';

/// Presets reutilizables
class HeaderLayoutPresets {
  /// Layout NONE: usado cuando no envías config.
  /// La lógica real se resuelve en CustomAppBar (título + items clásicos).
  static const none = HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.none,
    percentages: [1.0],
    sections: [
      HeaderSectionModel(type: HeaderSectionType.none, visible: false),
    ],
  );
}

enum HeaderSectionType {
  buttons, // solo iconos
  textInput, // textos o inputs
  imageIcon, // imagen o icono
  none, // vacío

  searchToggle, // botón lupa que abre/cierra búsqueda
  backButton, // botón atrás para salir de búsqueda
}

enum HeaderLayoutType {
  none,
  tripleColumnCenterWeighted, // 20% / 50% / 30%
  doubleColumnLeftWeighted, // 70% / 30%
  singleColumnFullWidth, // 100%
  doubleColumnRightWeighted, // 25% / 75%
}

class HeaderSectionModel {
  final HeaderSectionType type;
  final Widget? content;
  final VoidCallback? onTap;
  final bool visible;

  const HeaderSectionModel({
    required this.type,
    this.content,
    this.onTap,
    this.visible = true,
  });
}

class HeaderLayoutConfiguration {
  final HeaderLayoutType layoutType;
  final List<double> percentages;
  final List<HeaderSectionModel> sections; // ordenados según layout
  final bool borderAllow;

  const HeaderLayoutConfiguration({
    required this.layoutType,
    required this.percentages,
    required this.sections,
    this.borderAllow = true,
  });
}

class HeaderLayoutModel {
  final HeaderLayoutType type;
  final List<double> percentages; // cada valor entre 0 y 1

  const HeaderLayoutModel({required this.type, required this.percentages});
}

class HeaderLayouts {
  static const none = HeaderLayoutModel(
    type: HeaderLayoutType.none,
    percentages: [1.0],
  );
  static const tripleColumnCenterWeighted = HeaderLayoutModel(
    type: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: [0.20, 0.50, 0.30],
  );

  static const doubleColumnLeftWeighted = HeaderLayoutModel(
    type: HeaderLayoutType.doubleColumnLeftWeighted,
    percentages: [0.70, 0.30],
  );

  static const singleColumnFullWidth = HeaderLayoutModel(
    type: HeaderLayoutType.singleColumnFullWidth,
    percentages: [1.0],
  );

  static const doubleColumnRightWeighted = HeaderLayoutModel(
    type: HeaderLayoutType.doubleColumnRightWeighted,
    percentages: [0.25, 0.75],
  );

  static HeaderLayoutModel fromType(HeaderLayoutType type) {
    switch (type) {
      case HeaderLayoutType.none:
        return none;
      case HeaderLayoutType.tripleColumnCenterWeighted:
        return tripleColumnCenterWeighted;
      case HeaderLayoutType.doubleColumnLeftWeighted:
        return doubleColumnLeftWeighted;
      case HeaderLayoutType.singleColumnFullWidth:
        return singleColumnFullWidth;
      case HeaderLayoutType.doubleColumnRightWeighted:
        return doubleColumnRightWeighted;
    }
  }
}
