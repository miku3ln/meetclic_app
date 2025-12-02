import 'package:flutter/material.dart';

import '../molecules/reward_card.dart';

class RewardItemModel {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onTap;
  final String? badgeText;
  RewardItemModel({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onTap,
    this.badgeText,
  });
}

class RewardsListView extends StatelessWidget {
  final List<RewardItemModel> items;
  const RewardsListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return RewardCard(
          imageUrl: item.imageUrl,
          title: item.title,
          description: item.description,
          onTap: item.onTap,
          badgeText: item.badgeText,
        );
      },
    );
  }
}
