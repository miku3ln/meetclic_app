import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/models/api_response_model.dart';

/// Helper genérico para peticiones HTTP seguras.
class NetworkHelper {
  /// Ejecuta una petición HTTP y captura errores de red.
  static Future<ApiResponseModel<T>> safeRequest<T>({
    required Future<http.Response> Function() requestFunction,
    required T Function(dynamic) parseData,
    required T emptyData, // <- Valor vacío (ej: {} o [])
  }) async {
    try {
      final response = await requestFunction();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return ApiResponseModel.fromJson(
          jsonResponse,
              (data) {
            try {
              return parseData(data);
            } catch (_) {
              return emptyData;
            }
          },
        );
      } else {
        return ApiResponseModel<T>(
          type: 0,
          success: false,
          message: 'Error ${response.statusCode}: ${response.reasonPhrase}',
          data: emptyData,
        );
      }

    } on SocketException {
      return ApiResponseModel<T>.error('No hay conexión a Internet.', emptyData);
    } on HttpException {
      return ApiResponseModel<T>.error('Error de servidor.', emptyData);
    } on FormatException {
      return ApiResponseModel<T>.error('Respuesta del servidor no válida.', emptyData);
    } catch (e) {
      return ApiResponseModel<T>.error('Error inesperado: $e', emptyData);
    }
  }
}
