import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../../../../shared/controllers/app_controller.dart';
import '../../../state/pos_settings_controller.dart';

class PosSettingsMenu extends StatelessWidget {
  const PosSettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PosSettingsController>();
    final app = context.read<AppController>();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
      ),
      child: Column(
        children: [
          _menuItem(
            context,
            icon: Icons.print,
            title: 'Impresoras',
            selected: settings.section == PosSettingsSection.printers,
            onTap: () => settings.setSection(PosSettingsSection.printers),
          ),
          _menuItem(
            context,
            icon: Icons.desktop_windows,
            title: 'Pantalla para clientes',
            selected: settings.section == PosSettingsSection.customerScreen,
            onTap: () => settings.setSection(PosSettingsSection.customerScreen),
          ),
          _menuItem(
            context,
            icon: Icons.percent,
            title: 'Impuestos',
            selected: settings.section == PosSettingsSection.taxes,
            onTap: () => settings.setSection(PosSettingsSection.taxes),
          ),
          _menuItem(
            context,
            icon: Icons.settings,
            title: 'General',
            selected: settings.section == PosSettingsSection.general,
            onTap: () => settings.setSection(PosSettingsSection.general),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => app.logout(), // ✅ usa tu logout global
                child: const Text('CERRAR SESIÓN'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool selected,
        required VoidCallback onTap,
      }) {
    final bg = selected ? Colors.green.withOpacity(0.10) : Colors.transparent;
    final fg = selected ? Colors.green.shade800 : Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}