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
  // NUEVOS
  orientationChanged,
  metricsChanged,
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
class DeviceGestureObserver extends StatefulWidget {
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

  /// Para decidir layout sin gestos
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

  @override
  State<DeviceGestureObserver> createState() =>
      _DeviceGestureObserverState();
}

class _DeviceGestureObserverState extends State<DeviceGestureObserver>
    with WidgetsBindingObserver {
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _lastOrientation = MediaQuery.of(context).orientation;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DeviceSnapshot _snapshot() {
    return DeviceGestureObserver.snapshotOf(
      context,
      tabletBreakpoint: widget.tabletBreakpoint,
    );
  }

  void _emit(GestureEvent event) {
    widget.onEvent(_snapshot(), event);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final snapshot = _snapshot();

      if (_lastOrientation != snapshot.orientation) {
        _lastOrientation = snapshot.orientation;

        _emit(
          GestureEvent(
            type: GestureEventType.orientationChanged,
            at: DateTime.now(),
          ),
        );
      } else {
        _emit(
          GestureEvent(
            type: GestureEventType.metricsChanged,
            at: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTap: () => _emit(
        GestureEvent(
          type: GestureEventType.tap,
          at: DateTime.now(),
        ),
      ),

      onDoubleTap: () => _emit(
        GestureEvent(
          type: GestureEventType.doubleTap,
          at: DateTime.now(),
        ),
      ),

      onLongPress: () => _emit(
        GestureEvent(
          type: GestureEventType.longPress,
          at: DateTime.now(),
        ),
      ),

      onScaleStart: widget.enableScale
          ? (_) => _emit(
        GestureEvent(
          type: GestureEventType.scaleStart,
          at: DateTime.now(),
        ),
      )
          : null,

      onScaleUpdate: widget.enableScale
          ? (details) {
        final delta = details.focalPointDelta;

        if (widget.enablePan &&
            delta.distance > widget.panDeltaThreshold) {
          _emit(
            GestureEvent(
              type: GestureEventType.panUpdate,
              delta: delta,
              at: DateTime.now(),
            ),
          );
        }

        final zoom =
            (details.scale - 1).abs() > widget.scaleThreshold;

        final rotation =
            details.rotation.abs() >
                widget.rotationThreshold;

        if (zoom || rotation) {
          _emit(
            GestureEvent(
              type: GestureEventType.scaleUpdate,
              scale: details.scale,
              rotation: details.rotation,
              at: DateTime.now(),
            ),
          );
        }
      }
          : null,

      onScaleEnd: widget.enableScale
          ? (_) => _emit(
        GestureEvent(
          type: GestureEventType.scaleEnd,
          at: DateTime.now(),
        ),
      )
          : null,

      child: widget.child,
    );
  }
}