import '../repositories/device_sensors_repository.dart';

/// Config cross-plataforma para el stream de ubicación.
class LocationStreamConfig {
  final LocationAccuracyLevel accuracy;

  /// Distancia mínima en metros para emitir una nueva lectura (si el SO lo soporta).
  final int distanceFilterMeters;

  /// Mínimo intervalo sugerido entre lecturas.
  final Duration interval;

  const LocationStreamConfig({
    this.accuracy = LocationAccuracyLevel.balanced,
    this.distanceFilterMeters = 5,
    this.interval = const Duration(seconds: 3),
  });

  LocationStreamConfig copyWith({
    LocationAccuracyLevel? accuracy,
    int? distanceFilterMeters,
    Duration? interval,
  }) => LocationStreamConfig(
    accuracy: accuracy ?? this.accuracy,
    distanceFilterMeters: distanceFilterMeters ?? this.distanceFilterMeters,
    interval: interval ?? this.interval,
  );
}
