import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/state/product_modal_controller.dart';
import '../repositories/config_repository.dart';
import '../shared/utils.dart';
import '../widgets/dialogs/moda_managerl.dart';
import '../widgets/layouts/pos_main_controller.dart';

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

  void onMoreTap(      BuildContext context,
      dynamic data,
      PosMainController controllerMain) {
    final result = 'onMoreTap -> click..${controllerMain.hasCustomerSelected}';
    final hasCustomer = controllerMain.hasCustomerSelected;
    debugPrint(result);
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 20, 0),
      items: [
        BuildItemIconMenu(
          icon: Icons.delete,
          text: 'Despejar el ticket',
          enabled: hasCustomer,
          value: 'clear',
        ),
        BuildItemIconMenu(
          icon: Icons.sync,
          text: 'Sincronizar',
          enabled: true,
          value: 'sync',
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'clear':
          debugPrint('CLICK -> Despejar ticket');
          break;

        case 'sync':
          debugPrint('CLICK -> Sincronizar');
          break;
      }
    });
  }

  void onUserTap(
      BuildContext context,
      dynamic data,
      PosMainController controllerMain,
      ) async {//PROCESS-INIT

    final service = CustomerServiceModal();
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
