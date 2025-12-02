import '../repositories/device_sensors_repository.dart';

final class EnsureLocationPermission {
  final DeviceSensorsRepository repo;
  const EnsureLocationPermission(this.repo);

  Future<bool> call() => repo.ensureLocationPermission();
}
