import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final TextAlign textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  const TitleWidget({
    Key? key,
    required this.title,
    this.textAlign = TextAlign.left,
    this.fontSize,
    this.fontWeight,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle baseStyle = theme.textTheme.titleLarge!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? theme.textTheme.titleLarge!.color,
    );

    return Text(
      title,
      textAlign: textAlign,
      style: baseStyle,
    );
  }
}
