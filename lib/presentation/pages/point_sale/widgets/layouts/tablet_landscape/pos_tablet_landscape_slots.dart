import '../../../../../shared/responsive/device_gesture_observer.dart';
import '../../organisms/pos_header_bar.dart';

import '../../sections/pos_left_panel.dart';
import '../../sections/pos_right_panel.dart';
import '../../slots/pos_layout_slots.dart';
import '../pos_main_controller.dart';

class PosTabletLandscapeSlots {
  //INIT PROCESS-MANAGER-UI-03
  static PosLayoutSlots build({required PosMainController controller}) {
    return PosLayoutSlots(
      header: PosHeaderBar(
        controllerMain: controller,
        productCategories: controller.browser.productCategories,
        selectedProductCategoryId: controller.browser.selectedProductCategoryId,
        onProductCategoryChanged: controller.browser.onProductCategoryChanged,
        onSearchChanged: controller.browser.onSearchChanged,
        onSearchSubmitted: controller.browser.onSearchSubmitted,
        onMenuTap: controller.ui.onMenuTap,
        onUserTap: (context, data) =>
            controller.ui.onUserTap(context, data, controller),
        onMoreTap: (context, data) =>
            controller.ui.onMoreTap(context, data, controller),
      ),
      left: PosLeftPanel(
        controller: controller,
        columns: controller.colsNumberRowPosSales,
      ),
      right: PosRightPanel(controller: controller),
    );
  }
}

class PosLandScapeSlots{
  //INIT PROCESS-MANAGER-UI-03
  static LayoutLandSlots build({required PosMainController controller,required DeviceSnapshot device}) {
    return LayoutLandSlots(
      header: PosHeaderBar(
        controllerMain: controller,
        productCategories: controller.browser.productCategories,
        selectedProductCategoryId: controller.browser.selectedProductCategoryId,
        onProductCategoryChanged: controller.browser.onProductCategoryChanged,
        onSearchChanged: controller.browser.onSearchChanged,
        onSearchSubmitted: controller.browser.onSearchSubmitted,
        onMenuTap: controller.ui.onMenuTap,
        onUserTap: (context, data) =>
            controller.ui.onUserTap(context, data, controller),
        onMoreTap: (context, data) =>
            controller.ui.onMoreTap(context, data, controller),
      ),
      body: PosAllBodyPanel(
        controller: controller,
        columns: controller.colsNumberRowPosSales,
        device: device,
      ),
    );
  }
}
