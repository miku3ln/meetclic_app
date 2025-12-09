import 'package:flutter/material.dart';

import '../../../../theme/projects_theme.dart';
import '../../helpers/projects_callbacks.dart';
import '../../models/project_item_ui_model.dart';
import '../molecules/project_list_tile_molecule.dart';

class ProjectsListOrganism extends StatelessWidget {
  final List<ProjectItemUiModel> items;

  final OnProjectTap? onItemTap;
  final OnProjectLongPress? onItemLongPress;

  /// 👇👇 NUEVO: Builder para la animación OpenContainer
  final Widget Function(ProjectItemUiModel item)? openBuilder;

  // ==== parámetros para la línea divisoria ====
  final double dividerWidthFactor; // 0.0 - 1.0
  final double dividerHeight;
  final double dividerThickness;
  final AlignmentGeometry dividerAlignment;
  final Color? dividerColor;

  const ProjectsListOrganism({
    super.key,
    required this.items,
    this.onItemTap,
    this.onItemLongPress,
    this.openBuilder, // 👈 NECESARIO PARA OPENCONTAINER

    this.dividerWidthFactor = ProjectsDividerDefaults.widthFactor,
    this.dividerHeight = ProjectsDividerDefaults.height,
    this.dividerThickness = ProjectsDividerDefaults.thickness,
    this.dividerAlignment = ProjectsDividerDefaults.alignmentRight,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedDividerColor =
        dividerColor ?? ProjectsDividerDefaults.color;

    return ListView.separated(
      itemCount: items.length,

      separatorBuilder: (_, __) => Align(
        alignment: dividerAlignment,
        child: FractionallySizedBox(
          widthFactor: dividerWidthFactor,
          child: Divider(
            height: dividerHeight,
            thickness: dividerThickness,
            color: resolvedDividerColor,
          ),
        ),
      ),

      itemBuilder: (context, index) {
        final item = items[index];

        return ProjectListTileMolecule(
          item: item,
          onTap: onItemTap,
          onLongPress: onItemLongPress,

          /// 👇 PASAMOS EL OPENBUILDER HACIA EL MOLECULE
          openBuilder: openBuilder,
        );
      },
    );
  }
}
