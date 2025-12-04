import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/domain/usecases/get_nearby_businesses_usecase.dart';

import '../models/business_search_params.dart';

class BusinessMapService {
  final GetNearbyBusinessesUseCase useCase;
  final double defaultRadiusKm;

  BusinessMapService({required this.useCase, this.defaultRadiusKm = 10});

  Future<List<BusinessModel>> fetchBusinesses(
    BusinessSearchParams params,
  ) async {
    final response = await useCase.execute(params);
    return response.data ?? [];
  }
}
