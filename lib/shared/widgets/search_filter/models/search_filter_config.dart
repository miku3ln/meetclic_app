import 'filter_field.dart';

class SearchFilterConfig {
  final String hint;

  final String drawerTitle;

  final bool showSearch;

  final bool showFilterButton;

  final bool showFilterCounter;

  final bool showFilterChips;

  final bool closeDrawerOnApply;

  final bool autoSearch;

  final Duration searchDelay;

  final List<FilterField> fields;

  const SearchFilterConfig({
    this.hint = 'Buscar...',
    this.drawerTitle = 'Filtros',
    this.showSearch = true,
    this.showFilterButton = true,
    this.showFilterCounter = true,
    this.showFilterChips = true,
    this.closeDrawerOnApply = true,
    this.autoSearch = true,
    this.searchDelay = const Duration(milliseconds: 500),
    this.fields = const [],
  });

  SearchFilterConfig copyWith({
    String? hint,
    String? drawerTitle,
    bool? showSearch,
    bool? showFilterButton,
    bool? showFilterCounter,
    bool? showFilterChips,
    bool? closeDrawerOnApply,
    bool? autoSearch,
    Duration? searchDelay,
    List<FilterField>? fields,
  }) {
    return SearchFilterConfig(
      hint: hint ?? this.hint,
      drawerTitle: drawerTitle ?? this.drawerTitle,
      showSearch: showSearch ?? this.showSearch,
      showFilterButton: showFilterButton ?? this.showFilterButton,
      showFilterCounter:
      showFilterCounter ?? this.showFilterCounter,
      showFilterChips:
      showFilterChips ?? this.showFilterChips,
      closeDrawerOnApply:
      closeDrawerOnApply ?? this.closeDrawerOnApply,
      autoSearch: autoSearch ?? this.autoSearch,
      searchDelay: searchDelay ?? this.searchDelay,
      fields: fields ?? this.fields,
    );
  }
}