import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

import '../../../state/pos_loyalty_controller.dart';
import '../../drawers/pos_app_drawer.dart';

import '../../organisms/loyalty/pos_loyalty_content.dart';
import '../../organisms/loyalty/pos_loyalty_menu.dart';
import '../../organisms/pos_settings_app_bar.dart';


class PosLoyaltyLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const PosLoyaltyLayout({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosLoyaltyController(),
      child: const _PosLoyaltyView(),
    );
  }
}

class _PosLoyaltyView extends StatelessWidget {
  const _PosLoyaltyView();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final sectionTitle = context.watch<PosLoyaltyController>().sectionTitle;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary:"Fidelización",
        titleSecondary:sectionTitle,
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
      body: const Row(
        children: [
          Expanded(
            flex: 30,
            child: PosLoyaltyMenu(),
          ),
          Expanded(
            flex: 70,
            child: PosLoyaltyContent(),
          ),
        ],
      ),
    );
  }
}