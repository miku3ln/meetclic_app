// presentation/pages/business_map_page/state/business_filters_state.dart
class BusinessFiltersState {
  final double radiusKm; // 1 - 50 km
  final Set<int> selectedCategoryIds; // ids o códigos de categorías
  final String searchQuery; // texto del input superior

  const BusinessFiltersState({
    required this.radiusKm,
    required this.selectedCategoryIds,
    required this.searchQuery,
  });

  factory BusinessFiltersState.initial() => const BusinessFiltersState(
    radiusKm: 10,
    selectedCategoryIds: {},
    searchQuery: '',
  );

  BusinessFiltersState copyWith({
    double? radiusKm,
    Set<int>? selectedCategoryIds,
    String? searchQuery,
  }) {
    return BusinessFiltersState(
      radiusKm: radiusKm ?? this.radiusKm,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
