import '../repositories/device_sensors_repository.dart';

final class IsAccelerometerAvailable {
  final DeviceSensorsRepository repo;
  const IsAccelerometerAvailable(this.repo);

  Future<bool> call({Duration timeout = const Duration(milliseconds: 800)}) =>
      repo.isAccelerometerAvailable(timeout: timeout);
}
