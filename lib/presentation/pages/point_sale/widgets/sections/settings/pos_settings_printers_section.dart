import 'package:flutter/material.dart';

import '../../../../../widgets/empty_data.dart';


class PosSettingsPrintersSection extends StatelessWidget {
  const PosSettingsPrintersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyData(
      icon: Icons.print_rounded,
      title: 'Todavía no hay impresoras',
      descriptionText: 'Aquí puedes conectar tu impresora de recibos y de cocina.',
      linkText: 'Más información',
      onLinkTap: () {
        debugPrint('Abrir ayuda de impresoras');
      },
    );
  }
}