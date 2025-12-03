// presentation/pages/business_map_page/helpers/business_map_fallback_helper.dart
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class BusinessMapFallbackHelper {
  static Future<LatLng> resolveInitialCenter({
    required double defaultLat,
    required double defaultLng,
    required Future<Position> Function() getCurrentPosition,
    required void Function(String msg) onError,
  }) async {
    try {
      final position = await getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      onError('No se pudo obtener tu ubicación actual.');
      return LatLng(defaultLat, defaultLng);
    }
  }
}
