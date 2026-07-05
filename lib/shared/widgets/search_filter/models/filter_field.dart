import 'package:flutter/material.dart';

import 'filter_item.dart';

enum FilterFieldType {
  text,
  dropdown,
  multiSelect,
  checkbox,
  radio,
  switchField,
  date,
  dateRange,
  number,
  numberRange,
}

class FilterField<T> {
  final String id;

  final String label;

  final String? hint;

  final IconData? icon;

  final FilterFieldType type;

  final bool visible;

  final bool enabled;

  final bool required;

  final bool multiple;

  final dynamic defaultValue;

  final List<FilterItem<T>> items;

  const FilterField({
    required this.id,
    required this.label,
    required this.type,
    this.hint,
    this.icon,
    this.visible = true,
    this.enabled = true,
    this.required = false,
    this.multiple = false,
    this.defaultValue,
    this.items = const [],
  });

  FilterField<T> copyWith({
    String? id,
    String? label,
    String? hint,
    IconData? icon,
    FilterFieldType? type,
    bool? visible,
    bool? enabled,
    bool? required,
    bool? multiple,
    dynamic defaultValue,
    List<FilterItem<T>>? items,
  }) {
    return FilterField<T>(
      id: id ?? this.id,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      visible: visible ?? this.visible,
      enabled: enabled ?? this.enabled,
      required: required ?? this.required,
      multiple: multiple ?? this.multiple,
      defaultValue: defaultValue ?? this.defaultValue,
      items: items ?? this.items,
    );
  }
}