import 'package:flutter/material.dart';
import '../../../../../widgets/empty_data.dart';

class PosSettingsCustomerScreenSection extends StatelessWidget {
  const PosSettingsCustomerScreenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyData(
      icon: Icons.desktop_windows_rounded,
      title: 'Todavía no tienes pantallas',
      descriptionText: 'Aquí puedes conectar tu pantalla de clientes.',
      linkText: 'Más información',
      onLinkTap: () {
        debugPrint('Abrir más información de pantallas');
      },
    );
  }
}
