import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EmptyData extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Texto antes del link
  final String descriptionText;

  /// Texto clickable, por ejemplo: "Más información"
  final String? linkText;

  /// Acción del link
  final VoidCallback? onLinkTap;

  /// Tamaños configurables
  final double maxWidth;
  final double iconCircleSize;
  final double iconSize;

  const EmptyData({
    super.key,
    required this.icon,
    required this.title,
    required this.descriptionText,
    this.linkText,
    this.onLinkTap,
    this.maxWidth = 720,
    this.iconCircleSize = 230,
    this.iconSize = 88,
  });

  @override
  Widget build(BuildContext context) {
    final hasLink = linkText != null && linkText!.trim().isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconCircleSize,
                height: iconCircleSize,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F1F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: descriptionText,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                        height: 1.45,
                      ),
                    ),
                    if (hasLink) ...[
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: linkText!,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF1976D2),
                          decoration: TextDecoration.underline,
                          height: 1.45,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = onLinkTap,
                      ),
                    ],
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}