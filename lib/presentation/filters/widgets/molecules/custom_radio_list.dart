import 'package:flutter/material.dart';

class CustomRadioList extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final String label;

  const CustomRadioList({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    final TextStyle titleStyle =TextStyle(
      color: theme.primaryColor,
      fontSize:18,
      height: 2
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: titleStyle),
         SizedBox(height: 4),
        ...options.map((option) => RadioListTile<String>(
          value: option,
          groupValue: selected,
          onChanged: onChanged,
          title: Text(option, style: titleStyle),
          activeColor: theme.colorScheme.primary,
          dense: true, // Hace que ocupe menos altura vertical
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          visualDensity: VisualDensity.compact, // Reduce el espacio interno
        )),
      ],
    );
  }
}