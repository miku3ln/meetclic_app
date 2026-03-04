import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/pos_settings_controller.dart';
import '../../sections/settings/pos_settings_customer_screen_section.dart';
import '../../sections/settings/pos_settings_general_section.dart';
import '../../sections/settings/pos_settings_printers_section.dart';
import '../../sections/settings/pos_settings_taxes_section.dart';

class PosSettingsContent extends StatelessWidget {
  const PosSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final section = context.watch<PosSettingsController>().section;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _Header(title: _title(section)),
          const Divider(height: 1),
          Expanded(child: _buildSection(section)),
        ],
      ),
    );
  }

  String _title(PosSettingsSection s) {
    switch (s) {
      case PosSettingsSection.printers:
        return 'Impresoras';
      case PosSettingsSection.customerScreen:
        return 'Pantalla para clientes';
      case PosSettingsSection.taxes:
        return 'Impuestos';
      case PosSettingsSection.general:
        return 'General';
    }
  }

  Widget _buildSection(PosSettingsSection s) {
    switch (s) {
      case PosSettingsSection.printers:
        return const PosSettingsPrintersSection();
      case PosSettingsSection.customerScreen:
        return const PosSettingsCustomerScreenSection();
      case PosSettingsSection.taxes:
        return const PosSettingsTaxesSection();
      case PosSettingsSection.general:
        return const PosSettingsGeneralSection();
    }
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}