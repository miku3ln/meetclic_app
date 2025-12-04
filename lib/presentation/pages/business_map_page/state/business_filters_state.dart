import '../models/search_location_info_model.dart';

class BusinessFiltersState {
  final String searchQuery;
  final double radiusKm;
  final List<String> categoriesIds;
  final SearchLocationInfoModel? currentLocationInfo;
  const BusinessFiltersState({
    required this.searchQuery,
    required this.radiusKm,
    required this.categoriesIds,
    required this.currentLocationInfo,
  });

  factory BusinessFiltersState.initial() => const BusinessFiltersState(
    searchQuery: '',
    radiusKm: 10, // km por defecto
    categoriesIds: [],
    currentLocationInfo: null,
  );

  BusinessFiltersState copyWith({
    String? searchQuery,
    double? radiusKm,
    List<String>? categoriesIds,
    SearchLocationInfoModel? currentLocationInfo,
  }) {
    return BusinessFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      radiusKm: radiusKm ?? this.radiusKm,
      categoriesIds: categoriesIds ?? this.categoriesIds,
      currentLocationInfo: currentLocationInfo ?? this.currentLocationInfo,
    );
  }
}
