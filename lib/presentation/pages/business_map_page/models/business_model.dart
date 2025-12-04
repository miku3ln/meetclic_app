import '../../../../domain/models/business_model.dart';

extension BusinessGamificationX on BusinessModel {
  /// ¿Tiene alguna configuración de gamificación?
  bool get hasGamification => gamificationId > 0;

  /// ¿Permite canje dentro de la misma empresa?
  bool get canRedeemHere => allowExchange == 1;

  /// ¿Permite canje con empresas aliadas?
  bool get canRedeemWithAllies => allowExchangeBusiness == 1;

  /// ¿Tiene al menos algún tipo de premio/canje disponible?
  bool get hasAnyRewards =>
      hasGamification && (canRedeemHere || canRedeemWithAllies);
}
