import 'dart:math';

double _degToRad(double deg) => deg * pi / 180.0;

/// Distancia horizontal (2D) en metros entre dos coordenadas usando Haversine.
double haversineMeters({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const double R = 6371000; // m
  final phi1 = _degToRad(lat1);
  final phi2 = _degToRad(lat2);
  final dPhi = _degToRad(lat2 - lat1);
  final dLam = _degToRad(lon2 - lon1);

  final a =
      sin(dPhi / 2) * sin(dPhi / 2) +
      cos(phi1) * cos(phi2) * sin(dLam / 2) * sin(dLam / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

/// Distancia 3D en metros considerando altitud (en metros).
double distance3D({
  required double lat1,
  required double lon1,
  required double alt1,
  required double lat2,
  required double lon2,
  required double alt2,
}) {
  final horizontal = haversineMeters(
    lat1: lat1,
    lon1: lon1,
    lat2: lat2,
    lon2: lon2,
  );
  final dz = alt2 - alt1;
  return sqrt(horizontal * horizontal + dz * dz);
}
