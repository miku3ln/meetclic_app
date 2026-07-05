import 'package:flutter/material.dart';

class FilterItem<T> {
  final String id;
  final String label;
  final T value;
  final IconData? icon;
  final Color? color;
  final bool enabled;

  const FilterItem({
    required this.id,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.enabled = true,
  });

  FilterItem<T> copyWith({
    String? id,
    String? label,
    T? value,
    IconData? icon,
    Color? color,
    bool? enabled,
  }) {
    return FilterItem<T>(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
    );
  }
}