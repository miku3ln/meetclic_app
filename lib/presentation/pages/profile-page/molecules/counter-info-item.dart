import 'package:flutter/material.dart';

class CounterInfoItem extends StatelessWidget {
  final int count;
  final String imageAsset; // Ruta de la imagen local
  final String label;
  final Color lineColor;

  const CounterInfoItem({
    required this.count,
    required this.imageAsset,
    required this.label,
    required this.lineColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Image.asset(
          imageAsset,
          width: 50,
          height: 50,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class CounterInfoRow extends StatelessWidget {
  final List<CounterInfoItem> items;

  const CounterInfoRow({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .expand((item) => [
        item,
        if (item != items.last)
          Container(
            width: 2,
            height: 60,
            color: item.lineColor,
          ),
      ])
          .toList(),
    );
  }
}
