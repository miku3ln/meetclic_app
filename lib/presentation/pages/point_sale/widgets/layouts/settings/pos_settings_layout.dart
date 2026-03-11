import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/pos_settings_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../../organisms/settings/pos_settings_content.dart';
import '../../organisms/settings/pos_settings_menu.dart';

class PosSettingsLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const PosSettingsLayout({super.key,    this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosSettingsController(),
      child: _PosSettingsView(),
    );
  }
}

class _PosSettingsView extends StatelessWidget {

   _PosSettingsView(
  );
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:  PosAppDrawer(), // ✅ FALTA ESTO
      appBar: PosSettingsAppBar(
        titlePrimary: 'Configuración',
        titleSecondary: 'Pantalla para clientes',
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        style: PosSettingsAppBarStyle(
          topBackgroundColor: const Color(0xFF2E7D32),
          bottomBackgroundColor: const Color(0xFF4CAF50),
          primaryTitleColor: Colors.white,
          secondaryTitleColor: Colors.white,
          menuIconColor: Colors.white,
          primaryIndicatorColor: Colors.transparent,
          secondaryIndicatorColor: Colors.transparent,
          dividerColor: Colors.grey, // si no existe en tu SDK usa Color(0xFFFF6347)
        ),
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