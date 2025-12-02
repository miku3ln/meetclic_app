import 'package:flutter/material.dart';
import 'atom_styles.dart';

class LabelAtom extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const LabelAtom({required this.text, this.style, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: (style ?? AtomStyles.labelTextStyle).copyWith(
        color: theme.textTheme.bodyMedium?.color,
      ),
    );
  }
}
