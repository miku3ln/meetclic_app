import 'package:flutter/material.dart';

import '../../../domain/entities/status_item.dart';

class AppBarStatusWidget extends StatelessWidget {
  final List<StatusItem> items;

  const AppBarStatusWidget({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
