class C2BGamificationTask {
  final int id; // ID en gamification_by_process
  final String code; // C2B-01, C2B-10, etc.

  /// name / description:
  /// [Verbo en infinitivo] + [objeto] + [beneficio opcional]
  final String name;
  final String description;

  /// Grupo visual/funcional en la app:
  /// 1: Interacción con la Empresa
  /// 2: Compra y Consumo
  /// 3: Feedback
  /// 4: Fidelización
  /// 5: Promoción
  /// 6: Premium
  final int groupId;
  final String groupName;

  /// Catálogo: gamification_type_activity
  /// 1: Share
  /// 2: Suscribirse
  /// 3: Referir
  /// 4: Registrarse
  /// 5: Compra
  /// 6: Pagos
  /// 7: Ventas
  /// 8: Atención al Cliente
  /// 9: Productividad
  /// 10: Compromiso del Empleado
  /// 11: Marketing
  final int gamificationTypeActivityId;
  final String gamificationTypeActivityName;

  // Configuración de campaña / empresa
  final String companyName; // "MeetClic"
  final int companyId; // 1

  /// Si es true, startDate y endDate deben tener valores.
  final bool hasExpiration;
  final DateTime? startDate; // con fecha + hora + minutos
  final DateTime? endDate; // con fecha + hora + minutos

  /// Puntos de la acción
  /// typePoints:
  ///   - "yapitas"
  ///   - "suma-yapitas" (para premium)
  final int points;
  final String typePoints;

  /// Fuente opcional (ej: url de campaña, banner, etc.)
  final String? sourceUrl;

  const C2BGamificationTask({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.groupId,
    required this.groupName,
    required this.gamificationTypeActivityId,
    required this.gamificationTypeActivityName,
    required this.companyName,
    required this.companyId,
    required this.hasExpiration,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.typePoints,
    this.sourceUrl,
  });
}
