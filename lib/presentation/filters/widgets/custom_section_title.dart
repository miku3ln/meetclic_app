import 'package:flutter/material.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;

  const CustomSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final TextStyle titleStyle =TextStyle(
      color: theme.primaryColor,
      fontSize:18,
    );
    return Text(
      title,
      style: titleStyle,
    );
  }
}
