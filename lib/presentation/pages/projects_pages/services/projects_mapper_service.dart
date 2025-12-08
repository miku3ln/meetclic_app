import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';

import '../models/project_item_ui_model.dart';

class ProjectsMapperService {
  const ProjectsMapperService();

  List<ProjectItemUiModel> mapFromMenuItems(List<MenuTabUpItem> source) {
    return List<ProjectItemUiModel>.generate(source.length, (i) {
      final item = source[i];

      return ProjectItemUiModel(
        index: i + 1,
        title: item.name, // adapta a tu entidad
        subtitle: item.name, // o el campo que tengas
        imageUrl: item.asset, // debe ser https
      );
    });
  }
}
