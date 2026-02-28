
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
        controller: controller,
        columns: 5,
      ),

      right: PosRightPanel(controller: controller),

    );
  }
}
