import 'package:flutter/material.dart';

class MeetClicColors {
  static const azulClic = Color(0xFF4C4CFF);
  static const amarilloVital = Color(0xFFFFCC00);
  static const blanco = Color(0xFFFFFFFF);
  static const grisOscuro = Color(0xFF2C2C2C);
  static const moradoSuave = Color(0xFF5C5CFF);
  // Ajusta por el HEX real de Coral Social
  static const coralSocial = Color(0xFFFF6F61); // ejemplo
}

enum BusinessGamificationType {
  /// Sin gamificación configurada.
  none,

  /// Juegos / misiones activas, pero sin canje de puntos.
  basic,

  /// Permite canje de puntos en la misma empresa.
  redeemLocal,

  /// Permite canje con empresas aliadas (red andina / comunidad).
  redeemAllies,
}

/// Configuración visual + semántica de un tipo de gamificación.
class BusinessGamificationTypeConfig {
  /// Tipo lógico (none, basic, redeemLocal, redeemAllies).
  final BusinessGamificationType type;

  /// Clave única estable para usar en analytics, storage, etc.
  /// Ej: "gamification.none", "gamification.redeem_local"
  final String key;

  /// Color principal del marker / icono asociado al tipo.
  final Color primaryColor;

  /// Color del fondo del badge / chip que se muestra en UI.
  final Color badgeBackgroundColor;

  /// Color del texto dentro del badge.
  final Color badgeTextColor;

  /// Icono Material que usaremos en UI.
  final IconData icon;

  /// Nombre simbólico andino (para documentación o tooltips).
  ///
  /// Ej:
  /// - "Piedra" (base, sin juego)
  /// - "Chakana" (juego / aprendizaje)
  /// - "Inti" (sol, abundancia local)
  /// - "Minga" (red de aliados / comunidad)
  final String andeanSymbolName;

  /// Descripción corta del significado de este tipo
  /// en el contexto de MeetClic y la cultura andina.
  final String description;

  const BusinessGamificationTypeConfig({
    required this.type,
    required this.key,
    required this.primaryColor,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.icon,
    required this.andeanSymbolName,
    required this.description,
  });

  /// Factory central para obtener la configuración según el tipo.
  factory BusinessGamificationTypeConfig.fromType(
    BusinessGamificationType type,
  ) {
    switch (type) {
      // ----------------------------------------------------------
      // 0) SIN GAMIFICACIÓN – "Piedra"
      // ----------------------------------------------------------
      case BusinessGamificationType.none:
        return BusinessGamificationTypeConfig(
          type: type,
          key: 'gamification.none',
          primaryColor: MeetClicColors.grisOscuro,
          badgeBackgroundColor: MeetClicColors.grisOscuro,
          badgeTextColor: MeetClicColors.blanco,
          icon: Icons.storefront, // negocio "normal"
          andeanSymbolName: 'Piedra',
          description:
              'Empresa sin juegos ni canjes. Representa la base, lo estático, '
              'como la piedra andina: presente, pero sin movimiento lúdico.',
        );

      // ----------------------------------------------------------
      // 1) BASIC – juegos sin canje – "Chakana"
      // ----------------------------------------------------------
      case BusinessGamificationType.basic:
        return BusinessGamificationTypeConfig(
          type: type,
          key: 'gamification.basic',
          primaryColor: MeetClicColors.moradoSuave,
          badgeBackgroundColor: MeetClicColors.moradoSuave,
          badgeTextColor: MeetClicColors.blanco,
          icon: Icons.videogame_asset_rounded,
          andeanSymbolName: 'Chakana',
          description:
              'Empresa con juegos y misiones activas pero sin canje de puntos. '
              'Simboliza la Chakana andina: puente de aprendizaje y evolución, '
              'más enfoque en experiencia que en premio material.',
        );

      // ----------------------------------------------------------
      // 2) REDEEM LOCAL – canje en la empresa – "Inti"
      // ----------------------------------------------------------
      case BusinessGamificationType.redeemLocal:
        return BusinessGamificationTypeConfig(
          type: type,
          key: 'gamification.redeem_local',
          primaryColor: MeetClicColors.amarilloVital,
          badgeBackgroundColor: MeetClicColors.amarilloVital,
          badgeTextColor: MeetClicColors.grisOscuro,
          icon: Icons.local_activity, // ticket / premio local
          andeanSymbolName: 'Inti',
          description:
              'Empresa donde puedes canjear puntos directamente. Representa a Inti, '
              'el Sol andino: luz y abundancia que se manifiestan en este lugar específico.',
        );

      // ----------------------------------------------------------
      // 3) REDEEM ALLIES – red de canje – "Minga"
      // ----------------------------------------------------------
      case BusinessGamificationType.redeemAllies:
        return BusinessGamificationTypeConfig(
          type: type,
          key: 'gamification.redeem_allies',
          primaryColor: MeetClicColors.coralSocial,
          badgeBackgroundColor: MeetClicColors.coralSocial,
          badgeTextColor: MeetClicColors.blanco,
          icon: Icons.groups_rounded, // red / comunidad
          andeanSymbolName: 'Minga',
          description:
              'Empresa que forma parte de una red de canje con otras empresas aliadas. '
              'Simboliza la Minga andina: trabajo y beneficio en comunidad, donde los '
              'puntos circulan entre varios negocios.',
        );
    }
  }
}
