import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:meetclic_app/infrastructure/models/summary_model.dart';

import '../models/user_data_login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class FakeAuthService {
  static const String _user = 'admin';
  static const String _pass = '123456789@';

  Future<UserDataLogin> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // ⏳ simula red

    if (email.trim() != _user || password != _pass) {
      throw Exception('Credenciales inválidas (usa admin / 123456789@)');
    }

    // ✅ Summary con datos para que se vea en MenuTabUpController
    final summary = MovementSummaryModel(
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

    return UserDataLogin(
      userId: 1,
      userName: 'Administrador',
      email: 'admin',
      userStatus: 'ACTIVE',
      roleId: 1,
      roleName: 'ADMIN',
      accessToken: 'fake-token-admin',

      // opcionales
      username: 'admin',
      avatar: null,
      customerId: null,
      identificationDocument: null,
      businessName: null,
      businessReason: null,
      hasRepresentative: null,
      representativeFullname: null,
      rucTypeId: null,
      rucTypeName: null,
      peopleTypeId: null,
      peopleTypeName: null,
      peopleTypeCode: 'N',
      personId: 1,
      lastName: 'Admin',
      personName: 'Admin',
      birthdate: '1990-01-01',
      age: 35,
      gender: 1,

      summary: summary,
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