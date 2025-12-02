import 'dart:math' as math;

import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';

/// Controlador compatible con múltiples forks de ar_flutter_plugin.
/// - Usa ARAnchorManager para add/remove anchors.
/// - Raycast programático "best-effort" (performHitTest si existe).
/// - Transformaciones: intenta métodos típicos; si no hay, re-add del nodo con nuevos transforms.
class ARSceneController {
  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARAnchorManager? _anchors;

  ARNode? _node;
  ARAnchor? _anchor;
  String? _lastUri;
  bool _lastLocal = true;

  // ---------- Ciclo de vida ----------
  Future<void> init(
    ARSessionManager session,
    ARObjectManager objects, {
    ARAnchorManager? anchors,
    bool showPlanes = true,
    bool showFeaturePoints = true,
  }) async {
    _session = session;
    _objects = objects;
    _anchors = anchors;

    await _session!.onInitialize(
      showFeaturePoints: showFeaturePoints,
      showPlanes: showPlanes,
      showWorldOrigin: false,
      handleTaps: false,
    );
    await _objects!.onInitialize();
  }

  Future<void> dispose() async {
    try {
      await reset();
      // algunos forks no tienen dispose() en ARObjectManager; omitimos
      await _session?.dispose();
    } catch (_) {}
    _session = null;
    _objects = null;
    _anchors = null;
  }

  // ---------- Overlays ----------
  Future<void> reconfigureOverlays({
    required bool showFeaturePoints,
    required bool showPlanes,
  }) async {
    if (_session == null) return;
    await _session!.onInitialize(
      showFeaturePoints: showFeaturePoints,
      showPlanes: showPlanes,
      showWorldOrigin: false,
      handleTaps: false,
    );
  }

  // ---------- Raycast (best-effort con logs) ----------
  Future<dynamic> raycastScreen(double nx, double ny) async {
    if (_session == null) return null;

    // Normaliza por si te pasan pixeles
    double x = nx, y = ny;
    if (nx > 1 || ny > 1) {
      // asume coords de pantalla -> normaliza a 0..1
      x = (nx).clamp(0.0, 1.0);
      y = (ny).clamp(0.0, 1.0);
    }

    final dyn = _session as dynamic;

    // 1) performHitTest(x, y)
    try {
      if (dyn.performHitTest != null) {
        final results = await dyn.performHitTest(x, y);
        debugPrint('[AR] performHitTest -> ${results?.length}');
        if (results is List && results.isNotEmpty) {
          results.sort((a, b) => a.distance.compareTo(b.distance));
          return results.first;
        }
      }
    } catch (e) {
      debugPrint('[AR] performHitTest no disponible: $e');
    }

    // 2) hitTestFromScreen(x, y)
    try {
      if (dyn.hitTestFromScreen != null) {
        final results = await dyn.hitTestFromScreen(x, y);
        debugPrint('[AR] hitTestFromScreen -> ${results?.length}');
        if (results is List && results.isNotEmpty) {
          results.sort((a, b) => a.distance.compareTo(b.distance));
          return results.first;
        }
      }
    } catch (e) {
      debugPrint('[AR] hitTestFromScreen no disponible: $e');
    }

    // 3) raycast(x, y)
    try {
      if (dyn.raycast != null) {
        final results = await dyn.raycast(x, y);
        debugPrint('[AR] raycast -> ${results?.length}');
        if (results is List && results.isNotEmpty) {
          results.sort((a, b) => a.distance.compareTo(b.distance));
          return results.first;
        }
      }
    } catch (e) {
      debugPrint('[AR] raycast no disponible: $e');
    }

    // Nada disponible en este fork
    debugPrint(
      '[AR] ⚠️ No hay API de raycast programático en este fork. '
      'Usa tap manual o expón un método en tu plugin.',
    );
    return null;
  }

  // ---------- Colocar modelo ----------
  Future<void> placeAt(
    dynamic hit, {
    required String uri,
    required bool local,
  }) async {
    if (_objects == null) return;
    _lastUri = uri;
    _lastLocal = local;

    await _detach();

    // Anchor si posible
    if (_anchors != null && hit != null && hit.worldTransform != null) {
      try {
        _anchor = ARPlaneAnchor(transformation: hit.worldTransform);
        await _anchors!.addAnchor(_anchor!);
      } catch (_) {
        _anchor = null;
      }
    }

    final node = ARNode(
      type: NodeType.webGLB,
      uri:
          uri, // ⚠️ si tu fork usa 'assets:' o 'assetURI:' para locales, cambia aquí

      scale: Vector3(1, 1, 1),
      position: Vector3.zero(),
      rotation: Vector4(0, 0, 0, 1), // quaternion identidad
    );

    bool? ok = false;
    try {
      if (_anchor != null && _anchor is ARPlaneAnchor) {
        ok = await _objects!.addNode(
          node,
          planeAnchor: _anchor as ARPlaneAnchor,
        );
      } else {
        ok = await _objects!.addNode(node);
      }
    } catch (_) {
      try {
        ok = await _objects!.addNode(node);
      } catch (_) {}
    }

    if (!ok!) {
      _node = null;
      _anchor = null;
      return;
    }
    _node = node;
  }

  // ---------- Transformaciones ----------
  Future<void> setUniformScale(double s) async => setScaleXYZ(s, s, s);

