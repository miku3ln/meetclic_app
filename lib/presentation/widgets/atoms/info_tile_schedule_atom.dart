import 'package:flutter/material.dart';

class InfoTileScheduleAtom extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  /// 🔹 Colores opcionales
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? descriptionColor;

  const InfoTileScheduleAtom({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.onTap,
    this.titleColor,
    this.subtitleColor,
    this.descriptionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Color effectiveTitleColor = titleColor ?? Colors.black87;
    final Color effectiveSubtitleColor = subtitleColor ?? Colors.grey.shade600;
    final Color effectiveDescriptionColor =
        descriptionColor ?? Colors.green.shade800;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveTitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: effectiveSubtitleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: effectiveDescriptionColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}
