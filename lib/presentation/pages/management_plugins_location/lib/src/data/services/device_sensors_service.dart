import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:sensors_plus/sensors_plus.dart';

import '../../../management_plugins_location.dart';
import '../../core/errors/failures.dart';

class DeviceSensorsService implements DeviceSensorsRepository {
  // cache de últimas lecturas
  ({double x, double y, double z})? _lastAcc;
  ({double x, double y, double z})? _lastUserAcc;

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> ensureLocationPermission() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    if (permission == geo.LocationPermission.deniedForever) return false;

    return permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always;
  }

  @override
  Future<void> openLocationSettings() async {
    await geo.Geolocator.openLocationSettings();
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  geo.LocationAccuracy _mapAccuracy(LocationAccuracyLevel accuracy) {
    switch (accuracy) {
      case LocationAccuracyLevel.low:
        return geo.LocationAccuracy.low;
      case LocationAccuracyLevel.balanced:
        return geo.LocationAccuracy.medium;
      case LocationAccuracyLevel.high:
        return geo.LocationAccuracy.high;
      case LocationAccuracyLevel.best:
        return geo.LocationAccuracy.best;
    }
  }

  @override
  Future<DeviceLocation> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
    LocationAccuracyLevel accuracy = LocationAccuracyLevel.best,
  }) async {
    final hasPerm = await ensureLocationPermission();
    if (!hasPerm) {
      throw const PermissionFailure(
        'Ubicación sin permiso o servicio deshabilitado.',
      );
    }

    try {
      final pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: _mapAccuracy(accuracy),
        timeLimit: timeout,
      );

      return DeviceLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: pos.altitude ?? 0.0,
        timestamp: pos.timestamp ?? DateTime.now(),
      );
    } on TimeoutException catch (e, st) {
      throw TimeoutFailure(
        'Timeout obteniendo ubicación',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownFailure(
        'Error obteniendo ubicación',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> isAccelerometerAvailable({
    Duration timeout = const Duration(milliseconds: 800),
  }) async {
    final completer = Completer<bool>();
    late final StreamSubscription sub;
    bool seen = false;

    sub = accelerometerEvents.listen(
      (_) {
        seen = true;
        if (!completer.isCompleted) completer.complete(true);
        sub.cancel();
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
        sub.cancel();
      },
    );

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(seen);
        sub.cancel();
      }
    });

    return completer.future;
  }

  @override
  Stream<({double x, double y, double z})> accelerometerStream() {
    return accelerometerEvents.map((e) {
      final s = (x: e.x, y: e.y, z: e.z);
      _lastAcc = s;
      return s;
    });
  }

  @override
  Stream<({double x, double y, double z})> userAccelerometerStream() {
    return userAccelerometerEvents.map((e) {
      final s = (x: e.x, y: e.y, z: e.z);
      _lastUserAcc = s;
      return s;
    });
  }

  @override
  ({double x, double y, double z})? get lastAccelerometer => _lastAcc;

  @override
  ({double x, double y, double z})? get lastUserAccelerometer => _lastUserAcc;

  // ============== NUEVO: STREAM DE UBICACIÓN ==============
  @override
  Stream<DeviceLocation> watchLocationStream({
    LocationStreamConfig config = const LocationStreamConfig(),
  }) async* {
    // 1) Servicio + permiso
    final serviceOn = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      throw const ServiceDisabledFailure('GPS deshabilitado.');
    }
    final permOk = await ensureLocationPermission();
    if (!permOk) {
      throw const PermissionFailure('Permiso de ubicación no otorgado.');
    }

    // 2) Lectura inicial para “descongelar” la UI
    final first = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: _mapAccuracy(config.accuracy),
    );
    yield DeviceLocation(
      latitude: first.latitude,
      longitude: first.longitude,
      altitude: first.altitude ?? 0.0,
      timestamp: first.timestamp ?? DateTime.now(),
    );

    // 3) Settings por plataforma (ojo con el tipo de distanceFilter)
    geo.LocationSettings settings;
    if (Platform.isAndroid) {
      settings = geo.AndroidSettings(
        accuracy: _mapAccuracy(config.accuracy),
        distanceFilter: config.distanceFilterMeters
            .round(), // int en AndroidSettings
        intervalDuration: config.interval, // solicita updates periódicos
        forceLocationManager: false,
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      settings = geo.AppleSettings(
        accuracy: _mapAccuracy(config.accuracy),
        distanceFilter: config.distanceFilterMeters, // double en AppleSettings
        pauseLocationUpdatesAutomatically: false,
        activityType: geo.ActivityType.fitness,
        showBackgroundLocationIndicator: false,
      );
    } else {
      // Web/Desktop genérico
      settings = geo.LocationSettings(
        accuracy: _mapAccuracy(config.accuracy),
        distanceFilter: config.distanceFilterMeters
            .round(), // int en LocationSettings
      );
    }

    // 4) Stream base con distinct para evitar duplicados idénticos
    final baseStream =
        geo.Geolocator.getPositionStream(locationSettings: settings)
            .distinct(
              (a, b) =>
                  a.latitude == b.latitude &&
                  a.longitude == b.longitude &&
                  (a.altitude ?? 0.0) == (b.altitude ?? 0.0),
            )
            .map(
              (pos) => DeviceLocation(
                latitude: pos.latitude,
                longitude: pos.longitude,
                altitude: pos.altitude ?? 0.0,
                timestamp: pos.timestamp ?? DateTime.now(),
              ),
            );

    // 5) Fallback Android si no llegan eventos (watchdog)
    //    (algunos devices necesitan forzar LocationManager)
    if (!Platform.isAndroid) {
      // No hace falta fallback especial en iOS/web
      yield* baseStream;
      return;
    }

    final controller = StreamController<DeviceLocation>();
    Timer? watchdog;

    void armWatchdog() {
      watchdog?.cancel();
      watchdog = Timer(const Duration(seconds: 7), () async {
        if (controller.isClosed) return;
        try {
          final forcedStream =
              geo.Geolocator.getPositionStream(
                locationSettings: geo.AndroidSettings(
                  accuracy: _mapAccuracy(config.accuracy),
                  distanceFilter: 0, // sin filtro de distancia
                  intervalDuration: const Duration(seconds: 1),
                  forceLocationManager: true, // clave en ciertos equipos
                ),
              ).map(
                (pos) => DeviceLocation(
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                  altitude: pos.altitude ?? 0.0,
                  timestamp: pos.timestamp ?? DateTime.now(),
                ),
              );

          await for (final loc in forcedStream) {
            if (controller.isClosed) break;
            controller.add(loc);
          }
        } catch (_) {
          // silencioso: no matar el stream si el fallback falla
        }
      });
    }

    final sub = baseStream.listen(
      (loc) {
        armWatchdog();
        controller.add(loc);
      },
      onError: (e, st) => controller.addError(e, st),
      onDone: () => controller.close(),
      cancelOnError: false,
    );

    armWatchdog();

    controller.onCancel = () async {
      watchdog?.cancel();
      await sub.cancel();
    };

    yield* controller.stream;
  }
}
