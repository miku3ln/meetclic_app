import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../state/pos_settings_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../../organisms/settings/pos_settings_content.dart';
class PosSettingsLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;

  final PosSettingsSection section;

  const PosSettingsLayout({
    super.key,
    this.onMenuTap,required this.section
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosSettingsController(),
      child:  _PosSettingsView(section:section),
    );
  }
}

class _PosSettingsView extends StatelessWidget {
  final PosSettingsSection section;
  final VoidCallback? onMenuTap;
  const _PosSettingsView({
    super.key,
    this.onMenuTap,
    required this.section,
});
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final sectionTitle = context.watch<PosSettingsController>().sectionTitle;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary: 'Configuración',
        titleSecondary: sectionTitle,
        onMenuTap: () {
          scaffoldKey.currentState?.openDrawer();
        },
        style: PosSettingsAppBarStyle(
          topBackgroundColor: colors.primary,
          bottomBackgroundColor: colors.primary,
          primaryTitleColor: colors.textInverse,
          secondaryTitleColor: colors.textInverse,
          menuIconColor: colors.textInverse,
          primaryIndicatorColor: Colors.transparent,
          secondaryIndicatorColor: Colors.transparent,
          dividerColor: colors.divider,
        ),
      ),
      body:  Row(
        children: [

          Expanded(
            flex: 100,
            child: PosSettingsContent(section: section),
          ),
        ],
      ),
    );
  }
}