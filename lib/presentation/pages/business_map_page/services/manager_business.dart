import '../models/business_position.dart';

class ManagerBusiness {
  // Posición por defecto
  BusinessPosition _currentPosition = const BusinessPosition(
    latitude: 0.2322591,
    longitude: -78.2590913,
    zoom: 5.0,
  );

  /// Getter limpio: obtienes el objeto
  BusinessPosition get currentPosition => _currentPosition;

  /// Si necesitas en Map:
  Map<String, dynamic> get currentPositionAsMap => _currentPosition.toMap();

  /// Getter específico
  double get currentZoom => _currentPosition.zoom;

  /// Método para actualizar (por si luego cambias)
  void updateCurrentPosition(BusinessPosition newPosition) {
    _currentPosition = newPosition;
  }
}
