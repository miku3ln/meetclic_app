import '../../presentation/pages/business_map_page/models/business_search_params.dart';
import '../models/api_response_model.dart';
import '../models/business_model.dart';
import '../repositories/business_repository.dart';

class GetNearbyBusinessesUseCase {
  final BusinessRepository repository;

  GetNearbyBusinessesUseCase({required this.repository});

  Future<ApiResponseModel<List<BusinessModel>>> execute(
    BusinessSearchParams params,
  ) async {
    return await repository.getNearbyBusinesses(params);
  }
}

class BusinessesDetailsUseCase {
  final BusinessDetailsRepository repository;
  BusinessesDetailsUseCase({required this.repository});
  Future<ApiResponseModel<List<BusinessModel>>> execute({
    required int businessId,
  }) async {
    return await repository.getBusinessesDetails(businessId: businessId);
  }
}
