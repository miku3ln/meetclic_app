class BusinessPosition {
  final double latitude;
  final double longitude;
  final double zoom;

  const BusinessPosition({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'zoom': zoom,
  };
}
