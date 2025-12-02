import 'package:flutter/material.dart';

// ====== Widgets internos ======

class LoadingOverlay extends StatelessWidget {
  final double progress; // 0..1
  final bool progressKnown; // true si hay Content-Length

  const LoadingOverlay({
    super.key,
    required this.progress,
    required this.progressKnown,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay tamaño del servidor: 0%. Si hay, usamos progress*100.
    final pctText = progressKnown
        ? '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : '0%';

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        pctText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 56,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
