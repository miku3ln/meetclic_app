import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final Color? activeColor;

  const CustomSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final TextStyle titleStyle =TextStyle(
      color: theme.primaryColor,
      fontSize:18,
      height: 4
    );
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: titleStyle),
      activeColor: activeColor ?? theme.colorScheme.primary,
    );
  }
}
