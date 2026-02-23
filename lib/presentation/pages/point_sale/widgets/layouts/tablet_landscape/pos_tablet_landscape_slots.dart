import 'package:flutter/material.dart';
import '../../organisms/pos_header_bar.dart';
import '../../sections/pos_action_bar.dart';
import '../../sections/pos_left_panel.dart';
import '../../sections/pos_right_panel.dart';
import '../../slots/pos_layout_slots.dart';
import 'pos_tablet_landscape_controller.dart';
import 'pos_tablet_landscape_fixtures.dart';

class PosTabletLandscapeSlots {
  static PosLayoutSlots build({
    required PosTabletLandscapeController controller,
  }) {
    final menuDataActions = PosTabletLandscapeFixtures.getMenuDataActions(
      onTap: controller.onMenuCategoryTap,
    );

    return PosLayoutSlots(
      header: PosHeaderBar(
        // ✅ (1) dropdown usa PosCategoryItem
        productCategories: controller.productCategories,
        selectedProductCategoryId: controller.selectedProductCategoryId,
        onProductCategoryChanged: controller.onProductCategoryChanged,

        // ✅ (3) search
        onSearchChanged: controller.onSearchChanged,
        onSearchSubmitted: controller.onSearchSubmitted,

        // (otros icons)
        onMenuTap: () {},
        onUserTap: () {},
        onMoreTap: () {},
      ),

      left: PosLeftPanel(
        isShiftOpen: controller.isShiftOpen,
        onOpenShiftTap: controller.onOpenShiftTap,

        // ✅ aquí ya NO van chips de categorías viejas
        products: controller.products,
        onProductTap: controller.onProductTap,
        columns: 5,
      ),

      right: PosRightPanel(controller: controller),

      footer: controller.isShiftOpen
          ? PosActionBar(
              controller: controller,
              menuCategories: menuDataActions,
              selectedMenuCategoryId: controller.selectedMenuCategoryId,
              onMenuCategoryTap: controller.onMenuCategoryTap,
              onSave: controller.onSave,
              onPay: controller.onPay,
            )
          : const SizedBox.shrink(),
    );
  }
}
