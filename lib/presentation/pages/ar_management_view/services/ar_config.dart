import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' as v;

class ARConfig {
  // Distancia default para colocar frente a cámara
  static const double distanceMeters = 1.2;

  // Escala base (uniforme). 1.0 = tamaño original del modelo
  static const double uniformScale = 0.80;

  // Límites de escala absoluta (en factor, no %)
  static const double minScale = 0.15;
  static const double maxScale = 3.0;

  // Euler de respaldo si no hay pose de cámara
  static const List<double> fallbackEulerDeg = [0, 0, 0];
}

enum ARViewPreset {
  faceCamera, // mira a cámara
  front,
  back,
  left,
  right,
  up,
  down,
  isometric,
}

class OrientationHelper {
  OrientationHelper._();

  static double deg2rad(double d) => d * math.pi / 180.0;

  static v.Vector3 faceCameraEuler(v.Vector3 zAxis) {
    final forward = zAxis.normalized();
    final yaw = math.atan2(forward.x, forward.z) + math.pi;
    return v.Vector3(0.0, yaw, 0.0);
  }

  static v.Vector3 presetEuler(ARViewPreset preset) {
    switch (preset) {
      case ARViewPreset.front:
        return v.Vector3(0, 0, 0);
      case ARViewPreset.back:
        return v.Vector3(0, deg2rad(180), 0);
      case ARViewPreset.left:
        return v.Vector3(0, deg2rad(-90), 0);
      case ARViewPreset.right:
        return v.Vector3(0, deg2rad(90), 0);
      case ARViewPreset.up:
        return v.Vector3(deg2rad(-90), 0, 0);
      case ARViewPreset.down:
        return v.Vector3(deg2rad(90), 0, 0);
      case ARViewPreset.isometric:
        return v.Vector3(deg2rad(-30), deg2rad(45), 0);
      case ARViewPreset.faceCamera:
        return v.Vector3.zero();
    }
  }
}
