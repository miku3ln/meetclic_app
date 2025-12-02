import 'package:flutter/material.dart';
import 'atom_styles.dart';

class CheckboxAtom extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget? label;

  const CheckboxAtom({
    required this.value,
    this.onChanged,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
      title: label,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
