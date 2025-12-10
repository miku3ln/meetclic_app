// lib/infrastructure/gamification/datasources/business_c2b_config_local_source.dart

/// Fuente de configuración local (mock) que indica
/// qué tareas C2B del catálogo están activas para cada negocio.
///
/// Más adelante esto se puede reemplazar por:
/// - Llamadas a API (backend)
/// - Lectura desde base de datos local / remoto
/// sin cambiar la capa de dominio.
class BusinessC2BConfigLocalSource {
  const BusinessC2BConfigLocalSource();

  /// Devuelve los códigos de tareas C2B (ej: "C2B-01", "C2B-10")
  /// que están activas para un negocio específico.
  ///
  /// Esto simula una tabla tipo:
  /// business_by_gamification (business_id, task_code, enabled, ...)
  List<String> getActiveTaskCodesForBusiness(int businessId) {
    // Mapa: businessId -> lista de códigos C2B activos
    final config = <int, List<String>>{
      // =======================================
      // Negocio 1 – Ejemplo: "MeetClic Store"
      // Tiene una configuración amplia
      // =======================================
      1: [
        // Interacción
        'C2B-01', // Seguir negocio
        'C2B-02', // Visitar perfil
        'C2B-03', // Guardar favorito
        'C2B-04', // Compartir negocio
        'C2B-05', // Visitar tienda física
        'C2B-06', // Leer noticias
        // Compra y consumo
        'C2B-10', // Realizar compra
        'C2B-11', // Comprar producto destacado
        'C2B-12', // Suscribirse a plan
        'C2B-13', // Pagar con MeetClic Pay
        'C2B-14', // Canjear cupón
        'C2B-15', // Completar compra recomendada
        // Feedback
        'C2B-20', // Calificar negocio
        'C2B-21', // Escribir reseña
        'C2B-22', // Subir evidencia
        'C2B-23', // Responder encuesta
        'C2B-24', // Reportar problema
        // Fidelización
        'C2B-30', // Reclamar recompensa
        'C2B-31', // Participar en reto diario
        'C2B-32', // Participar en evento
        'C2B-33', // Compra mensual recurrente
        'C2B-34', // Enviar sugerencia
        // Promoción
        'C2B-40', // Compartir cupón
        'C2B-41', // Recomendar producto
        'C2B-42', // Invitar a seguir negocio
        // Premium
        'C2B-50', // Feedback avanzado NPS
        'C2B-51', // Participar en campaña de marca
        'C2B-52', // Completar misión especial
      ],

      // =======================================
      // Negocio 2 – Ejemplo: negocio pequeño
      // Tiene un set más reducido
      // =======================================
      2: [
        // Interacción básica
        'C2B-01',
        'C2B-02',
        'C2B-03',

        // Compra básica
        'C2B-10',

        // Feedback básico
        'C2B-20',
      ],

      // =======================================
      // Negocio 3 – Solo campañas de promoción
      // =======================================
      3: [
        'C2B-40', // Compartir cupón
        'C2B-41', // Recomendar producto
        'C2B-42', // Invitar a seguir negocio
      ],
    };

    // Si el negocio no tiene configuración, devolvemos algo básico
    return config[businessId] ??
        [
          // por defecto: catálogo mínimo
          'C2B-01', // Seguir negocio
          'C2B-10', // Realizar compra
        ];
  }

  /// Helper opcional:
  /// Verifica si una tarea concreta está activa para un negocio.
  bool isTaskActiveForBusiness({
    required int businessId,
    required String taskCode,
  }) {
    final activeCodes = getActiveTaskCodesForBusiness(businessId);
    return activeCodes.contains(taskCode);
  }
}
