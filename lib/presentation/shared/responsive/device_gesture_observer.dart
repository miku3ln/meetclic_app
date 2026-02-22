import 'package:flutter/material.dart';

// ----------------------------
// Enums
// ----------------------------
enum LayoutType {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
}

enum GestureEventType {
  tap,
  doubleTap,
  longPress,
  panUpdate,     // se emite desde scaleUpdate (focalPointDelta)
  scaleStart,
  scaleUpdate,
  scaleEnd,
}

// ----------------------------
// Models
// ----------------------------
class DeviceSnapshot {
  final double width;
  final double height;
  final double shortestSide;
  final Orientation orientation;
  final bool isTablet;
  final LayoutType layoutType;

  const DeviceSnapshot({
    required this.width,
    required this.height,
    required this.shortestSide,
    required this.orientation,
    required this.isTablet,
    required this.layoutType,
  });

  @override
  String toString() =>
      'DeviceSnapshot(w:$width h:$height shortest:$shortestSide '
          'ori:$orientation tablet:$isTablet layout:$layoutType)';
}

class GestureEvent {
  final GestureEventType type;

  /// Para "panUpdate" (drag) viene desde ScaleUpdateDetails.focalPointDelta
  final Offset? delta;

  /// Para scaleUpdate (pinch)
  final double? scale;

  /// Para scaleUpdate (rotación)
  final double? rotation;

  final DateTime at;

  const GestureEvent({
    required this.type,
    this.delta,
    this.scale,
    this.rotation,
    required this.at,
  });

  @override
  String toString() =>
      'GestureEvent(type:$type delta:$delta scale:$scale rot:$rotation at:$at)';
}

typedef DeviceGestureCallback = void Function(
    DeviceSnapshot device,
    GestureEvent event,
    );

// ----------------------------
// Widget Observer
// ----------------------------
class DeviceGestureObserver extends StatelessWidget {
  final Widget child;

  /// Se dispara en CADA gesto y te manda:
  /// - medidas (w/h)
  /// - layoutType (mobile/tablet + portrait/landscape)
  /// - el evento del gesto
  final DeviceGestureCallback onEvent;

  /// Breakpoint recomendado (Material): shortestSide >= 600 => tablet
  final double tabletBreakpoint;

  /// Activa gestos de escala (incluye pan/drag)
  final bool enableScale;

  /// Si es false, NO emitimos panUpdate (drag) aunque haya focalPointDelta
  final bool enablePan;

  /// Evita spam: solo emite panUpdate si el movimiento supera este umbral
  final double panDeltaThreshold;

  /// Evita spam: solo emite scaleUpdate si supera este umbral
  final double scaleThreshold;

  /// Evita spam: solo emite rotation si supera este umbral
  final double rotationThreshold;

  const DeviceGestureObserver({
    super.key,
    required this.child,
    required this.onEvent,
    this.tabletBreakpoint = 600,
    this.enableScale = true,
    this.enablePan = true,
    this.panDeltaThreshold = 0.5,
    this.scaleThreshold = 0.001,
    this.rotationThreshold = 0.001,
  });

  // ✅ Para decidir layout sin gestos (usa esto en tu PointSalePage)
  static DeviceSnapshot snapshotOf(
      BuildContext context, {
        double tabletBreakpoint = 600,
      }) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final orientation = mq.orientation;
    final shortest = size.shortestSide;

    final isTablet = shortest >= tabletBreakpoint;

    final layoutType = switch ((isTablet, orientation)) {
      (false, Orientation.portrait) => LayoutType.mobilePortrait,
      (false, Orientation.landscape) => LayoutType.mobileLandscape,
      (true, Orientation.portrait) => LayoutType.tabletPortrait,
      (true, Orientation.landscape) => LayoutType.tabletLandscape,
      _ => LayoutType.mobilePortrait,
    };

    return DeviceSnapshot(
      width: size.width,
      height: size.height,
      shortestSide: shortest,
      orientation: orientation,
      isTablet: isTablet,
      layoutType: layoutType,
    );
  }

  DeviceSnapshot _snapshot(BuildContext context) {
    return snapshotOf(context, tabletBreakpoint: tabletBreakpoint);
  }

  void _emit(BuildContext context, GestureEvent event) {
    final device = _snapshot(context);
    onEvent(device, event);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTap: () => _emit(
        context,
        GestureEvent(type: GestureEventType.tap, at: DateTime.now()),
      ),

      onDoubleTap: () => _emit(
        context,
        GestureEvent(type: GestureEventType.doubleTap, at: DateTime.now()),
      ),

      onLongPress: () => _emit(
        context,
        GestureEvent(type: GestureEventType.longPress, at: DateTime.now()),
      ),

      // ✅ SOLO SCALE (incluye pan)
      onScaleStart: enableScale
          ? (_) => _emit(
        context,
        GestureEvent(type: GestureEventType.scaleStart, at: DateTime.now()),
      )
          : null,

      onScaleUpdate: enableScale
          ? (d) {
        // PAN (drag) desde scale
        final delta = d.focalPointDelta;
        final moved = delta.distance > panDeltaThreshold;

        if (enablePan && moved) {
          _emit(
            context,
            GestureEvent(
              type: GestureEventType.panUpdate,
              delta: delta,
              at: DateTime.now(),
            ),
          );
        }

        // SCALE / ROTATION
        final isZooming = (d.scale - 1.0).abs() > scaleThreshold;
        final isRotating = d.rotation.abs() > rotationThreshold;

        if (isZooming || isRotating) {
          _emit(
            context,
            GestureEvent(
              type: GestureEventType.scaleUpdate,
              scale: d.scale,
              rotation: d.rotation,
              at: DateTime.now(),
            ),
          );
        }
      }
          : null,

      onScaleEnd: enableScale
          ? (_) => _emit(
        context,
        GestureEvent(type: GestureEventType.scaleEnd, at: DateTime.now()),
      )
          : null,

      child: child,
    );
  }
}
