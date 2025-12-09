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
          // 👇 Aquí metemos el loading
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            final expected = loadingProgress.expectedTotalBytes;
            final loaded = loadingProgress.cumulativeBytesLoaded;

            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: expected != null ? loaded / expected : null,
                ),
              ),
            );
          },
          // 👇 fallback si falla la imagen
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      ),
    );
  }
}
