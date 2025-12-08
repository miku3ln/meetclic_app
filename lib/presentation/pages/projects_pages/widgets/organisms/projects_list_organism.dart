import 'package:flutter/material.dart';

import '../../helpers/projects_callbacks.dart';
import '../../models/project_item_ui_model.dart';
import '../molecules/project_list_tile_molecule.dart';

class ProjectsListOrganism extends StatelessWidget {
  final List<ProjectItemUiModel> items;
  final OnProjectTap? onItemTap;
  final OnProjectLongPress? onItemLongPress;

  const ProjectsListOrganism({
    super.key,
    required this.items,
    this.onItemTap,
    this.onItemLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ProjectListTileMolecule(
          item: item,
          onTap: onItemTap,
          onLongPress: onItemLongPress,
        );
      },
    );
  }
}
