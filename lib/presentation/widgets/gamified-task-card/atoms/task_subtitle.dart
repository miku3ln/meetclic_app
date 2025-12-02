import 'package:flutter/material.dart';

class TaskSubtitle extends StatelessWidget {
  final String subtitle;
  const TaskSubtitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      subtitle,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
