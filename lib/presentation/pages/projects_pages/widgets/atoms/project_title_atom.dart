import 'package:flutter/material.dart';

import '../../theme/projects_theme.dart';

class ProjectTitleAtom extends StatelessWidget {
  final String text;

  const ProjectTitleAtom({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: ProjectsTheme.titleColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
