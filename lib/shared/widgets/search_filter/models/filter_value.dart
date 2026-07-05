class FilterValue<T> {
  final String fieldId;

  final T? value;

  final String displayValue;

  const FilterValue({
    required this.fieldId,
    this.value,
    required this.displayValue,
  });

  FilterValue<T> copyWith({
    String? fieldId,
    T? value,
    String? displayValue,
  }) {
    return FilterValue<T>(
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      displayValue: displayValue ?? this.displayValue,
    );
  }
}