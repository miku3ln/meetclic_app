import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../../../../widgets/loading_manager.dart';
import '../atoms/pos_menu_carousel.dart';
import '../layouts/pos_main_controller.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../molecules/pos_product_grid.dart';

class PosLeftPanel extends StatelessWidget {
  final PosMainController controller;
  final int columns;

  const PosLeftPanel({
    super.key,
    required this.controller,
    this.columns = 5,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>(); // ✅ lee modo global
    final bool isLoginMode = app.isLoginRequired;
    final double heightSliderMenu=isLoginMode?80:50;
    final double heightSliderBox=isLoginMode?0:16;
    final double paddingAll=isLoginMode?45:12;
    final menuDataActions = PosTabletLandscapeFixtures.getMenuDataActions(
      onTap: controller.browser.onMenuCategoryTap,
        controller:controller
    );
    final showMenu = controller.shift.isShiftOpen;
    if (controller.browser.loadingData) {
      return PosLoadingView();
    }
    return Padding(
      padding: EdgeInsets.all(paddingAll),
      child: Column(
        children: [
          Expanded(
            child: !controller.shift.isShiftOpen
                ? _ShiftClosedView(
              onOpenTap: controller.shift.onOpenShiftTap,
            )
                : PosProductGrid(
              products: controller.browser.products,
              columns: columns,
              onProductTap: controller.onProductTap,
            ),
          ),

          if (showMenu) ...[
            SizedBox(height: heightSliderBox),
            SizedBox(
              height: heightSliderMenu,
              child: PosMenuCarousel(
                items: menuDataActions,
                selectedId: controller.browser.selectedMenuCategoryId,
                onTap: controller.browser.onMenuCategoryTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftClosedView extends StatelessWidget {
  final VoidCallback onOpenTap;
  const _ShiftClosedView({required this.onOpenTap});
  @override
  Widget build(BuildContext context) {
    // ✅ Scroll por seguridad: si el panel queda bajo (teclado, split view, etc.)
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 72, color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'El turno está cerrado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Abra el turno para realizar ventas',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onOpenTap,
                child: const Text('ABRIR EL TURNO OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}