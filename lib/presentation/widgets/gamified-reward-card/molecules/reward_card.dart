import 'package:flutter/material.dart';

import '../atoms/reward_description.dart';
import '../atoms/reward_image.dart';
import '../atoms/reward_title.dart';

class RewardCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onTap;
  final String? badgeText;
  const RewardCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              RewardImage(imageUrl: imageUrl, badgeText: badgeText),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RewardTitle(title: title),
                    const SizedBox(height: 4),
                    RewardDescription(description: description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
