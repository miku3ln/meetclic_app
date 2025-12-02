import 'dart:io';
import 'dart:math' as math;

import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:meetclic_app/presentation/pages/ar_management_view/services/node_factory.dart';
import 'package:vector_math/vector_math_64.dart' as v;

import 'ar_config.dart';

class ARService {
  Future<void> _recreateWith({
    v.Vector3? position,
    v.Vector3? euler,
    v.Vector3? scale,
  }) async {
    final node = _current;
    if (node == null) return;
    final uri = node.uri ?? '';
    if (uri.isEmpty) return;

    final newNode = ARNode(
      type: node.type,
      uri: uri,
      position: position ?? node.position ?? v.Vector3.zero(),
      eulerAngles: euler ?? node.eulerAngles ?? v.Vector3.zero(),
      scale: scale ?? node.scale ?? v.Vector3.all(ARConfig.uniformScale),
    );

    try {
      await _objects?.removeNode(node);
    } catch (_) {}

    final ok = await _objects?.addNode(newNode);
    if (ok == true) {
      _current = newNode;
    }
  }

  Future<void> applyViewPreset(
    ARViewPreset preset, {
    bool absolute = true,
  }) async {
    if (_current == null) return;

    if (preset == ARViewPreset.faceCamera) {
      final pose = await _computePoseAhead(ARConfig.distanceMeters);
      if (absolute) {
        await _recreateWith(euler: pose.euler);
      } else {
        final cur = _current!.eulerAngles ?? v.Vector3.zero();
        await _recreateWith(
          euler: v.Vector3(
            cur.x + pose.euler.x,
            cur.y + pose.euler.y,
            cur.z + pose.euler.z,
          ),
        );
      }
      return;
    }

    final eulPreset = OrientationHelper.presetEuler(preset);
    if (absolute) {
      await _recreateWith(euler: eulPreset);
    } else {
      final cur = _current!.eulerAngles ?? v.Vector3.zero();
      await _recreateWith(
        euler: v.Vector3(
          cur.x + eulPreset.x,
          cur.y + eulPreset.y,
          cur.z + eulPreset.z,
        ),
      );
    }
  }

  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARNode? _current;

  ARNode? get currentNode => _current;

  Future<void> init({
    required ARSessionManager sessionManager,
    required ARObjectManager objectManager,
  }) async {
    _session = sessionManager;
    _objects = objectManager;

    await _session!.onInitialize(
      showAnimatedGuide: false,
      showFeaturePoints: false,
      showPlanes: false,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      handleTaps: false,
      handlePans: false,
      handleRotation: false,
    );
    await _objects!.onInitialize();
  }

  Future<void> dispose() async {
    try {
      if (_current != null) {
        await _objects?.removeNode(_current!);
      }
    } catch (_) {}
    _current = null;
    _session?.dispose();
  }

  Future<void> removeCurrentNodeIfAny() async {
    if (_current != null) {
      try {
        await _objects?.removeNode(_current!);
      } catch (_) {}
      _current = null;
    }
  }

  Future<({v.Vector3 position, v.Vector3 euler, v.Vector3 zAxis})>
  _computePoseAhead(double distanceMeters) async {
    v.Vector3 camPos = v.Vector3.zero();
    v.Vector3 zAxis = v.Vector3(0, 0, 1);

    try {
      final camPose = await _session!.getCameraPose();
      if (camPose != null) {
        camPos = camPose.getTranslation();
        zAxis = v.Vector3(
          camPose.entry(0, 2),
          camPose.entry(1, 2),
          camPose.entry(2, 2),
        ).normalized();
      }
    } catch (_) {}

    final targetPos = camPos - zAxis * ARConfig.distanceMeters;
    final euler = OrientationHelper.faceCameraEuler(zAxis);
    return (position: targetPos, euler: euler, zAxis: zAxis);
  }

