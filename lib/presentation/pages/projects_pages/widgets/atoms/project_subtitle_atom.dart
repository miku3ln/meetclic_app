import 'package:flutter/material.dart';

import '../../theme/projects_theme.dart';

class ProjectSubtitleAtom extends StatelessWidget {
  final String text;

  const ProjectSubtitleAtom({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: ProjectsTheme.subtitleColor),
    );
  }
}
