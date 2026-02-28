import 'package:flutter/material.dart';
import '../atoms/pos_menu_carousel.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../molecules/pos_product_grid.dart';


class PosLeftPanel extends StatelessWidget {
  final PosTabletLandscapeController controller;
  final int columns;

  const PosLeftPanel({
    super.key,
    required this.controller,
    this.columns = 5,
  });

  @override
  Widget build(BuildContext context) {
    final menuDataActions = PosTabletLandscapeFixtures.getMenuDataActions(
      onTap: controller.onMenuCategoryTap,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, c) {
          final carouselH = c.maxHeight * 0.28; // ✅ 10% fijo
          final gridH = c.maxHeight - carouselH - 18; // - SizedBox(height:10)
          return Column(
            children: [
              SizedBox(
                height: gridH, // ✅ 90% (aprox) para productos
                child: !controller.isShiftOpen
                    ? _ShiftClosedView(onOpenTap: controller.onOpenShiftTap)
                    : PosProductGrid(
                  products: controller.products,
                  columns: columns,
                  onProductTap: controller.onProductTap,
                ),
              ),

              SizedBox(
                height: 50, // ✅ 10% fijo
                child: controller.isShiftOpen?PosMenuCarousel(
                  items: menuDataActions,
                  selectedId: controller.selectedMenuCategoryId,
                  onTap: controller.onMenuCategoryTap,
                ):SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShiftClosedView extends StatelessWidget {
  final VoidCallback onOpenTap;
  const _ShiftClosedView({required this.onOpenTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
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
              child: const Text('ABRIR EL TURNO'),
            ),
          ],
        ),
      ),
    );
  }
}