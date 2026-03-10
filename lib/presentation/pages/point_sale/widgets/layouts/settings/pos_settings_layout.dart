import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/pos_settings_controller.dart';
import '../../organisms/settings/pos_settings_content.dart';
import '../../organisms/settings/pos_settings_menu.dart';

class PosSettingsLayout extends StatelessWidget {
  const PosSettingsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosSettingsController(),
      child: const _PosSettingsView(),
    );
  }
}

class _PosSettingsView extends StatelessWidget {
  const _PosSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración s'),
      ),
      body: Row(
        children: const [
          // 30%
          Expanded(
            flex: 30,
            child: PosSettingsMenu(),
          ),
          // 70%
          Expanded(
            flex: 70,
            child: PosSettingsContent(),
          ),
        ],
      ),
    );
  }
}