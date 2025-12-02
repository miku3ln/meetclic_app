import 'package:flutter/material.dart';

class RewardTitle extends StatelessWidget {
  final String title;
  const RewardTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold)
          .copyWith(
            color: theme
                .colorScheme
                .secondary, // se puede personalizar desde el Theme
          ),
    );
  }
}
