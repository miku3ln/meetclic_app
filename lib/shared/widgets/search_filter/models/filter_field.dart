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

  /// Permite seleccionar varios valores
  final bool multiple;

  /// Valor inicial
  final T? defaultValue;

  /// Lista de opciones (Dropdown, Radio, MultiSelect...)
  final List<FilterItem<T>> items;

  /// Placeholder del campo
  final String? placeholder;

  /// Texto de ayuda
  final String? helperText;

  /// Para DatePicker, Number, etc.
  final T? minValue;

  final T? maxValue;

  /// Si es obligatorio
  final String? validationMessage;

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
    this.placeholder,
    this.helperText,
    this.minValue,
    this.maxValue,
    this.validationMessage,
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
    T? defaultValue,
    List<FilterItem<T>>? items,
    String? placeholder,
    String? helperText,
    T? minValue,
    T? maxValue,
    String? validationMessage,
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
      placeholder: placeholder ?? this.placeholder,
      helperText: helperText ?? this.helperText,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      validationMessage:
      validationMessage ?? this.validationMessage,
    );
  }
}