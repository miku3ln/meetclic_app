import 'package:flutter/material.dart';

class RewardImage extends StatelessWidget {
  final String imageUrl;
  final String? badgeText; // 👈 nuevo parámetro opcional

  const RewardImage({super.key, required this.imageUrl, this.badgeText});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetwork
          ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
          : Image.asset(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
    );
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        imageWidget,

        // 👇 Badge solo si está presente
        if (badgeText != null)
          Positioned(
            top: -4,
            right: -18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC00), // amarilloVital de MeetClic
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
