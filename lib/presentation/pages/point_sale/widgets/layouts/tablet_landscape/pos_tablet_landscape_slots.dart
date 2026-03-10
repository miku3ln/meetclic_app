
import 'package:flutter/cupertino.dart';

import '../../organisms/pos_header_bar.dart';

import '../../sections/pos_left_panel.dart';
import '../../sections/pos_right_panel.dart';
import '../../slots/pos_layout_slots.dart';
import 'pos_tablet_landscape_controller.dart';



class PosTabletLandscapeSlots {
  static PosLayoutSlots build({
    required PosTabletLandscapeController controller,
  }) {
    return PosLayoutSlots(
      header: PosHeaderBar(
        productCategories: controller.browser.productCategories,
        selectedProductCategoryId: controller.browser.selectedProductCategoryId,
        onProductCategoryChanged: controller.browser.onProductCategoryChanged,
        onSearchChanged: controller.browser.onSearchChanged,
        onSearchSubmitted: controller.browser.onSearchSubmitted,
        onMenuTap: controller.ui.onMenuTap,
        onUserTap: controller.ui.onUserTap,
        onMoreTap: controller.ui.onMoreTap,
      ),
      left: PosLeftPanel(
        controller: controller,
        columns: 5,
      ),
      right: PosRightPanel(
        controller: controller,
      ),
    );
  }
}
