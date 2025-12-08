import 'package:flutter/material.dart';

/// Configuración visual de un marker de negocio en el mapa.
///
/// Separa la lógica de **qué asset usar** y **con qué tamaño / alineación**
/// para que el código del mapa quede más limpio.
class BusinessMarkerVisualConfig {
  /// Ruta del asset PNG/SVG que representa el marker.
  final String assetPath;

  /// Ancho del marker en el mapa.
  final double width;

  /// Alto del marker en el mapa.
  final double height;

  /// Alineación del widget dentro del punto del mapa.
  /// Normalmente Alignment.topCenter o Alignment.center.
  final Alignment alignment;

  const BusinessMarkerVisualConfig({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.alignment,
  });
}
