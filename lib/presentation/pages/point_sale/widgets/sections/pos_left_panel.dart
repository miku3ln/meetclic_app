import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import '../../../../../app/router/controllers/app_controller.dart';

import '../../../../shared/responsive/device_gesture_observer.dart';
import '../../../../widgets/loading_manager.dart';
import '../../theme/pos_ticket_styles.dart';
import '../atoms/pos_menu_carousel.dart';
import '../layouts/pos_main_controller.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../molecules/pos_product_grid.dart';
import '../molecules/pos_ticket_header.dart';
import '../organisms/pos_ticket_checkout.dart';
import '../organisms/pos_ticket_list.dart';

class PosLeftPanel extends StatelessWidget {
  //INIT PROCESS-MANAGER-UI-END
  final PosMainController controller;
  final int columns;

  const PosLeftPanel({super.key, required this.controller, this.columns = 5});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>(); // ✅ lee modo global
    final bool isLoginMode = app.isLoginRequired;
    final double heightSliderMenu = isLoginMode ? 80 : 50;
    final double heightSliderBox = isLoginMode ? 0 : 16;
    final double paddingAll = isLoginMode ? 45 : 12;
    final menuDataActions = PosTabletLandscapeFixtures.getMenuDataActions(
      onTap: controller.browser.onMenuCategoryTap,
      controller: controller,
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
                    //INIT DATA CASH
                    controller: controller,
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
  final PosMainController controller;

  const _ShiftClosedView({required this.onOpenTap, required this.controller});

  @override
  Widget build(BuildContext context) {
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
              Text(
                controller.labels.shiftClosedTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                controller.labels.shiftClosedDescription,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onOpenTap,
                child: Text(controller.labels.openShiftButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PosAllBodyPanel extends StatelessWidget {
  final PosMainController controller;
  final int columns;
  final DeviceSnapshot device;

  const PosAllBodyPanel({
    super.key,
    required this.controller,
    this.columns = 5,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final bool isLoginMode = app.isLoginRequired;
    final double heightSliderMenu = isLoginMode ? 80 : 50;
    final double heightSliderBox = isLoginMode ? 0 : 16;
    final menuDataActions = PosTabletLandscapeFixtures.getMenuDataActions(
      onTap: controller.browser.onMenuCategoryTap,
      controller: controller,
    );
    final styles = const PosTicketStyles().copyWith(
      leftThumbSize: 30,
      rightColumnWidth: 100,
      iconButtonSize: 25,
    );
    final double heightPostTicket=isLoginMode?170:200;

    final items = controller.ticket.items;
    final bool showMenu = controller.shift.isShiftOpen;
    if (controller.browser.loadingData) {
      return const PosLoadingView();
    }
    return SizedBox.expand(
      child: Column(
        children: [
          PosTicketHeader(
            title: 'Tickets',
            itemsCount: items.length,
            controllerMain: controller,
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

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: !controller.shift.isShiftOpen
                  ? _ShiftClosedView(
                      controller: controller,
                      onOpenTap: controller.shift.onOpenShiftTap,
                    )
                  : PosProductGrid(
                      products: controller.browser.products,
                      columns: columns,
                      onProductTap: controller.onProductTap,
                      spacing: 10,
                      runSpacing: 10,
                    ),
            ),
          ),
          const Divider(height: 0),
          // ✅ Lista ocupa todo menos checkout
          Expanded(
            child: PosTicketBody(
              items: controller.ticket.items,
              styles: styles,
              onMinus: (it) => controller.ticket. decreaseItem(it),
              onPlus: (it) => controller.ticket.increaseItem(it),
              onEdit: (it) => controller.ticket.editTicketItem(it),
              onDelete: (it) => controller.ticket.removeItem(it),
            ),
          ),

          // ✅ Checkout fijo
          SizedBox(
            height: heightPostTicket,
            child: PosTicketCheckout(controller: controller),
          ),
        ],
      ),
    );
  }
}
