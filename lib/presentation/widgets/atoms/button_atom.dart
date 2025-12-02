import 'package:flutter/material.dart';
import 'atom_styles.dart';

class ButtonAtom extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? height;

  const ButtonAtom({
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textStyle,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height ?? AtomStyles.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtomStyles.buttonBorderRadius),
          ),
        ),
        child: Text(
          text,
          style: (textStyle ?? AtomStyles.buttonTextStyle).copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
