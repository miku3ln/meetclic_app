import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' as v;

enum ARViewPreset { faceCamera, front, back, left, right, up, down, isometric }

class OrientationHelper {
  OrientationHelper._();

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double deg2rad(double d) => _deg2rad(d);

  static v.Vector3 faceCameraEuler(v.Vector3 zAxis) {
    final forward = zAxis.normalized();
    final yaw = math.atan2(forward.x, forward.z) + math.pi;
    return v.Vector3(0.0, yaw, 0.0);
    // pitch, yaw, roll
  }

  static v.Vector3 presetEuler(ARViewPreset preset) {
    switch (preset) {
      case ARViewPreset.front:
        return v.Vector3(0, 0, 0);
      case ARViewPreset.back:
        return v.Vector3(0, _deg2rad(180), 0);
      case ARViewPreset.left:
        return v.Vector3(0, _deg2rad(-90), 0);
      case ARViewPreset.right:
        return v.Vector3(0, _deg2rad(90), 0);
      case ARViewPreset.up:
        return v.Vector3(_deg2rad(-90), 0, 0);
      case ARViewPreset.down:
        return v.Vector3(_deg2rad(90), 0, 0);
      case ARViewPreset.isometric:
        return v.Vector3(_deg2rad(-30), _deg2rad(45), 0);
      case ARViewPreset.faceCamera:
        return v.Vector3.zero();
    }
  }
}
