import 'package:flutter/material.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../models/sections_data.dart';
import '../../../state/pos_items_controller.dart';

class PosModifiersManagementSection extends StatelessWidget {
  const PosModifiersManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EmptyData(
          icon: Sections.getIconItems(PosItemsSection.modifiers),

          title: 'Todavía no existe modificadores',
          descriptionText: 'Aquí puedes gestionar los modificadores',
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
