// presentation/pages/business_map_page/helpers/business_marker_visual_resolver.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';

import '../models/business_gamification_type_config.dart';
import '../models/meet_clic_colors.dart';
// <- aquí vive BusinessGamificationType y BusinessGamificationTypeConfig
//    si lo tienes en otro path, ajusta el import.

// --------------------------------------------------------------
// Resolver del tipo de gamificación a partir del BusinessModel
// --------------------------------------------------------------
class BusinessGamificationTypeResolver {
  static BusinessGamificationType fromBusiness(BusinessModel business) {
    if (business.gamificationId <= 0) {
      return BusinessGamificationType.none;
    }

    final bool canRedeemHere = business.allowExchange == 1;
    final bool canRedeemWithAllies = business.allowExchangeBusiness == 1;

    if (canRedeemWithAllies) {
      // Si hay red de aliados, lo consideramos el nivel más alto
      return BusinessGamificationType.redeemAllies;
    }

    if (canRedeemHere) {
      return BusinessGamificationType.redeemLocal;
    }

    // Tiene gamificación pero sin canje → básico
    return BusinessGamificationType.basic;
  }
}

// --------------------------------------------------------------
// Helper visual para los markers del mapa
// --------------------------------------------------------------
class BusinessMarkerVisualResolver {
  /// Devuelve la configuración visual (asset, tamaño, alineación)
  /// según las propiedades de la empresa.
  static BusinessMarkerVisualConfig resolve(BusinessModel business) {
    final BusinessGamificationType type =
        BusinessGamificationTypeResolver.fromBusiness(business);

    switch (type) {
      // ============================================
      // 0) SIN GAMIFICACIÓN – "Piedra"
      // ============================================
      case BusinessGamificationType.none:
        return const BusinessMarkerVisualConfig(
          assetPath: AppImages.businessMarkerNoGamification,
          width: 38,
          height: 38,
          alignment: Alignment.topCenter,
        );

      // ============================================
      // 1) BASIC – "Chakana" (juegos sin canje)
      // ============================================
      case BusinessGamificationType.basic:
        return const BusinessMarkerVisualConfig(
          assetPath: AppImages.businessMarkerBasicGamification,
          width: 40,
          height: 40,
          alignment: Alignment.topCenter,
        );

      // ============================================
      // 2) REDEEM LOCAL – "Inti"
      // ============================================
      case BusinessGamificationType.redeemLocal:
        return const BusinessMarkerVisualConfig(
          assetPath: AppImages.businessMarkerRedeemLocalIntiGamification,
          width: 42,
          height: 42,
          alignment: Alignment.topCenter,
        );

      // ============================================
      // 3) REDEEM ALLIES – "Minga" (Chakana + Ayllu)
      // ============================================
      case BusinessGamificationType.redeemAllies:
        return const BusinessMarkerVisualConfig(
          assetPath: AppImages.businessMarkerRedeemAlliesGamification,
          width: 46,
          height: 46,
          alignment: Alignment.topCenter,
        );
    }
  }

  /// (Opcional) Construir marker de negocio usando la config.
  static List<Marker> buildBusinessMarkers({
    required List<BusinessModel> businesses,
    required MapController mapController,
    required PopupController popupController,
  }) {
    return businesses.map((business) {
      final markerPoint = LatLng(business.streetLat, business.streetLng);
      final visual = resolve(business);

      late final Marker marker;
      marker = Marker(
        point: markerPoint,
        width: visual.width,
        height: visual.height,
        alignment: visual.alignment,
        child: GestureDetector(
          onTap: () {
            mapController.move(markerPoint, mapController.camera.zoom);
            popupController.showPopupsOnlyFor([marker]);
          },
          child: Image.asset(visual.assetPath),
        ),
      );

      return marker;
    }).toList();
  }
}
