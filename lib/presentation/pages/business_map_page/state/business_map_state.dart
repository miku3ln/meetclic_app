// presentation/pages/business_map_page/state/business_map_state.dart
import 'package:flutter_map/flutter_map.dart';
import 'package:meetclic_app/domain/models/business_model.dart';

class BusinessMapState {
  final bool isLoading;
  final bool isGpsEnabled;
  final List<BusinessModel> businesses;
  final List<Marker> businessMarkers;
  final Marker? currentLocationMarker;

  const BusinessMapState({
    required this.isLoading,
    required this.isGpsEnabled,
    required this.businesses,
    required this.businessMarkers,
    required this.currentLocationMarker,
  });

  factory BusinessMapState.initial() => const BusinessMapState(
    isLoading: false,
    isGpsEnabled: false,
    businesses: [],
    businessMarkers: [],
    currentLocationMarker: null,
  );

  BusinessMapState copyWith({
    bool? isLoading,
    bool? isGpsEnabled,
    List<BusinessModel>? businesses,
    List<Marker>? businessMarkers,
    Marker? currentLocationMarker,
  }) {
    return BusinessMapState(
      isLoading: isLoading ?? this.isLoading,
      isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
      businesses: businesses ?? this.businesses,
      businessMarkers: businessMarkers ?? this.businessMarkers,
      currentLocationMarker:
          currentLocationMarker ?? this.currentLocationMarker,
    );
  }
}
