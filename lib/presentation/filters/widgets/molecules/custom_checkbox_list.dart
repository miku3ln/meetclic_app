import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/filters/widgets/atoms/custom_checkbox.dart';

class CustomCheckboxList extends StatelessWidget {
  final Map<String, bool> values;
  final ValueChanged<String> onToggle;

  const CustomCheckboxList({
    super.key,
    required this.values,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: values.entries.map((entry) {
        return CustomCheckbox(
          value: entry.value,
          label: entry.key,
          onChanged: (_) => onToggle(entry.key),
        );
      }).toList(),
    );
  }
}
