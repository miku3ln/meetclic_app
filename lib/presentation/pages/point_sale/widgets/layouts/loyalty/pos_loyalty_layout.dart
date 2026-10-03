import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../app/router/controllers/app_controller.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../shared/utils/screen_utils.dart';
import '../../../state/pos_loyalty_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../pos_main_controller.dart';
import 'body_ticket_manager.dart';

// ============================================================================
// POS LOYALTY LAYOUT
// ============================================================================

class PosLoyaltyLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final PosLoyaltySection section;

  const PosLoyaltyLayout({
    super.key,
    this.onMenuTap,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosLoyaltyController(),
      child: _PosLoyaltyView(
        section: section,
        onMenuTap: onMenuTap,
      ),
    );
  }
}

// ============================================================================
// POS LOYALTY VIEW
// ============================================================================
class _PosLoyaltyView extends StatefulWidget {
  final PosLoyaltySection section;
  final VoidCallback? onMenuTap;

  const _PosLoyaltyView({
    this.onMenuTap,
    required this.section,
  });

  @override
  State<_PosLoyaltyView> createState() =>
      _PosLoyaltyViewState();
}

class _PosLoyaltyViewState extends State<_PosLoyaltyView> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    const sectionTitle = '';
    context.read<AppController>();
    final main = context.watch<PosMainController>();
    final device = main.device;
    final appBarConfig = ScreenUtils.appBarConfigTitle(
      width: device.width,
      height: device.height,
      isLandscape: device.isLandscape,
      isTablet: device.isTablet,
    );

    return Scaffold(
      key: _scaffoldKey,

      // El teclado no redimensiona toda la interfaz POS.
      resizeToAvoidBottomInset: false,

      backgroundColor: colors.background,

      drawer: const PosAppDrawer(),

      // ======================================================================
      // APP BAR
      // ======================================================================

      appBar: PosSettingsAppBar(
        titlePrimary: 'Fidelización',
        titleSecondary: sectionTitle,
        showDivider: false,
        secondaryFlex: appBarConfig.primaryFlex,
        primaryFlex: appBarConfig.secondaryFlex,
        onMenuTap: () {
          if (widget.onMenuTap != null) {
            widget.onMenuTap!();
            return;
          }
          _scaffoldKey.currentState?.openDrawer();
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

      // ======================================================================
      // BODY
      //
      // AQUÍ SOLAMENTE:
      // - catálogo
      // - ticket draggable
      //
      // NO botones de gestión.
      // ======================================================================

      body: PosLoyaltyBody(
        section: widget.section,
      ),

      // ======================================================================
      // FIXED MANAGEMENT ACTIONS
      //
      // ESTE SIGUE SIENDO EL ÚNICO LUGAR DONDE EXISTEN.
      //
      // Scaffold reserva físicamente este espacio.
      // El body no puede ocuparlo.
      // El ticket no puede taparlo.
      // ======================================================================

      bottomNavigationBar: PosTicketActions(
        total: 8.50,
        compact: device.isLandscape,
      ),
    );
  }
}