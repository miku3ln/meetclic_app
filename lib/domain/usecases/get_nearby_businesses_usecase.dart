import '../models/api_response_model.dart';
import '../models/business_model.dart';
import '../repositories/business_repository.dart';

class GetNearbyBusinessesUseCase {
  final BusinessRepository repository;

  GetNearbyBusinessesUseCase({required this.repository});

  Future<ApiResponseModel<List<BusinessModel>>> execute({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    List<int>? subcategoryIds,
  }) async {
    return await repository.getNearbyBusinesses(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      subcategoryIds: subcategoryIds,
    );
  }
}
class BusinessesDetailsUseCase {
  final BusinessDetailsRepository repository;
  BusinessesDetailsUseCase({required this.repository});
  Future<ApiResponseModel<List<BusinessModel>>> execute({
    required int businessId,
  }) async {
    return await repository.getBusinessesDetails(
      businessId: businessId,

    );
  }
}
