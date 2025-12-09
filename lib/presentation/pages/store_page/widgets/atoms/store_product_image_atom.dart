import 'package:flutter/material.dart';

class StoreProductImageAtom extends StatelessWidget {
  final String imageUrl;

  const StoreProductImageAtom({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.grey),
        ),
      ),
    );
  }
}
