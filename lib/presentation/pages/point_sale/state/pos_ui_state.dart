import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/state/product_modal_controller.dart';
import '../widgets/dialogs/moda_managerl.dart';
import '../widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';

class PosUiState extends ChangeNotifier {
  final ValueNotifier<bool> isSummaryExpanded = ValueNotifier<bool>(false);

  VoidCallback? onRequestOpenDrawer;

  void toggleSummary() {
    isSummaryExpanded.value = !isSummaryExpanded.value;
  }

  void onMenuTap() {
    debugPrint('onMenuTap -> click');
    onRequestOpenDrawer?.call();
  }

  void onMoreTap() {
    debugPrint('onMoreTap -> click');
  }

  void onUserTap(
      BuildContext context,
      dynamic data,
      PosTabletLandscapeController controllerMain,
      ) async {

    final service = CustomerService();
    final controller = CustomerModalController(service);

    /// 🔥 DECIDES TODO AQUÍ (no en UI)
    if (controllerMain.hasCustomerSelected) {
      controller.initWithCustomer(controllerMain.selectedCustomer!);
    } else {
      controller.initLoadData(); // sin await → loading

    }

    await showCustomerModal(
      controllerMain: controllerMain,
      context: context,
      controller: controller,
    );
  }
}
