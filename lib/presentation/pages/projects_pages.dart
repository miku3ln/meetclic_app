import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/models/project_item_ui_model.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/services/projects_mapper_service.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/state/%20projects_state.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/widgets/organisms/projects_list_organism.dart';
import 'package:rive/rive.dart';

import '../widgets/template/custom_app_bar.dart';

class ProjectsPages extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const ProjectsPages({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<ProjectsPages> createState() => _ProjectsPagesState();
}

class _ProjectsPagesState extends State<ProjectsPages> {
  final List<RiveAnimationController> _controllers = [];
  late ProjectsState _state;

  final _mapper = const ProjectsMapperService();

  @override
  void initState() {
    super.initState();

    final uiItems = _mapper.mapFromMenuItems(widget.itemsStatus);
    _state = ProjectsState(items: uiItems);

    // si quisieras crear controllers por item:
    _controllers.addAll(
      List.generate(
        uiItems.length,
        (_) => SimpleAnimation('idle'), // nombre de tu state machine/anim
      ),
    );
  }

  // ==== Callbacks ====

  void _onItemTap(ProjectItemUiModel item) {
    // aquí llamas a tus métodos, navegación o Rive
    // ejemplo: print / log
    debugPrint('Tap en item: ${item.index} - ${item.title}');
  }

  void _onItemLongPress(ProjectItemUiModel item) {
    debugPrint('LongPress en item: ${item.index}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: SafeArea(
        child: ProjectsListOrganism(
          items: _state.items,
          onItemTap: _onItemTap,
          onItemLongPress: _onItemLongPress,
        ),
      ),
    );
  }
}
