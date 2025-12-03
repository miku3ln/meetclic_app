import '../models/api_response_model.dart';
import '../models/business_model.dart';

abstract class BusinessRepository {
  Future<ApiResponseModel<List<BusinessModel>>> getNearbyBusinesses({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required String searchQuery,
    required List<String> categoriesIds,
  });
}

abstract class BusinessDetailsRepository {
  Future<ApiResponseModel<List<BusinessModel>>> getBusinessesDetails({
    required int businessId,
  });
}
