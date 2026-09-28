import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/../../../../app/router/controllers/app_controller.dart';

import '../../../repositories/config_repository.dart';
import '../../../services/config_api_service.dart';
import '../../dialogs/pos_open_shift_dialog.dart';
import '../../templates/pos_split_template.dart';
import '../pos_main_controller.dart';
import 'pos_tablet_landscape_fixtures.dart';
import 'pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  const PosTabletLandscapeLayout({
    super.key,
  });

  @override
  State<PosTabletLandscapeLayout> createState() =>
      _PosTabletLandscapeLayoutState();
}

class _PosTabletLandscapeLayoutState
    extends State<PosTabletLandscapeLayout> {

  late final PosMainController controller;

  @override
  void initState() {
    super.initState();

    final app = context.read<AppController>();

    controller = PosMainController(
      app: app,
      configRepository: ConfigRepository(
        ConfigApiService(),
      ),
    );

    /**
     * ============================================================
     * LISTENER GENERAL DEL POS
     * ============================================================
     */
    controller.addListener(
      _onControllerChanged,
    );

    /**
     * ============================================================
     * LISTENER DEL ESTADO DEL TURNO
     * ============================================================
     *
     * isShiftOpen pertenece a:
     *
     * controller.shift
     *
     * Por eso debemos escuchar directamente PosShiftState.
     *
     * Cuando:
     *
     * currentSession = null;
     * notifyListeners();
     *
     * este layout se reconstruirá.
     */
    controller.shift.addListener(
      _onShiftChanged,
    );

    /**
     * ============================================================
     * OPEN SHIFT CALLBACK
     * ============================================================
     */
    controller.shift.onRequestOpenShift =
        _showOpenShiftModal;

    _initialize();
  }

  /**
   * ============================================================
   * INITIALIZE
   * ============================================================
   */
  Future<void> _initialize() async {
    await controller.initDataPointOfSales();
  }

  /**
   * ============================================================
   * MAIN CONTROLLER CHANGED
   * ============================================================
   */
  void _onControllerChanged() {
    if (!mounted) return;

    setState(() {});
  }

  /**
   * ============================================================
   * SHIFT STATE CHANGED
   * ============================================================
   *
   * Este listener es específicamente para:
   *
   * controller.shift.isShiftOpen
   */
  void _onShiftChanged() {
    if (!mounted) return;

    setState(() {});
  }

  /**
   * ============================================================
   * DISPOSE
   * ============================================================
   */
  @override
  void dispose() {
    /**
     * Removemos listener principal.
     */
    controller.removeListener(
      _onControllerChanged,
    );

    /**
     * Removemos listener del turno.
     */
    controller.shift.removeListener(
      _onShiftChanged,
    );

    controller.dispose();

    super.dispose();
  }

  /**
   * ============================================================
   * OPEN SHIFT MODAL
   * ============================================================
   */
  Future<void> _showOpenShiftModal() async {
    final opened = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PosOpenShiftDialog(
        controller: controller,
      ),
    );

    if (!mounted) return;

    if (opened != true) return;

  }

  @override
  Widget build(BuildContext context) {
    final slots =
    PosTabletLandscapeSlots.build(
      controller: controller,
    );

    return PosSplitTemplate(
      slots: slots,
    );
  }
}