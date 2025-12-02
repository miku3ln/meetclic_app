import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.flag, color: theme.iconTheme.color),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 4),
              Text('5', style: TextStyle(fontSize: 12,color: theme.colorScheme.secondary)),
              const SizedBox(width: 16),
              const Icon(Icons.diamond, color: Colors.cyan),
              const SizedBox(width: 4),
              Text('2480', style: TextStyle(fontSize: 12,color: theme.colorScheme.secondary)),
              const SizedBox(width: 16),
              Icon(Icons.emoji_events, color: theme.colorScheme.surface),
            ],
          ),
        ],
      ),
    );
  }
}
