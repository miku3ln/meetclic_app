// presentation/pages/business_map_page/helpers/marker_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';

class MarkerHelper {
  /// Marker para la ubicación actual (tu ícono especial)
  static Marker buildCurrentLocationMarker(LatLng center) {
    return Marker(
      point: center,
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: Image.asset(AppImages.pageBusinessMapMarkerPosition),
    );
  }

  /// Markers de negocios.
  /// - Mueve el mapa al hacer tap
  /// - Muestra el popup del marker tocado
  static List<Marker> buildBusinessMarkers({
    required List<BusinessModel> businesses,
    required MapController mapController,
    required PopupController popupController,
  }) {
    return businesses.map((business) {
      final markerPoint = LatLng(business.streetLat, business.streetLng);

      late final Marker marker;
      marker = Marker(
        point: markerPoint,
        width: 40,
        height: 40,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            mapController.move(markerPoint, mapController.camera.zoom);
            // Mostramos el popup solo para este marker
            popupController.showPopupsOnlyFor([marker]);
          },
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );

      return marker;
    }).toList();
  }
}
