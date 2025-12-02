// lib/preview/controllers/preview_scene_controller.dart
import 'package:flutter/material.dart';

class PreviewSceneController {
  // En este wrapper no necesitas recursos nativos; guardas estado y notificas a la vista.
  late void Function({
    double? sx,
    double? sy,
    double? sz,
    double? ox,
    double? oy,
    double? oz,
    double? rx,
    double? ry,
    double? rz,
  })
  _apply;

  Future<void> init({
    required bool showPlanes,
    required bool showFeaturePoints,
    required BuildContext context,
  }) async {}

  Future<void> placeAt(
    Object _, {
    required String uri,
    required bool local,
  }) async {
    // El <model-viewer> carga por src directamente. La Vista leerá `uri`.
  }

  Future<void> reconfigureOverlays({
    required bool showFeaturePoints,
    required bool showPlanes,
  }) async {}

  Future<void> setUniformScale(double s) async {
    _apply(sx: s, sy: s, sz: s);
  }

  Future<void> setScaleXYZ(double x, double y, double z) async {
    _apply(sx: x, sy: y, sz: z);
  }

  Future<void> setOffset(double x, double y, double z) async {
    _apply(ox: x, oy: y, oz: z);
  }

  Future<void> setRotationEulerDeg(double rx, double ry, double rz) async {
    _apply(rx: rx, ry: ry, rz: rz);
  }

  Future<void> reset() async {
    _apply(sx: 1, sy: 1, sz: 1, ox: 0, oy: 0.05, oz: 0, rx: 0, ry: 0, rz: 0);
  }

  void bind(
    void Function({
      double? sx,
      double? sy,
      double? sz,
      double? ox,
      double? oy,
      double? oz,
      double? rx,
      double? ry,
      double? rz,
    })
    apply,
  ) {
    _apply = apply;
  }

  void dispose() {}
}
