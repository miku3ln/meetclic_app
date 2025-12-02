import '../entities/device_location.dart';
import '../entities/location_stream_config.dart';
import '../repositories/device_sensors_repository.dart';

final class WatchLocationStream {
  final DeviceSensorsRepository repo;
  const WatchLocationStream(this.repo);

  Stream<DeviceLocation> call({
    LocationStreamConfig config = const LocationStreamConfig(),
  }) {
    return repo.watchLocationStream(config: config);
  }
}
