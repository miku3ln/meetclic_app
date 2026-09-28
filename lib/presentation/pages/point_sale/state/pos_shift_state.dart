import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../app/router/controllers/app_controller.dart';
import '../widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosShiftSession {
  final int userId;
  final double openingAmount;
  final DateTime openedAt;
  final bool isShiftOpen;
  final String typeOpen;

  const PosShiftSession({
    required this.userId,
    required this.openingAmount,
    required this.openedAt,
    required this.isShiftOpen,
    required this.typeOpen,

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
      userId: map['userId'] as int,typeOpen: "",
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

  VoidCallback? onRequestOpenShift;

  /**
   * ============================================================
   * CURRENT SESSION
   * ============================================================
   *
   * ÚNICA FUENTE DE VERDAD DEL ESTADO DE CAJA EN FLUTTER.
   */
  PosShiftSession? currentSession;

  PosShiftState({
    required this.app,
  });

  /**
   * ============================================================
   * GETTERS
   * ============================================================
   */

  bool get isShiftOpen =>
      currentSession?.isShiftOpen ?? false;

  double? get initialCash =>
      currentSession?.openingAmount;

  int? get openedByUserId =>
      currentSession?.userId;

  DateTime? get openedAt =>
      currentSession?.openedAt;

  String get typeOpen =>
      currentSession?.typeOpen ?? '';

  bool get hasSavedOpenShift =>
      currentSession != null && isShiftOpen;

  bool get canSell => isShiftOpen;

  /**
   * ============================================================
   * READ
   * ============================================================
   *
   * Laravel es la fuente persistente de verdad.
   *
   * Al iniciar el POS consultamos el estado actual
   * de la caja y actualizamos currentSession.
   */
  Future<void> loadData() async {
    final response =
    await UtilServicesCash.allowManagerCash();

    /**
     * Si no podemos consultar el servidor,
     * no asumimos que existe una caja abierta.
     */
    if (!response.success) {
      _clearLocalState();
      return;
    }

    final data = response.data;

    if (data == null) {
      _clearLocalState();
      return;
    }

    /**
     * ============================================================
     * SESSION
     * ============================================================
     */

    final sessionData = data['session'];

    if (sessionData is! Map<String, dynamic>) {
      _clearLocalState();
      return;
    }

    final bool isOpen =
        sessionData['is_open'] == true;

    /**
     * Laravel confirma que no existe
     * una sesión abierta.
     */
    if (!isOpen) {
      _clearLocalState();
      return;
    }

    /**
     * ============================================================
     * ASSIGNMENT
     * ============================================================
     */

    final assignmentData = data['assignment'];

    if (assignmentData is! Map<String, dynamic>) {
      _clearLocalState();
      return;
    }

    final int? userId =
    (assignmentData['user_id'] as num?)
        ?.toInt();

    final double? openingAmount =
    (sessionData['opening_amount'] as num?)
        ?.toDouble();

    final DateTime? openingDate =
    _parseServerDate(
      sessionData['opening_date']?.toString(),
    );

    /**
     * No creamos una sesión incompleta.
     */
    if (userId == null ||
        openingAmount == null ||
        openingDate == null) {
      _clearLocalState();
      return;
    }

    /**
     * ============================================================
     * APPLY SERVER SESSION
     * ============================================================
     */

    final session = PosShiftSession(
      typeOpen: 'preloadRegister',
      userId: userId,
      openingAmount: openingAmount,
      openedAt: openingDate,
      isShiftOpen: true,
    );

    _applySession(session);
  }

  /**
   * ============================================================
   * OPEN SHIFT TAP
   * ============================================================
   */

  void onOpenShiftTap() {
    onRequestOpenShift?.call();
  }

  /**
   * ============================================================
   * CREATE / UPDATE
   * ============================================================
   *
   * Se llama después de que Laravel confirme
   * correctamente la apertura de caja.
   *
   * Actualiza la sesión compartida en memoria.
   */
  Future<Map<String, dynamic>> openShift({
    required double initialCash,
    String messageSave = "",
    String messageNotSave = "",
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
        typeOpen: 'saveRegister',
        userId: currentUser.userId,
        openingAmount: initialCash,
        openedAt: DateTime.now(),
        isShiftOpen: true,
      );

      /**
       * Actualizamos la única sesión
       * compartida en memoria.
       */
      _applySession(session);

      return {
        'success': true,
        'data': _currentData(),
        'message': messageSave.isEmpty
            ? 'Caja abierta correctamente'
            : messageSave,
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': messageNotSave.isEmpty
            ? 'No se pudo actualizar la sesión del turno: $e'
            : messageNotSave,
      };
    }
  }

  /**
   * ============================================================
   * CREATE / UPDATE PRELOAD
   * ============================================================
   *
   * Permite establecer en memoria una caja
   * que ya se encontraba abierta.
   */
  Future<Map<String, dynamic>> openShiftPreload({
    required double initialCash,
    required DateTime openedAt,
    String messageSave = "",
    String messageNotSave = "",
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
        typeOpen: 'preloadRegister',
        userId: currentUser.userId,
        openingAmount: initialCash,
        openedAt: openedAt,
        isShiftOpen: true,
      );

      /**
       * Actualizamos la única sesión
       * compartida en memoria.
       */
      _applySession(session);

      return {
        'success': true,
        'data': _currentData(),
        'message': messageSave.isEmpty
            ? 'Caja cargada correctamente'
            : messageSave,
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': messageNotSave.isEmpty
            ? 'No se pudo actualizar la sesión del turno: $e'
            : messageNotSave,
      };
    }
  }

  /**
   * ============================================================
   * DELETE / CLOSE
   * ============================================================
   *
   * Debe ejecutarse después de que Laravel
   * confirme correctamente el cierre de caja.
   */
  Future<Map<String, dynamic>> closeShift() async {
    try {
      _clearLocalState();

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

  /**
   * ============================================================
   * CURRENT DATA
   * ============================================================
   *
   * Retorna los valores actuales de la caja.
   */
  Map<String, dynamic> getCurrentData() {
    return _currentData();
  }

  Map<String, dynamic> _currentData() {
    return {
      'isShiftOpen': isShiftOpen,
      'initialCash': initialCash,
      'openedByUserId': openedByUserId,
      'openedAt': openedAt?.toIso8601String(),
      'typeOpen': typeOpen,
    };
  }

  /**
   * ============================================================
   * APPLY SESSION
   * ============================================================
   *
   * Punto central para CREATE / UPDATE
   * del estado en memoria.
   */
  void _applySession(
      PosShiftSession session,
      ) {
    currentSession = session;

    notifyListeners();
  }

  /**
   * ============================================================
   * CLEAR SESSION
   * ============================================================
   *
   * Punto central para DELETE
   * del estado en memoria.
   */
  void _clearLocalState() {
    currentSession = null;

    notifyListeners();
  }

  /**
   * ============================================================
   * PARSE SERVER DATE
   * ============================================================
   */

  DateTime? _parseServerDate(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      value
          .trim()
          .replaceFirst(' ', 'T'),
    );
  }
}
