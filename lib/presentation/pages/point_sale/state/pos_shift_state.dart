import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/controllers/app_controller.dart';
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

class PosShiftState extends ChangeNotifier {
  final AppController app;
  final PosShiftStorage storage;
  VoidCallback? onRequestOpenShift;

  bool isShiftOpen = false;
  double? initialCash;
  int? openedByUserId;
  DateTime? openedAt;
  PosShiftSession? currentSession;

  PosShiftState({
    required this.app,
    required this.storage,
  });

  void onOpenShiftTap() => onRequestOpenShift?.call();

  bool get hasSavedOpenShift => currentSession != null && isShiftOpen;
  bool get canSell => isShiftOpen;

  Future<void> init() async {
    final savedShift = await storage.getShift();

    if (savedShift != null && savedShift.isShiftOpen) {
      _applySession(savedShift);
    } else {
      _clearLocalState();
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> openShift({
    required double initialCash,
  }) async {
    final currentUser = app.currentUser;

    if (currentUser == null) {
      return {
        'success': false,
        'data': null,
        'message': 'No existe un usuario en sesión',
      };
    }

    try {
      final session = PosShiftSession(
        userId: currentUser.userId,
        openingAmount: initialCash,
        openedAt: DateTime.now(),
        isShiftOpen: true,
      );

      await storage.saveShift(session);
      _applySession(session);

      notifyListeners();

      return {
        'success': true,
        'data': {
          'isShiftOpen': isShiftOpen,
          'initialCash': this.initialCash,
          'openedByUserId': openedByUserId,
          'openedAt': openedAt?.toIso8601String(),
        },
        'message': 'Caja abierta correctamente',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'No se pudo guardar la sesión del turno: $e',
      };
    }
  }

  Future<Map<String, dynamic>> closeShift() async {
    try {
      await storage.clearShift();
      _clearLocalState();

      notifyListeners();

      return {
        'success': true,
        'data': null,
        'message': 'Caja cerrada correctamente',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'No se pudo cerrar la caja: $e',
      };
    }
  }

  void _applySession(PosShiftSession session) {
    currentSession = session;
    isShiftOpen = session.isShiftOpen;
    initialCash = session.openingAmount;
    openedByUserId = session.userId;
    openedAt = session.openedAt;
  }

  void _clearLocalState() {
    currentSession = null;
    isShiftOpen = false;
    initialCash = null;
    openedByUserId = null;
    openedAt = null;
  }
}