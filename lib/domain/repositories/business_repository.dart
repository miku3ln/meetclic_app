import '../../presentation/pages/business_map_page/models/business_search_params.dart';
import '../models/api_response_model.dart';
import '../models/business_model.dart';

abstract class BusinessRepository {
  Future<ApiResponseModel<List<BusinessModel>>> getNearbyBusinesses(
    BusinessSearchParams params,
  );
}

abstract class BusinessDetailsRepository {
  Future<ApiResponseModel<List<BusinessModel>>> getBusinessesDetails({
    required int businessId,
  });
}
