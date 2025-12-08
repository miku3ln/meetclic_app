import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';

import '../models/business_gamification_type_config.dart';

class MarkerHelper {
  /// Marker para la ubicación actual (tu ícono especial)
  static Marker buildCurrentLocationMarker(LatLng center) {
    return Marker(
      point: center,
      width: 60,
      height: 60,
      alignment: Alignment.center,
      key: const ValueKey('current_location_marker'),
      child: Image.asset(AppImages.pageBusinessMapMarkerPosition),
    );
  }

  /// Markers de negocios.
  /// Ahora recibe una función [resolveVisual] que define el asset y tamaño
  /// según el BusinessModel (propósito del marker).
  static List<Marker> buildBusinessMarkers({
    required List<BusinessModel> businesses,
    required MapController mapController,
    required PopupController popupController,
    required BusinessMarkerVisualConfig Function(BusinessModel) resolveVisual,
  }) {
    return businesses.map((business) {
      final markerPoint = LatLng(business.streetLat, business.streetLng);
      final visual = resolveVisual(business);

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
          child: Image.asset(visual.assetPath, fit: BoxFit.contain),
        ),
      );

      return marker;
    }).toList();
  }
}
