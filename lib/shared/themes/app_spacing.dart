import 'package:flutter/material.dart';

class AppSpacing {
  // Espaciado general modular (por tamaños)
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 40;

  // Espaciados tipificados (orientados al uso)

  /// Espaciado entre campos de formulario (inputs).
  static const double betweenInputs = m;

  /// Espaciado entre botones alineados (en fila o columna).
  static const double betweenButtons = s;

  /// Espaciado entre secciones (bloques diferenciados).
  static const double betweenSections = l;

  /// Espaciado entre encabezado y el contenido que le sigue.
  static const double betweenHeaderAndContent = xl;

  /// Espaciado general de márgenes o paddings exteriores de página.
  static const double pagePadding = xxl;

  /// Espaciado mínimo entre íconos u objetos pequeños.
  static const double betweenIcons = xs;


  // SizedBoxes Listos (vertical)

  static const SizedBox spaceBetweenInputs = SizedBox(height: betweenInputs);
  static const SizedBox spaceBetweenButtons = SizedBox(height: betweenButtons);
  static const SizedBox spaceBetweenSections = SizedBox(height: betweenSections);
  static const SizedBox spaceBetweenHeaderAndContent = SizedBox(height: betweenHeaderAndContent);
  static const SizedBox pagePaddingBox = SizedBox(height: pagePadding);
  static const SizedBox spaceBetweenIcons = SizedBox(height: betweenIcons);
}
