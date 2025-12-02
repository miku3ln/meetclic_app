import 'package:flutter/material.dart';

class DropdownSelector extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final double? width; // ✅ parámetro opcional

  const DropdownSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.width, // ✅ valor opcional
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 1, // ✅ valor por defecto: 200
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
