import 'package:flutter/material.dart';

class ProjectThumbnailAtom extends StatelessWidget {
  final String imageUrl;
  final double size;

  const ProjectThumbnailAtom({
    super.key,
    required this.imageUrl,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      ),
    );
  }
}
