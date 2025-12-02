import 'package:flutter/material.dart';

import '../atoms/task_subtitle.dart';
import '../atoms/task_title.dart';
import '../atoms/yapita_badge.dart';

class TaskHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  const TaskHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YapitaBadge(text: badge),
        const SizedBox(height: 8),
        TaskTitle(title: title),
        TaskSubtitle(subtitle: subtitle),
      ],
    );
  }
}
