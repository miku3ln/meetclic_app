import 'filter_value.dart';

class SearchFilterResult {
  final String search;

  final List<FilterValue> filters;

  const SearchFilterResult({
    required this.search,
    required this.filters,
  });

  bool get hasSearch => search.trim().isNotEmpty;

  bool get hasFilters => filters.isNotEmpty;

  int get totalFilters => filters.length;

  SearchFilterResult copyWith({
    String? search,
    List<FilterValue>? filters,
  }) {
    return SearchFilterResult(
      search: search ?? this.search,
      filters: filters ?? this.filters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "search": search,
      "filters": {
        for (final filter in filters)
          filter.fieldId: filter.value,
      }
    };
  }
}