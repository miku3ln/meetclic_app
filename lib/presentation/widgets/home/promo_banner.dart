import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  final String text;

   PromoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
           Icon(Icons.local_offer, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
