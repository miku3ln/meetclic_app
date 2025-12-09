import '../models/project_item_ui_model.dart';
import '../models/projects_id.dart';

class ProjectsMapperService {
  const ProjectsMapperService();

  List<ProjectItemUiModel> mapFromMenuItems() {
    List<ProjectItemUiModel> source = [];
    final List<ProjectItemUiModel> projectItems = [
      ProjectItemUiModel(
        index: ProjectsId.ar.value,
        title: "Realidad Aumentada ",
        description:
            "Explora experiencias inmersivas en 3D mediante Realidad Aumentada. Este proyecto permite visualizar Tótems digitales como Taita Imbabura, Mama Cotacachi y Coraza en cualquier superficie real, con detección de plano, orientación dinámica, carga optimizada de modelos GLB, caché inteligente y animaciones en tiempo real. Diseñado para turismo, cultura y educación, ofrece una experiencia fluida en dispositivos móviles.",
        imageUrl:
            "https://media.gettyimages.com/id/1488644028/es/foto/vr-gafas-e-ingenier%C3%ADa-man-on-tablet-para-investigaci%C3%B3n-futurista-gesti%C3%B3n-electr%C3%B3nica-o-dise%C3%B1o.jpg?s=2048x2048&w=gi&k=20&c=IzJJL_owWYvJzkMlQ2lCObK_14frsnJ-_XlhAAjx8_Q=",
      ),
      ProjectItemUiModel(
        index: ProjectsId.rive.value,
        title: "Rive ",
        description:
            "Explora experiencias inmersivas en 3D mediante Realidad Aumentada. Este proyecto permite visualizar Tótems digitales como Taita Imbabura, Mama Cotacachi y Coraza en cualquier superficie real, con detección de plano, orientación dinámica, carga optimizada de modelos GLB, caché inteligente y animaciones en tiempo real. Diseñado para turismo, cultura y educación, ofrece una experiencia fluida en dispositivos móviles.",
        imageUrl:
            "https://media.gettyimages.com/id/1488644028/es/foto/vr-gafas-e-ingenier%C3%ADa-man-on-tablet-para-investigaci%C3%B3n-futurista-gesti%C3%B3n-electr%C3%B3nica-o-dise%C3%B1o.jpg?s=2048x2048&w=gi&k=20&c=IzJJL_owWYvJzkMlQ2lCObK_14frsnJ-_XlhAAjx8_Q=",
      ),
    ];

    return projectItems;
  }
}
