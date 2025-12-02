import 'package:flutter/material.dart';

class GamificationScreenPage extends StatelessWidget {
  final String title;

  const GamificationScreenPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // usa el color global
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.appBarTheme.backgroundColor, // color global AppBar
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary, // se puede personalizar desde el Theme
          ),
        ),
      ),
    );
  }
}
