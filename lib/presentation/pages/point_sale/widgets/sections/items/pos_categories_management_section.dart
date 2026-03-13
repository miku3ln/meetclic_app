import 'package:flutter/material.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../models/sections_data.dart';
import '../../../state/pos_items_controller.dart';

class PosCategoriesManagementSection extends StatelessWidget {
  const PosCategoriesManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EmptyData(
          icon: Sections.getIconItems(PosItemsSection.categories),

          title: 'Todavía no existe Categorias',
          descriptionText: 'Aquí puedes gestionar las categorias',
          linkText: 'Más información',
          onLinkTap: () {
            debugPrint('Abrir más información de este proceso');
          },
        ),
        Positioned(
          right: 32,
          bottom: 80,
          child: FloatingActionButton(
            onPressed: () {
              debugPrint('Agregar proceso');
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
