
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PsHeaderWithBadge extends StatelessWidget {
  final String title;
  final String? badgeText;
  final int? badgeCount;
  final String? imageUrl;
  final VoidCallback? onTap;

  const PsHeaderWithBadge({
    super.key,
    required this.title,
    this.badgeText,
    this.badgeCount,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            /// 🔘 IMAGE / ICON
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias, // 👈 importante para recortar imagen
              child: _buildImage(imageUrl!),
            ),

            const SizedBox(width: 16),

            /// 📦 TITLE + BADGE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// BADGE
                  if (badgeCount != null || badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badgeCount != null)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "$badgeCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          if (badgeText != null)
                            Text(
                              badgeText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget _buildImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    return const SizedBox.shrink();
  }

  final isNetwork =
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  if (!isNetwork) {
    return const Icon(Icons.broken_image, color: Colors.grey);
  }

  return Stack(
    alignment: Alignment.center,
    children: [
      /// ⏳ LOADING BASE (SIEMPRE visible al inicio)
      const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),

      /// 🖼 IMAGEN
      Image.network(
        imageUrl,
        fit: BoxFit.cover,

        /// 🔥 CONTROL DE FRAME
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;

          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },

        /// ❌ ERROR
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        },
      ),
    ],
  );
}


