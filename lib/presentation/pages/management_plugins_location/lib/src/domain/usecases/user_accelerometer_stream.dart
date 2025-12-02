import '../repositories/device_sensors_repository.dart';

final class UserAccelerometerStream {
  final DeviceSensorsRepository repo;
  const UserAccelerometerStream(this.repo);

  Stream<({double x, double y, double z})> call() =>
      repo.userAccelerometerStream();
}
