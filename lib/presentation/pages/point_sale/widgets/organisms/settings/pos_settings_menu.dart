import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../domain/services/session_service.dart';
import '../../../../../../shared/controllers/app_controller.dart';

import '../../../models/sections_data.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_settings_controller.dart';


class PosSettingsMenu extends StatelessWidget {
  const PosSettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PosSettingsController>();
    final app = context.read<AppController>();
    final session = context.watch<SessionService>();

    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                menuItem(
                  context,
                  icon: Icons.print,
                  title: 'Impresoras',
                  selected: settings.section == PosSettingsSection.printers,
                  onTap: () => settings.setSection(PosSettingsSection.printers),
                ),
                menuItem(
                  context,
                  icon: Icons.desktop_windows,
                  title: 'Pantalla para clientes',
                  selected:
                  settings.section == PosSettingsSection.customerScreen,
                  onTap: () =>
                      settings.setSection(PosSettingsSection.customerScreen),
                ),
                menuItem(
                  context,
                  icon: Icons.percent,
                  title: 'Impuestos',
                  selected: settings.section == PosSettingsSection.taxes,
                  onTap: () => settings.setSection(PosSettingsSection.taxes),
                ),
                menuItem(
                  context,
                  icon: Icons.settings,
                  title: 'General',
                  selected: settings.section == PosSettingsSection.general,
                  onTap: () => settings.setSection(PosSettingsSection.general),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: PosSettingsMenuStyles.footerPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    session.displayEmail.isNotEmpty
                        ? session.displayEmail
                        : 'Sin correo',
                    textAlign: TextAlign.center,
                    style: PosSettingsMenuStyles.emailTextStyle(context),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => app.logout(),
                      child: const Text('CERRAR SESIÓN'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}