import 'package:flutter/material.dart';

class RewardDescription extends StatelessWidget {
  final String description;
  const RewardDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color:
            theme.colorScheme.onPrimary, // se puede personalizar desde el Theme
      ),
    );
  }
}