  Future<void> setScaleXYZ(double sx, double sy, double sz) async {
    if (_node == null || _objects == null) return;

    // Intento dinámico: updateNodeScale(node, Vector3)
    try {
      final dyn = _objects as dynamic;
      final updated = await dyn.updateNodeScale?.call(
        _node!,
        Vector3(sx, sy, sz),
      );
      if (updated == true) {
        _node!.scale = Vector3(sx, sy, sz);
        return;
      }
    } catch (_) {}

    // Intento genérico: updateNode(node)
    try {
      final dyn = _objects as dynamic;
      _node!.scale = Vector3(sx, sy, sz);
      final updated = await dyn.updateNode?.call(_node!);
      if (updated == true) return;
    } catch (_) {}

    // Fallback: re-add
    await _readdWithTransforms(scale: Vector3(sx, sy, sz));
  }

  Future<void> setOffset(double ox, double oy, double oz) async {
    if (_node == null || _objects == null) return;

    try {
      final dyn = _objects as dynamic;
      final updated = await dyn.updateNodePosition?.call(
        _node!,
        Vector3(ox, oy, oz),
      );
      if (updated == true) {
        _node!.position = Vector3(ox, oy, oz);
        return;
      }
    } catch (_) {}

    try {
      final dyn = _objects as dynamic;
      _node!.position = Vector3(ox, oy, oz);
      final updated = await dyn.updateNode?.call(_node!);
      if (updated == true) return;
    } catch (_) {}

    await _readdWithTransforms(position: Vector3(ox, oy, oz));
  }

  Future<void> setRotationEulerDeg(double rx, double ry, double rz) async {
    if (_node == null || _objects == null) return;

    final radX = rx * math.pi / 180.0;
    final radY = ry * math.pi / 180.0;
    final radZ = rz * math.pi / 180.0;

    final quat = _eulerToQuaternion(rx, ry, rz); // Vector4
    final eulerDeg = Vector3(rx, ry, rz);
    final eulerRad = Vector3(radX, radY, radZ);

    // updateNodeRotation con varias firmas posibles
    try {
      final dyn = _objects as dynamic;
      final okQuat = await dyn.updateNodeRotation?.call(_node!, quat);
      if (okQuat == true) {
        _node!.rotation = quat as Matrix3;
        return;
      }
    } catch (_) {}

    try {
      final dyn = _objects as dynamic;
      final okDeg = await dyn.updateNodeRotation?.call(_node!, eulerDeg);
      if (okDeg == true) {
        _node!.rotation = quat as Matrix3;
        return;
      }
    } catch (_) {}

    try {
      final dyn = _objects as dynamic;
      final okRad = await dyn.updateNodeRotation?.call(_node!, eulerRad);
      if (okRad == true) {
        _node!.rotation = quat as Matrix3;
        return;
      }
    } catch (_) {}

    try {
      final dyn = _objects as dynamic;
      _node!.rotation = quat as Matrix3;
      final ok = await dyn.updateNode?.call(_node!);
      if (ok == true) return;
    } catch (_) {}

    await _readdWithTransforms(rotationQuat: quat);
  }

  // ---------- Reset ----------
  Future<void> reset() async => _detach();

  // ---------- Internos ----------
  Future<void> _detach() async {
    try {
      if (_node != null) {
        await _objects?.removeNode(_node!);
      }
    } catch (_) {}
    _node = null;

    try {
      if (_anchor != null && _anchors != null) {
        await _anchors!.removeAnchor(_anchor!);
      }
    } catch (_) {}
    _anchor = null;
  }

  Future<void> _readdWithTransforms({
    Vector3? position,
    Vector3? scale,
    Vector4? rotationQuat,
  }) async {
    if (_objects == null) return;
    final uri = _lastUri;
    final isLocal = _lastLocal;
    if (uri == null) return;

    final curPos = position ?? _node?.position ?? Vector3.zero();
    final curScale = scale ?? _node?.scale ?? Vector3.all(1);
    final curRot =
        rotationQuat ??
        (_node?.rotation is Vector4
            ? _node!.rotation as Vector4
            : Vector4(0, 0, 0, 1));

    await _detach();

    final node = ARNode(
      type: NodeType.webGLB,
      uri: isLocal ? '' : uri, // ⚠️ cambia a 'assets:' si tu fork lo requiere
      scale: curScale,
      position: curPos,
      rotation: curRot, // asegurado Vector4
    );

    bool? ok = false;
    try {
      if (_anchor != null && _anchor is ARPlaneAnchor) {
        ok = await _objects!.addNode(
          node,
          planeAnchor: _anchor as ARPlaneAnchor,
        );
      } else {
        ok = await _objects!.addNode(node);
      }
    } catch (_) {
      try {
        ok = await _objects!.addNode(node);
      } catch (_) {}
    }
    if (!ok!) _node = node;
  }

  // ---------- Utilidades ----------
  Vector4 _eulerToQuaternion(double rxDeg, double ryDeg, double rzDeg) {
    final x = rxDeg * math.pi / 180.0;
    final y = ryDeg * math.pi / 180.0;
    final z = rzDeg * math.pi / 180.0;

    final cx = math.cos(x / 2), sx = math.sin(x / 2);
    final cy = math.cos(y / 2), sy = math.sin(y / 2);
    final cz = math.cos(z / 2), sz = math.sin(z / 2);

    final w = cx * cy * cz + sx * sy * sz;
    final qx = sx * cy * cz - cx * sy * sz;
    final qy = cx * sy * cz + sx * cy * sz;
    final qz = cx * cy * sz - sx * sy * cz;

    return Vector4(qx, qy, qz, w);
  }
}
