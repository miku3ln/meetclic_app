import '../entities/device_location.dart';
import '../repositories/device_sensors_repository.dart';

final class GetCurrentLocation {
  final DeviceSensorsRepository repo;
  const GetCurrentLocation(this.repo);

  Future<DeviceLocation> call({
    Duration timeout = const Duration(seconds: 10),
    LocationAccuracyLevel accuracy = LocationAccuracyLevel.best,
  }) => repo.getCurrentLocation(timeout: timeout, accuracy: accuracy);
}
