import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final Color? activeColor;
  final Color? checkColor;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    final TextStyle titleStyle =TextStyle(
      color: theme.primaryColor,
      fontSize:18,
    );
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor:  theme.colorScheme.secondary,
      checkColor: theme.colorScheme.primary,
      title: Text(label, style:titleStyle),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}