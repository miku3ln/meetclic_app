import 'package:flutter/material.dart';

import '../../../../../widgets/empty_data.dart';


class PosSettingsTaxesSection extends StatelessWidget {
  const PosSettingsTaxesSection({super.key});

  @override
  Widget build(BuildContext context) {

   return Stack(
      children: [
        EmptyData(
          icon: Icons.percent_rounded,
          title: 'Aún no tiene impuestos en esta tienda',
          descriptionText: 'Los impuestos se pueden aplicar a artículos específicos y se calculan en el momento de la venta.',
          linkText: 'Más información',
          onLinkTap: () {
            debugPrint('Abrir ayuda de impuestos');
          },
        ),
        Positioned(
          right: 32,
          bottom: 80,
          child: FloatingActionButton(
            onPressed: () {
              debugPrint('Agregar impresora');
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );

  }
}