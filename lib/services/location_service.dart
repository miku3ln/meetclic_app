import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensurePermissions() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<Position> current() =>
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

  Stream<Position> stream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
  );
}
