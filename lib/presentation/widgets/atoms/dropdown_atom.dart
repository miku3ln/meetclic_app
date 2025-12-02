import 'package:flutter/material.dart';
import 'atom_styles.dart';

class DropdownAtom extends StatelessWidget {
  final String? label;
  final List<String> items;
  final String value;
  final ValueChanged<String?>? onChanged;

  const DropdownAtom({
    this.label,
    required this.items,
    required this.value,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(
            e,
            style: AtomStyles.dropdownItemStyle.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AtomStyles.labelTextStyle.copyWith(
          color: theme.textTheme.titleSmall?.color,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AtomStyles.dropdownPaddingVertical,
          horizontal: AtomStyles.dropdownPaddingHorizontal,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
          ),
          borderRadius: AtomStyles.inputBorder.borderRadius,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.secondary,
            width: 1.5,
          ),
          borderRadius: AtomStyles.inputBorder.borderRadius,
        ),
      ),
    );
  }
}
