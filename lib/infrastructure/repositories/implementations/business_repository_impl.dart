import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../domain/models/api_response_model.dart';
import '../../../domain/models/business_model.dart';
import '../../../domain/repositories/business_repository.dart';
import '../../../presentation/pages/business_map_page/models/business_search_params.dart';
import '../../config/server_config.dart';
import '../../network/network_helper.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  @override
  Future<ApiResponseModel<List<BusinessModel>>> getNearbyBusinesses(
    BusinessSearchParams params,
  ) async {
    final url = Uri.parse(
      '${ServerConfig.baseUrl}/business/searchNearbyBusinesses',
    );
    final String categoriesIdsCurrent = (params.categoriesIds ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(',');
    final body = {
      'latitude': params.latitude,
      'longitude': params.longitude,
      'radius_km': params.radiusKm,
      'subcategory_ids': categoriesIdsCurrent,
      'searchQuery': params.searchQuery,
      'onlyWithGamesActive': params.onlyWithGamesActive,
      'onlyWithRedeemableRewards': params.onlyWithRedeemableRewards,
      'onlyAlliedCompanies': params.onlyAlliedCompanies,
    };

    return NetworkHelper.safeRequest<List<BusinessModel>>(
      requestFunction: () {
        return http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      },
      parseData: (data) {
        if (data is List) {
          return data.map((item) => BusinessModel.fromJson(item)).toList();
        }
        return [];
      },
      emptyData: [], // Si falla, devuelves lista vacía segura
    );
  }
}

class BusinessDetailsRepositoryImpl implements BusinessDetailsRepository {
  @override
  Future<ApiResponseModel<List<BusinessModel>>> getBusinessesDetails({
    required int businessId,
  }) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/business/businessDetails');
    final body = {'businessId': businessId};
    return NetworkHelper.safeRequest<List<BusinessModel>>(
      requestFunction: () {
        return http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      },
      parseData: (data) {
        if (data is List) {
          return data.map((item) => BusinessModel.fromJson(item)).toList();
        }
        return [];
      },
      emptyData: [], // Si falla, devuelves lista vacía segura
    );
  }
}
