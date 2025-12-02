import 'package:flutter/material.dart';

class CounterRewardEarned extends StatelessWidget {
  final int count;
  final String imageAsset;
  final String label;
  final Color lineColor;
  final VoidCallback onTap;

  const CounterRewardEarned({
    required this.count,
    required this.imageAsset,
    required this.label,
    required this.lineColor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}

class RewardsGrid extends StatelessWidget {
  final List<CounterRewardEarned> items;

  const RewardsGrid({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: items,
    );
  }
}
