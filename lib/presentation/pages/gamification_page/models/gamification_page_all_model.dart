import 'package:flutter/material.dart';

enum GamificationCardLayout { imageLeft, full, compact, others }

class GamificationCardVariant {
  final GamificationCardLayout layout;
  final Color badgeColor;
  final Color rewardColor;
  final bool showImage;

  const GamificationCardVariant({
    required this.layout,
    required this.badgeColor,
    required this.rewardColor,
    required this.showImage,
  });
}
