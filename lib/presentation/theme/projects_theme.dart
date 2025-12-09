import 'package:flutter/material.dart';

/// Colores de marca MeetClic reutilizables
class MeetClicBrandColors {
  static const Color azulClic = Color(0xFF4C4CFF);
  static const Color amarilloVital = Color(0xFFFFCC00);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisOscuro = Color(0xFF2C2C2C);
  static const Color moradoSuave = Color(0xFF5C5CFF);

  // Línea suave para listas (puedes ajustarla)
  static const Color dividerSoft = Color(0xFFE0E0E0);
}

/// Configuración por defecto para divisores de listas en Projects
class ProjectsDividerDefaults {
  static const double widthFactor = 0.8; // 70% del ancho
  static const double height = 1;
  static const double thickness = 0.5;
  static const AlignmentGeometry alignmentCenter = Alignment.center;
  static const AlignmentGeometry alignmentRight = Alignment.centerRight;
  static const AlignmentGeometry alignmentLeft = Alignment.centerLeft;

  static const Color color = MeetClicBrandColors.dividerSoft;
}
