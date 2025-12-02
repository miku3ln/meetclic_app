import 'package:flutter/material.dart';

class IconTextCounter extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconTextCounter({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 30, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 30,color: theme.colorScheme.primary)),
      ],
    );
  }
}
