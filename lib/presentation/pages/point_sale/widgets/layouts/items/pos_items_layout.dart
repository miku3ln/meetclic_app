import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/models/sections_data.dart';
import 'package:provider/provider.dart';

import '../../../../../../app/router/controllers/app_controller.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

import '../../../state/pos_items_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/items/pos_items_content.dart';
import '../../organisms/pos_settings_app_bar.dart';

class PosItemsLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final PosItemsSection section;
  const PosItemsLayout({super.key, this.onMenuTap,required this.section});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosItemsController(),
      child:  _PosItemsView(section:section),
    );
  }
}

class _PosItemsView extends StatelessWidget {
  final PosItemsSection section;
  final VoidCallback? onMenuTap;
  const _PosItemsView({
    super.key,
    this.onMenuTap,
    required this.section,
  });
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final sectionTitle = "gestion";
    final app = context.read<AppController>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary: Sections.getTitleItems(PosItemsSection.items),
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
      body: Row(
        children: [
          Expanded(flex: 100, child: PosItemsContent(section: section)),
        ],
      ),
    );
  }
}
