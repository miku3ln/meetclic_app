import '../../domain/entities/device_location.dart';
import '../../domain/entities/location_stream_config.dart';
import '../../domain/repositories/device_sensors_repository.dart';
import '../services/device_sensors_service.dart';

final class DeviceSensorsRepositoryImpl implements DeviceSensorsRepository {
  final DeviceSensorsService _service;
  DeviceSensorsRepositoryImpl({DeviceSensorsService? service})
    : _service = service ?? DeviceSensorsService();

  // Ubicación
  @override
  Future<bool> isLocationServiceEnabled() =>
      _service.isLocationServiceEnabled();

  @override
  Future<bool> ensureLocationPermission() =>
      _service.ensureLocationPermission();

  @override
  Future<void> openLocationSettings() => _service.openLocationSettings();

  @override
  Future<void> openAppSettings() => _service.openAppSettings();

  @override
  Future<DeviceLocation> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
    LocationAccuracyLevel accuracy = LocationAccuracyLevel.best,
  }) => _service.getCurrentLocation(timeout: timeout, accuracy: accuracy);

  // Acelerómetro
  @override
  Future<bool> isAccelerometerAvailable({
    Duration timeout = const Duration(milliseconds: 800),
  }) => _service.isAccelerometerAvailable(timeout: timeout);

  @override
  Stream<({double x, double y, double z})> accelerometerStream() =>
      _service.accelerometerStream();

  @override
  Stream<({double x, double y, double z})> userAccelerometerStream() =>
      _service.userAccelerometerStream();

  @override
  ({double x, double y, double z})? get lastAccelerometer =>
      _service.lastAccelerometer;

  @override
  ({double x, double y, double z})? get lastUserAccelerometer =>
      _service.lastUserAccelerometer;

  @override
  Stream<DeviceLocation> watchLocationStream({
    LocationStreamConfig config = const LocationStreamConfig(),
  }) => _service.watchLocationStream(config: config);
}
