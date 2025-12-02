import '../core/utils/geo_utils.dart';
import '../models/totem.dart';

class ProximityService {
  /// returns first totem within its captureRadius from user
  Totem? firstWithin({
    required double userLat,
    required double userLng,
    required List<Totem> totems,
  }) {
    for (final t in totems) {
      final d = distanceMeters(userLat, userLng, t.lat, t.lng);
      if (d <= t.captureRadius) return t;
    }
    return null;
  }
}
