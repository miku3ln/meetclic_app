import 'package:flutter/material.dart';

class InfoTileScheduleAtom extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const InfoTileScheduleAtom({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  Text(title,
                      style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.green.shade800)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
