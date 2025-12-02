import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/models/business_model.dart';
import '../../../domain/repositories/business_repository.dart';
import '../../config/server_config.dart';
import '../../network/network_helper.dart';
import '../../../domain/models/api_response_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  @override
  Future<ApiResponseModel<List<BusinessModel>>> getNearbyBusinesses({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    List<int>? subcategoryIds,
  }) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/business/searchNearbyBusinesses');

    final body = {
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'subcategoryIds': subcategoryIds ?? [0],
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
      emptyData: [],  // Si falla, devuelves lista vacía segura
    );
  }
}
class BusinessDetailsRepositoryImpl implements BusinessDetailsRepository {
  @override
  Future<ApiResponseModel<List<BusinessModel>>> getBusinessesDetails({
    required int businessId
  }) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/business/businessDetails');
    final body = {
      'businessId': businessId,
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
      emptyData: [],  // Si falla, devuelves lista vacía segura
    );
  }
}