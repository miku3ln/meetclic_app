class DeviceLocation {
  final double latitude;
  final double longitude;
  final double altitude; // metros (puede ser 0 si no disponible)
  final DateTime timestamp;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
  });

  @override
  String toString() =>
      'DeviceLocation(lat:$latitude, lon:$longitude, alt:${altitude}m, t:$timestamp)';
}
