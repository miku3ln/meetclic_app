import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../../../../../domain/services/session_service.dart';
import '../../../../../../../../infrastructure/config/server_config.dart';
import '../../../../../../../../shared/models/api_response.dart';
import '../../../../../../../../shared/pagination_response.dart';
import '../../../../../../../../shared/utils/util_common.dart';

class CategoryListRepository {
  final int total;

  const CategoryListRepository({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required String searchPhrase,
    required int rowCount,
  }) async {
    final token = SessionService().apiToken;
    final businessId = SessionService().businessId;
    final uriManagement =
        '${ServerConfig.baseUrl}/pointsales/category-by-business';

    return SafeExecutor.run(
      () async {
        final uri =
            Uri.parse(uriManagement) //POS-PRODUCTS -INIT-ONE
                .replace(
                  queryParameters: {
                    'current': current.toString(),
                    'rowCount': rowCount.toString(),
                    'searchPhrase': searchPhrase,
                    'business_id': businessId.toString(),
                  },
                );
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${token!}',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode != 200) {
          return const PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
            current: 1,
            rowCount: 0,
            rows: [],
            total: 0,
          );
        }
        final data = jsonDecode(response.body);

        final rows = (data['rows'] as List).map((json) {
          return GenericListItem<Map<String, dynamic>>(
            id: json['id'],
            title: json['value'],
            subtitle: json['subtitle'],
            description: json['description'] ?? '',
            image: json['source'],
            data: json,
          );
        }).toList();

        return PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
          current: data['current'] ?? current,
          rowCount: data['rowCount'] ?? rowCount,
          rows: rows,
          total: data['total'] ?? 0,
        );
      },
      PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
        current: 1,
        rowCount: 0,
        rows: [],
        total: 0,
      ),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createCategory(
    Map<String, dynamic> payload, {
    File? image,
  }) async {
    try {
      final token = SessionService().apiToken;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ServerConfig.baseUrl}/pointsales/category-by-business-save',
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Payload como JSON
      request.fields['payload'] = jsonEncode(payload);
      if (image == null) {
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }
      // Imagen

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return ApiResponse.success(
          message: body['message'] ?? 'Operación realizada correctamente',
          data: body,
        );
      }

      String message = 'Error desconocido';
      try {
        final errorRaw = body['error']?['message'];

        if (errorRaw != null) {
          final errorJson = jsonDecode(errorRaw) as Map<String, dynamic>;
          final table = errorJson['table'];
          final errors = errorJson['errors'] as Map<String, dynamic>? ?? {};
          if (errors.isNotEmpty) {
            final field = errors.keys.first;
            final fieldErrors = List<String>.from(errors[field]);
            message = '[$table] ${fieldErrors.first}';
          }
        }
      } catch (_) {
        message =
            body['error']?['message'] ?? body['message'] ?? 'Error desconocido';
      }

      return ApiResponse.error(message);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateCategory(
    Map<String, dynamic> payload, {
    File? image,
  }) async {
    try {
      final token = SessionService().apiToken;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ServerConfig.baseUrl}/pointsales/category-by-business-update',
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      // Payload como JSON
      request.fields['payload'] = jsonEncode(payload);
      if (image == null) {
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return ApiResponse.success(
          message: body['message'] ?? 'Operación realizada correctamente',
          data: body,
        );
      }

      String message = 'Error desconocido';

      try {
        final errorRaw = body['error']?['message'];

        if (errorRaw != null) {
          final errorJson = jsonDecode(errorRaw) as Map<String, dynamic>;
          final table = errorJson['table'];
          final errors = errorJson['errors'] as Map<String, dynamic>? ?? {};
          if (errors.isNotEmpty) {
            final field = errors.keys.first;
            final fieldErrors = List<String>.from(errors[field]);
            message = '[$table] ${fieldErrors.first}';
          }
        }
      } catch (_) {
        message =
            body['error']?['message'] ?? body['message'] ?? 'Error desconocido';
      }

      return ApiResponse.error(message);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
