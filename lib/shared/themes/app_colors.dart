import 'package:flutter/material.dart';

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
