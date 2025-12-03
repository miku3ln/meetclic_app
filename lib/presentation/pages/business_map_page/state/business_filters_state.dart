class BusinessFiltersState {
  final String searchQuery;
  final double radiusKm;
  final List<String> categoriesIds;

  const BusinessFiltersState({
    required this.searchQuery,
    required this.radiusKm,
    required this.categoriesIds,
  });

  factory BusinessFiltersState.initial() => const BusinessFiltersState(
    searchQuery: '',
    radiusKm: 10, // km por defecto
    categoriesIds: [],
  );

  BusinessFiltersState copyWith({
    String? searchQuery,
    double? radiusKm,
    List<String>? categoriesIds,
  }) {
    return BusinessFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      radiusKm: radiusKm ?? this.radiusKm,
      categoriesIds: categoriesIds ?? this.categoriesIds,
    );
  }
}
