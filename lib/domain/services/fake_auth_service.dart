import 'dart:async';


import 'package:http/http.dart' as http;
import 'package:meetclic_app/infrastructure/models/summary_model.dart';

import '../../infrastructure/config/server_config.dart';
import '../../shared/models/api_response.dart';
import '../models/user_data_login.dart';
import 'dart:convert';
class AuthManagerService {
  static const String _user = 'admin';
  static const String _pass = '123456789@';
  Future<ApiResponse<UserDataLogin>> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${ServerConfig.baseUrl}/pointsales/login');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      // 🔍 Intentar parsear JSON (aunque falle status)
      final Map<String, dynamic> json =
      response.body.isNotEmpty ? jsonDecode(response.body) : {};

      // 🚨 1. MANEJO POR STATUS CODE
      switch (response.statusCode) {
        case 200:
        case 201:
        // OK
          break;

        case 202:
          return ApiResponse(
            success: false,
            message: json['message'] ?? 'Solicitud aceptada pero no completada',
            data: null,
          );

        case 400:
          return ApiResponse(
            success: false,
            message: json['message'] ?? 'Solicitud inválida',
            data: null,
          );

        case 401:
          return ApiResponse(
            success: false,
            message: json['message'] ?? 'Credenciales incorrectas',
            data: null,
          );

        case 403:
          return ApiResponse(
            success: false,
            message: json['message'] ?? 'Acceso denegado',
            data: null,
          );

        case 404:
          return ApiResponse(
            success: false,
            message: 'Endpoint no encontrado',
            data: null,
          );

        case 500:
        default:
          return ApiResponse(
            success: false,
            message: json['message'] ?? 'Error interno del servidor',
            data: null,
          );
      }

      // ✅ 2. VALIDAR ESTRUCTURA DEL BACKEND
      if (json['success'] != true) {
        return ApiResponse(
          success: false,
          message: json['message'] ?? 'Error en autenticación',
          data: null,
        );
      }

      if (json['data'] == null) {
        return ApiResponse(
          success: false,
          message: 'Respuesta sin datos',
          data: null,
        );
      }
      // ✅ 3. MAPEO SEGURO
      final user = UserDataLogin.fromJson(json['data']["userData"]);
      return ApiResponse(
        success: true,
        message: json['message'] ?? 'Login correcto',
        data: user,
      );
    } catch (e) {
      // 💥 ERROR TOTAL (red, parse, etc.)
      return ApiResponse(
        success: false,
        message: 'Error de conexión o formato inválido',
        data: null,
      );
    }
  }
  MovementSummaryModel _buildSummaryMock() {
    return MovementSummaryModel(
      yapitas: MovementAmountModel(
        totalInput: 1200,
        totalOutput: 200,
        currentBalance: 1000,
      ),
      yapitasPremium: MovementAmountModel(
        totalInput: 50,
        totalOutput: 10,
        currentBalance: 40,
      ),
      reputation: ReputationSummaryModel(total: 77),
      trophies: TrophiesSummaryModel(total: 12),
      visits: VisitsSummaryModel(total: 340),
      rating: RatingSummaryModel(
        positiveClients: 25,
        averageStars: 4.8,
        communityScore: 93.5,
      ),
    );
  }
}


