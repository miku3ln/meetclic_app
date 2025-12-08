import 'package:flutter/material.dart';

import '../../theme/projects_theme.dart';

class ProjectIndexAtom extends StatelessWidget {
  final int index;

  const ProjectIndexAtom({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Text(
      index.toString().padLeft(2, '0'),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: ProjectsTheme.indexColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
