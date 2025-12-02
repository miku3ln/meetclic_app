import 'package:flutter/material.dart';
import 'package:meetclic_app/models/totem_management.dart';

import 'atoms.dart';

class InfoCardAR extends StatelessWidget {
  final ItemAR item;
  final String? lastError;
  final VoidCallback? onCapturePressed;
  final bool isCapturing;

  // Submenú yaw
  final VoidCallback? onYawLeft;
  final VoidCallback? onYawRight;

  const InfoCardAR({
    super.key,
    required this.item,
    this.lastError,
    this.onCapturePressed,
    this.isCapturing = false,
    this.onYawLeft,
    this.onYawRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool captureEnabled = onCapturePressed != null && !isCapturing;
    final bool yawEnabled = onYawLeft != null && onYawRight != null;

    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.sources.img,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (lastError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lastError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${item.position.lat.toStringAsFixed(5)}, ${item.position.lng.toStringAsFixed(5)}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Submenú yaw
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ARIconCircleButton(
                    icon: Icons.arrow_left_rounded,
                    tooltip: 'Girar a la izquierda',
                    onPressed: yawEnabled ? onYawLeft : null,
                  ),
                  const SizedBox(width: 8),
                  ARIconCircleButton(
                    icon: Icons.arrow_right_rounded,
                    tooltip: 'Girar a la derecha',
                    onPressed: yawEnabled ? onYawRight : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: captureEnabled ? onCapturePressed : null,
                  icon: isCapturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_rounded),
                  label: Text(isCapturing ? 'Guardando…' : 'Capturar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
