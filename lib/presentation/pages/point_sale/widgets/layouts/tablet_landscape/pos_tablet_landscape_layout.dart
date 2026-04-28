import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/controllers/app_controller.dart';
import '../../../repositories/config_repository.dart';
import '../../../services/config_api_service.dart';
import '../../dialogs/pos_open_shift_dialog.dart';
import '../../templates/pos_split_template.dart';
import '../pos_main_controller.dart';
import 'pos_tablet_landscape_fixtures.dart';
import 'pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  const PosTabletLandscapeLayout({super.key});

  @override
  State<PosTabletLandscapeLayout> createState() =>
      _PosTabletLandscapeLayoutState();
}

class _PosTabletLandscapeLayoutState extends State<PosTabletLandscapeLayout> {
  late final PosMainController controller;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    controller = PosMainController(app: app,configRepository: ConfigRepository(
        ConfigApiService(), // 👈 mock por ahora
    ))
      ..addListener(_onControllerChanged);
    controller.shift.onRequestOpenShift = _showOpenShiftModal;

    _initialize();
  }

  Future<void> _initialize() async {
    await controller.shift.init();
    final products = await PosTabletLandscapeFixtures.getProductsData();
    controller.browser.allProducts=products;
    controller.init(
      initialProducts:products,
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(products),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(products),
      initialSelectedProductCategoryId: "all",
      initialSelectedMenuCategoryId: "all",
    );
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  Future<void> _showOpenShiftModal() async {
    final opened = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PosOpenShiftDialog(controller: controller),
    );

    if (!mounted) return;
    if (opened != true) return;


  }

  @override
  Widget build(BuildContext context) {
    final slots = PosTabletLandscapeSlots.build(controller: controller);
    return PosSplitTemplate(slots: slots);
  }
}