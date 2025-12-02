import '../entities/device_location.dart';
import '../entities/location_stream_config.dart';

abstract interface class DeviceSensorsRepository {
  // Ubicación
  Future<bool> isLocationServiceEnabled();
  Future<bool> ensureLocationPermission();
  Future<void> openLocationSettings();
  Future<void> openAppSettings();
  Future<DeviceLocation> getCurrentLocation({
    Duration timeout,
    LocationAccuracyLevel accuracy,
  });

  // Acelerómetro
  Future<bool> isAccelerometerAvailable({Duration timeout});

  /// Acelerómetro **con gravedad** (x,y,z en m/s²)
  Stream<({double x, double y, double z})> accelerometerStream();

  /// Acelerómetro del usuario **sin gravedad** (x,y,z en m/s²)
  Stream<({double x, double y, double z})> userAccelerometerStream();

  /// Últimas muestras cacheadas (pueden ser null la primera vez)
  ({double x, double y, double z})? get lastAccelerometer;
  ({double x, double y, double z})? get lastUserAccelerometer;

  // --- NUEVO: stream de ubicación en vivo ---
  /// Devuelve un stream con DeviceLocation. Requiere servicio + permiso.
  Stream<DeviceLocation> watchLocationStream({
    LocationStreamConfig config = const LocationStreamConfig(),
  });
}

/// Precisión abstracta para desacoplar de librerías externas
enum LocationAccuracyLevel { low, balanced, high, best }
