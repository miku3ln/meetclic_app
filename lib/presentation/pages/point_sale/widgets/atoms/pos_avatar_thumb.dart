// widgets/atoms/pos_avatar_thumb.dart
import 'package:flutter/material.dart';

class PosAvatarThumb extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;
  final Color fallback;

  const PosAvatarThumb({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.radius,
    this.fallback = const Color(0xFFE9EDF3),
  });

  @override
  Widget build(BuildContext context) {
    final hasImg = (imageUrl != null && imageUrl!.trim().isNotEmpty);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: fallback,
        child: hasImg
            ? Image.network(imageUrl!, fit: BoxFit.cover)
            : const Icon(Icons.fastfood, size: 22),
      ),
    );
  }
}