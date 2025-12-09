import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/presentation/pages/project_lake_page.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/models/project_item_ui_model.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/models/projects_id.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/services/projects_mapper_service.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/state/%20projects_state.dart';
import 'package:meetclic_app/presentation/pages/projects_pages/widgets/organisms/projects_list_organism.dart';
import 'package:meetclic_app/presentation/pages/rive-example/vehicles_page.dart';
import 'package:rive/rive.dart';

import '../../shared/localization/app_localizations.dart';
import '../widgets/template/custom_app_bar.dart';
import 'ar_management_view/ar_management_view.dart';

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

    // ⚠️ FALTABA EL PARÁMETRO widget.itemsStatus
    final uiItems = _mapper.mapFromMenuItems();
    _state = ProjectsState(items: uiItems);

    _controllers.addAll(
      List.generate(uiItems.length, (_) => SimpleAnimation('idle')),
    );
  }

  // ==== Callbacks ====
  void _onItemTap(ProjectItemUiModel item) {
    debugPrint("Tap lógico: ${item.index} - ${item.title}");
  }

  void _onItemLongPress(ProjectItemUiModel item) {
    debugPrint('LongPress en item: ${item.index}');
  }

  // ==== NUEVO: BUILDER PARA NAVEGACIÓN CON OpenContainer ====
  Widget _openPageBuilder(ProjectItemUiModel item) {
    final appLocalizations = AppLocalizations.of(context);
    if (item.index == ProjectsId.ar.value) {
      return const ARManagementView();
    } else if (item.index == ProjectsId.rive.value) {
      return VehiclesScreenPage(title: "Rive", itemsStatus: widget.itemsStatus);
    } else if (item.index == ProjectsId.maritime.value) {
      final title = appLocalizations.translate('pages.maritime');
      return ProjectLakePage(title: title, itemsStatus: widget.itemsStatus);
    }
    return const Scaffold(body: Center(child: Text("Módulo en construcción")));
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

          // 👇 AQUÍ PASAMOS EL OPEN BUILDER PARA OpenContainer
          openBuilder: _openPageBuilder,
        ),
      ),
    );
  }
}
