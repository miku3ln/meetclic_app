import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:meetclic_app/domain/services/session_service.dart';
import 'package:meetclic_app/infrastructure/models/summary_model.dart';

import '../../infrastructure/config/server_config.dart';
import '../../shared/models/api_response.dart';
import '../models/user_data_login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


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

class PosShiftSession {
  final int userId;
  final double openingAmount;
  final DateTime openedAt;
  final bool isShiftOpen;

  const PosShiftSession({
    required this.userId,
    required this.openingAmount,
    required this.openedAt,
    required this.isShiftOpen,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'openingAmount': openingAmount,
      'openedAt': openedAt.toIso8601String(),
      'isShiftOpen': isShiftOpen,
    };
  }

  factory PosShiftSession.fromMap(Map<String, dynamic> map) {
    return PosShiftSession(
      userId: map['userId'] as int,
      openingAmount: (map['openingAmount'] as num).toDouble(),
      openedAt: DateTime.parse(map['openedAt'] as String),
      isShiftOpen: map['isShiftOpen'] as bool,
    );
  }
}


class PosShiftStorage {
  static const String _key = 'pos_shift_session';

  Future<void> saveShift(PosShiftSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toMap()));
  }

  Future<PosShiftSession?> getShift() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PosShiftSession.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearShift() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
class PosShiftController extends ChangeNotifier {
  final PosShiftStorage storage;

  bool _isShiftOpen = false;
  bool get isShiftOpen => _isShiftOpen;

  PosShiftSession? _currentSession;
  PosShiftSession? get currentSession => _currentSession;

  PosShiftController({required this.storage});

  Future<void> init() async {
    final savedShift = await storage.getShift();

    if (savedShift != null && savedShift.isShiftOpen) {
      _currentSession = savedShift;
      _isShiftOpen = true;
    } else {
      _currentSession = null;
      _isShiftOpen = false;
    }

    notifyListeners();
  }

  Future<void> openShift2({
    required UserDataLogin user,
    required double openingAmount,
  }) async {
    final session = PosShiftSession(
      userId: user.userId,
      openingAmount: openingAmount,
      openedAt: DateTime.now(),
      isShiftOpen: true,
    );

    await storage.saveShift(session);

    _currentSession = session;
    _isShiftOpen = true;
    notifyListeners();
  }

  Future<void> closeShift() async {
    await storage.clearShift();
    _currentSession = null;
    _isShiftOpen = false;
    notifyListeners();
  }
}