import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/domain/usecases/get_nearby_businesses_usecase.dart';

class BusinessMapService {
  final GetNearbyBusinessesUseCase useCase;
  final double defaultRadiusKm;

  BusinessMapService({required this.useCase, this.defaultRadiusKm = 10});

  Future<List<BusinessModel>> fetchBusinesses(
    double latitude,
    double longitude, {
    double? radiusKm,
  }) async {
    final response = await useCase.execute(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm ?? defaultRadiusKm,
    );
    return response.data ?? [];
  }
}
