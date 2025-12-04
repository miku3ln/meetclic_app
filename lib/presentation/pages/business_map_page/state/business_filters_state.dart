import '../models/search_location_info_model.dart';

class BusinessFiltersState {
  final String searchQuery;
  final double radiusKm;
  final List<String> categoriesIds;
  final SearchLocationInfoModel? currentLocationInfo;
  // 🔥 NUEVOS FILTROS
  final bool onlyWithGamesActive;
  final bool onlyWithRedeemableRewards;
  final bool onlyAlliedCompanies;
  const BusinessFiltersState({
    required this.searchQuery,
    required this.radiusKm,
    required this.categoriesIds,
    required this.currentLocationInfo,
    required this.onlyWithGamesActive,
    required this.onlyWithRedeemableRewards,
    required this.onlyAlliedCompanies,
  });

  factory BusinessFiltersState.initial() => const BusinessFiltersState(
    searchQuery: '',
    radiusKm: 10, // km por defecto
    categoriesIds: [],
    currentLocationInfo: null,
    onlyWithGamesActive: false,
    onlyWithRedeemableRewards: false,
    onlyAlliedCompanies: false,
  );

  BusinessFiltersState copyWith({
    String? searchQuery,
    double? radiusKm,
    List<String>? categoriesIds,
    SearchLocationInfoModel? currentLocationInfo,
    bool? onlyWithGamesActive,
    bool? onlyWithRedeemableRewards,
    bool? onlyAlliedCompanies,
  }) {
    return BusinessFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      radiusKm: radiusKm ?? this.radiusKm,
      categoriesIds: categoriesIds ?? this.categoriesIds,
      currentLocationInfo: currentLocationInfo ?? this.currentLocationInfo,
      onlyWithGamesActive: onlyWithGamesActive ?? this.onlyWithGamesActive,
      onlyWithRedeemableRewards:
          onlyWithRedeemableRewards ?? this.onlyWithRedeemableRewards,
      onlyAlliedCompanies: onlyAlliedCompanies ?? this.onlyAlliedCompanies,
    );
  }
}
