import 'package:geolocator/geolocator.dart';

import '../data/totems_data.dart';
import '../models/totem.dart';
import '../services/location_service.dart';
import '../services/proximity_service.dart';

class TotemController {
  final _loc = LocationService();
  final _prox = ProximityService();

  List<Totem> get all => totems;

  Future<Position> getCurrent() async {
    await _loc.ensurePermissions();
    return _loc.current();
  }

  Stream<Position> watch() => _loc.stream();

  Totem? findNearby(double userLat, double userLng) =>
      _prox.firstWithin(userLat: userLat, userLng: userLng, totems: totems);
}
