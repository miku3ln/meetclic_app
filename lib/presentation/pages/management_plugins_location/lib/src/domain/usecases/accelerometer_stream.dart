import '../repositories/device_sensors_repository.dart';

final class AccelerometerStream {
  final DeviceSensorsRepository repo;
  const AccelerometerStream(this.repo);

  Stream<({double x, double y, double z})> call() => repo.accelerometerStream();
}
