import 'package:latlong2/latlong.dart';

/// Define cuándo realmente vale la pena refrescar los negocios
/// según el movimiento del mapa.
class MapRefreshHelper {
  MapRefreshHelper({
    this.minDistanceMeters = 400, // distancia mínima para refrescar
    this.minZoomDelta = 0.7, // cambio mínimo de zoom
  });

  final double minDistanceMeters;
  final double minZoomDelta;

  final Distance _distance = const Distance();

  LatLng? _lastCenter;
  double? _lastZoom;

  bool shouldRefresh(LatLng center, double zoom) {
    // Primer uso → siempre refrescar
    if (_lastCenter == null || _lastZoom == null) {
      _lastCenter = center;
      _lastZoom = zoom;
      return true;
    }

    final dist = _distance.as(LengthUnit.Meter, _lastCenter!, center);
    final zoomDiff = (zoom - _lastZoom!).abs();

    final movedFarEnough = dist >= minDistanceMeters;
    final zoomChangedEnough = zoomDiff >= minZoomDelta;

    if (movedFarEnough || zoomChangedEnough) {
      _lastCenter = center;
      _lastZoom = zoom;
      return true;
    }

    return false;
  }
}
