import '../models/project_item_ui_model.dart';

class ProjectsState {
  final List<ProjectItemUiModel> items;

  const ProjectsState({required this.items});

  ProjectsState copyWith({List<ProjectItemUiModel>? items}) {
    return ProjectsState(items: items ?? this.items);
  }
}
