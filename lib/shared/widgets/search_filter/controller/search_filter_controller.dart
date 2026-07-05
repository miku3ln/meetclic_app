import 'dart:async';

import 'package:flutter/material.dart';

import '../models/filter_value.dart';
import '../models/search_filter_result.dart';
import 'search_filter_event.dart';
import 'search_filter_events.dart';

class SearchFilterController {
  SearchFilterController();
  void setValue<T>(
      String fieldId,
      T? value,
      String displayValue,
      ) {
    final index = _filters.indexWhere((e) => e.fieldId == fieldId);

    final newValue = FilterValue<T>(
      fieldId: fieldId,
      value: value,
      displayValue: displayValue,
    );

    if (index == -1) {
      _filters.add(newValue);
    } else {
      _filters[index] = newValue;
    }

    emit(SearchFilterEvents.filterChanged, newValue);
  }

  T? getValue<T>(String fieldId) {
    final filter = _filters.where((e) => e.fieldId == fieldId);

    if (filter.isEmpty) return null;

    return filter.first.value as T?;
  }


  //---------------------------------------------------------
  // Controllers
  //---------------------------------------------------------

  final TextEditingController searchController = TextEditingController();

  final FocusNode searchFocusNode = FocusNode();

  //---------------------------------------------------------
  // Streams
  //---------------------------------------------------------

  final StreamController<SearchFilterEvent> _events =
      StreamController.broadcast();

  Stream<SearchFilterEvent> get events => _events.stream;

  //---------------------------------------------------------
  // State
  //---------------------------------------------------------

  final List<FilterValue> _filters = [];

  bool _drawerOpened = false;

  bool _loading = false;

  //---------------------------------------------------------
  // Getters
  //---------------------------------------------------------

  String get search => searchController.text.trim();

  bool get drawerOpened => _drawerOpened;

  bool get loading => _loading;

  List<FilterValue> get filters => List.unmodifiable(_filters);

  int get totalFilters => _filters.length;

  //---------------------------------------------------------
  // Drawer
  //---------------------------------------------------------

  void openDrawer() {
    _drawerOpened = true;

    emit(SearchFilterEvents.drawerOpened);
  }

  void closeDrawer() {
    _drawerOpened = false;

    emit(SearchFilterEvents.drawerClosed);
  }

  //---------------------------------------------------------
  // Search
  //---------------------------------------------------------

  void setSearch(String value) {
    searchController.text = value;

    emit(SearchFilterEvents.searchChanged, value);
  }

  void submitSearch() {
    emit(SearchFilterEvents.searchSubmitted, buildResult());
  }

  void clearSearch() {
    searchController.clear();

    emit(SearchFilterEvents.searchCleared);
  }

  //---------------------------------------------------------
  // Filters
  //---------------------------------------------------------

  void updateFilter(FilterValue value) {
    final index = _filters.indexWhere((e) => e.fieldId == value.fieldId);

    if (index == -1) {
      _filters.add(value);
    } else {
      _filters[index] = value;
    }

    emit(SearchFilterEvents.filterChanged, value);
  }

  void removeFilter(String fieldId) {
    _filters.removeWhere((e) => e.fieldId == fieldId);

    emit(SearchFilterEvents.filterRemoved, fieldId);
  }

  void resetFilters() {
    _filters.clear();

    emit(SearchFilterEvents.filterReset);
  }

  //---------------------------------------------------------
  // Apply
  //---------------------------------------------------------

  SearchFilterResult buildResult() {
    return SearchFilterResult(search: search, filters: filters);
  }

  void apply() {
    emit(SearchFilterEvents.filterApplied, buildResult());
  }

  void cancel() {
    emit(SearchFilterEvents.filterCancelled);
  }

  //---------------------------------------------------------
  // Loading
  //---------------------------------------------------------

  void setLoading(bool value) {
    _loading = value;
  }

  //---------------------------------------------------------
  // Generic emitter
  //---------------------------------------------------------

  void emit(String type, [dynamic data]) {
    if (_events.isClosed) {
      return;
    }

    _events.add(SearchFilterEvent(type: type, data: data));
  }

  //---------------------------------------------------------
  // Dispose
  //---------------------------------------------------------

  void dispose() {
    searchController.dispose();

    searchFocusNode.dispose();

    _events.close();
  }
}
