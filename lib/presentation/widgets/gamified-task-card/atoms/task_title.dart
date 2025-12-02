import 'package:flutter/material.dart';

class TaskTitle extends StatelessWidget {
  final String title;
  const TaskTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    );
  }
}