  Future<bool> placeGlbInFront({
    required String url,
    bool isLocal = false,
    double distanceMeters = ARConfig.distanceMeters,
    double uniformScale = ARConfig.uniformScale,
    ARViewPreset? initialPreset,
  }) async {
    if (_session == null || _objects == null) {
      throw StateError('ARService no inicializado');
    }

    await removeCurrentNodeIfAny();
    final pose = await _computePoseAhead(distanceMeters);

    var euler = pose.euler;
    if (initialPreset != null && initialPreset != ARViewPreset.faceCamera) {
      euler = OrientationHelper.presetEuler(initialPreset);
    }

    // 🔍 Diagnóstico previo si es local (asegúrate que el archivo exista y pese >0)
    if (isLocal) {
      try {
        final f = File(url);
        if (!await f.exists()) {
          debugPrint('[AR] local path no existe: $url');
          return false;
        }
        final len = await f.length();
        if (len == 0) {
          debugPrint('[AR] local path tamaño 0: $url');
          return false;
        }
        if (!url.toLowerCase().endsWith('.glb')) {
          debugPrint('[AR] advertencia: extensión no .glb -> $url');
        }
      } catch (e) {
        debugPrint('[AR] error inspeccionando archivo local: $e');
        return false;
      }
    } else {
      // Para remotos, valida que sea http(s)
      if (!NodeFactory.isValidGlbUrl(url)) {
        debugPrint('[AR] URL web inválida: $url');
        return false;
      }
    }

    final node = isLocal
        ? NodeFactory.localFileGlb(
            filePath: url,
            position: pose.position,
            eulerAngles: euler,
            uniformScale: uniformScale,
          )
        : NodeFactory.webGlb(
            url: url,
            position: pose.position,
            eulerAngles: euler,
            uniformScale: uniformScale,
          );

    try {
      final added = await _objects!.addNode(node);
      if (added == true) {
        _current = node;
        return true;
      }
      debugPrint('[AR] addNode devolvió false');
      return false;
    } catch (e, st) {
      debugPrint('[AR] addNode lanzó excepción: $e\n$st');
      return false;
    }
  }

  // === Hot updates ===
  Future<void> setUniformScalePercent(double percent) async {
    if (_current == null) return;

    final minP = ARConfig.minScale * 100 / ARConfig.uniformScale;
    final maxP = ARConfig.maxScale * 100 / ARConfig.uniformScale;
    final p = percent.clamp(minP, maxP).toDouble();

    final newScale = ARConfig.uniformScale * (p / 100.0);
    _current!.scale = v.Vector3.all(newScale);
    _pushCurrentTransform();
  }

  double getCurrentUniformScale() {
    final sc = _current?.scale ?? v.Vector3.all(ARConfig.uniformScale);
    return (sc.x + sc.y + sc.z) / 3.0;
  }

  Future<void> nudgeYawDegrees(double deltaDeg) async {
    if (_current == null) return;
    final eul = _current!.eulerAngles ?? v.Vector3.zero();
    final dy = deltaDeg * math.pi / 180.0;

    _current!.eulerAngles = v.Vector3(eul.x, eul.y + dy, eul.z);
    _pushCurrentTransform();
  }

  Future<void> nudgeXawDegrees(double deltaDeg) async {
    if (_current == null) return;

    final eul = _current!.eulerAngles ?? v.Vector3.zero();
    final dx = deltaDeg * math.pi / 180.0; // grados -> radianes

    _current!.eulerAngles = v.Vector3(eul.x + dx, eul.y, eul.z);
    _pushCurrentTransform(); // aplica en caliente sin recrear el nodo
  }

  Future<void> recenterInFront() async {
    if (_current == null) return;
    final pose = await _computePoseAhead(ARConfig.distanceMeters);
    _current!
      ..position = pose.position
      ..eulerAngles = pose.euler;
    _pushCurrentTransform();
  }

  void _pushCurrentTransform() {
    final node = _current;
    if (node == null) return;

    final pos = node.position ?? v.Vector3.zero();
    final eul = node.eulerAngles ?? v.Vector3.zero();
    final sc = node.scale ?? v.Vector3.all(ARConfig.uniformScale);

    final q = v.Quaternion.euler(eul.x, eul.y, eul.z);
    final m = v.Matrix4.compose(pos, q, sc);

    node.transformNotifier.value = m; // 🔥 notifica al nativo
  }
}
