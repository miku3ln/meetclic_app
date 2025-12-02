import '../repositories/device_sensors_repository.dart';

final class CheckLocationServiceEnabled {
  final DeviceSensorsRepository repo;
  const CheckLocationServiceEnabled(this.repo);

  Future<bool> call() => repo.isLocationServiceEnabled();
}
