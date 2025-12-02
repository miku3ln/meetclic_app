import '../../core/utils/distance.dart';

final class ComputeDistance3D {
  const ComputeDistance3D();

  /// Distancia 3D en metros.
  double call({
    required double lat1,
    required double lon1,
    required double alt1,
    required double lat2,
    required double lon2,
    required double alt2,
  }) => distance3D(
    lat1: lat1,
    lon1: lon1,
    alt1: alt1,
    lat2: lat2,
    lon2: lon2,
    alt2: alt2,
  );
}
