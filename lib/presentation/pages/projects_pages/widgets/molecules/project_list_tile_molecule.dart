import 'package:flutter/material.dart';

import '../../helpers/projects_callbacks.dart';
import '../../models/project_item_ui_model.dart';
import '../../theme/projects_theme.dart';
import '../atoms/project_index_atom.dart';
import '../atoms/project_subtitle_atom.dart';
import '../atoms/project_thumbnail_atom.dart';
import '../atoms/project_title_atom.dart';

class ProjectListTileMolecule extends StatelessWidget {
  final ProjectItemUiModel item;
  final OnProjectTap? onTap;
  final OnProjectLongPress? onLongPress;

  const ProjectListTileMolecule({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProjectsTheme.cardBackground,
      child: InkWell(
        onTap: () => onTap?.call(item),
        onLongPress: () => onLongPress?.call(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: ProjectThumbnailAtom(imageUrl: item.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectTitleAtom(text: item.title),
                    const SizedBox(height: 4),
                    ProjectSubtitleAtom(text: item.subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ProjectIndexAtom(index: item.index),
            ],
          ),
        ),
      ),
    );
  }
}
