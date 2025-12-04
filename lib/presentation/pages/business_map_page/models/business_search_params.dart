// domain/models/business_search_params.dart (o similar)
import 'package:latlong2/latlong.dart';

import "../state/business_filters_state.dart";

class BusinessSearchParams {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String searchQuery;
  final List<String> categoriesIds;

  // ✅ Filtros de gamificación
  final bool onlyWithGamesActive;
  final bool onlyWithRedeemableRewards;
  final bool onlyAlliedCompanies;

  const BusinessSearchParams({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.searchQuery,
    required this.categoriesIds,
    required this.onlyWithGamesActive,
    required this.onlyWithRedeemableRewards,
    required this.onlyAlliedCompanies,
  });

  /// Construye el DTO a partir del estado de filtros + centro del mapa.
  factory BusinessSearchParams.fromState({
    required LatLng center,
    required BusinessFiltersState filters,
    double? defaultRadiusKm,
  }) {
    return BusinessSearchParams(
      latitude: center.latitude,
      longitude: center.longitude,
      radiusKm: filters.radiusKm == 0
          ? (defaultRadiusKm ?? 10)
          : filters.radiusKm,
      searchQuery: filters.searchQuery,
      categoriesIds: filters.categoriesIds,
      onlyWithGamesActive: filters.onlyWithGamesActive,
      onlyWithRedeemableRewards: filters.onlyWithRedeemableRewards,
      onlyAlliedCompanies: filters.onlyAlliedCompanies,
    );
  }

  BusinessSearchParams copyWith({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? searchQuery,
    List<String>? categoriesIds,
    bool? onlyWithGamesActive,
    bool? onlyWithRedeemableRewards,
    bool? onlyAlliedCompanies,
  }) {
    return BusinessSearchParams(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      searchQuery: searchQuery ?? this.searchQuery,
      categoriesIds: categoriesIds ?? this.categoriesIds,
      onlyWithGamesActive: onlyWithGamesActive ?? this.onlyWithGamesActive,
      onlyWithRedeemableRewards:
          onlyWithRedeemableRewards ?? this.onlyWithRedeemableRewards,
      onlyAlliedCompanies: onlyAlliedCompanies ?? this.onlyAlliedCompanies,
    );
  }
}
