import 'package:flutter/material.dart';
import 'atom_styles.dart';

class SwitchToggleAtom extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchToggleAtom({
    required this.value,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
      inactiveThumbColor: theme.colorScheme.onSurface.withOpacity(0.5),
    );
  }
}
