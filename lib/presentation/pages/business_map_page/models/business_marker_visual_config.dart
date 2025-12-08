import 'package:flutter/material.dart';

/// Configuración visual para un marker de negocio en el mapa.
class BusinessMarkerVisualConfig {
  final String assetPath;
  final double width;
  final double height;
  final Alignment alignment;

  const BusinessMarkerVisualConfig({
    required this.assetPath,
    this.width = 40,
    this.height = 40,
    this.alignment = Alignment.topCenter,
  });
}
