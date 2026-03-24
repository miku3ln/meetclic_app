import 'package:flutter/material.dart';

import '../../../../../../shared/controllers/app_controller.dart';
import '../../../state/pos_product_browser_state.dart';
import '../../dialogs/moda_managerl.dart';
import '../../models/pos_product_item.dart';
import '../../../state/pos_shift_state.dart';
import '../../../state/pos_ticket_state.dart';
import '../../../state/pos_payment_state.dart';
import '../../../state/pos_checkout_state.dart';
import '../../../state/pos_ui_state.dart';

class PosTabletLandscapeController extends ChangeNotifier {
  final AppController app;
  final PosShiftState shift;
  final PosProductBrowserState browser;
  final PosTicketState ticket;
  final PosPaymentState payment;
  final PosCheckoutState checkout;
  final PosUiState ui;

  PosTabletLandscapeController({
    required AppController app,
    PosShiftState? shift,
    PosProductBrowserState? browser,
    PosTicketState? ticket,
    PosPaymentState? payment,
    PosCheckoutState? checkout,
    PosUiState? ui,
  }) : app = app,
       shift = shift ?? PosShiftState(app: app, storage: PosShiftStorage()),
       browser = browser ?? PosProductBrowserState(),
       ticket = ticket ?? PosTicketState(),
       payment = payment ?? PosPaymentState(),
       checkout = checkout ?? PosCheckoutState(),
       ui = ui ?? PosUiState() {
    _bindStates();
  }

  void _bindStates() {
    shift.addListener(notifyListeners);
    browser.addListener(notifyListeners);
    ticket.addListener(notifyListeners);
    payment.addListener(notifyListeners);
    checkout.addListener(notifyListeners);
    ui.addListener(notifyListeners);
  }

  Future<void> init({
    required List<PosProductItem> initialProducts,
    required List<PosCategoryItem> initialProductCategories,
    required List<PosCategoryItem> initialMenuCategories,
    String? initialSelectedProductCategoryId,
    String? initialSelectedMenuCategoryId,
  }) async {
    await shift.init();

    browser.init(
      initialProducts: initialProducts,
      initialProductCategories: initialProductCategories,
      initialMenuCategories: initialMenuCategories,
      initialSelectedProductCategoryId: initialSelectedProductCategoryId,
      initialSelectedMenuCategoryId: initialSelectedMenuCategoryId,
    );
  }

  void onProductTap(PosProductItem product) {
    ticket.addProduct(product);
  }

  void onSave() {
    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }

    debugPrint('onSave -> guardar ticket');
    ticket.saveTicket();
  }

  void onPay() {
    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }

    debugPrint('onPay -> cobrar');
  }

  void onPrimaryCheckoutTap() {
    if (checkout.checkoutAction == PosCheckoutAction.pay) {
      onPay();
    } else {
      onSave();
    }
  }

  @override
  void dispose() {
    shift.removeListener(notifyListeners);
    browser.removeListener(notifyListeners);
    ticket.removeListener(notifyListeners);
    payment.removeListener(notifyListeners);
    checkout.removeListener(notifyListeners);
    ui.removeListener(notifyListeners);
    ui.isSummaryExpanded.dispose();
    super.dispose();
  }

  CustomerModelPosCurrent? selectedCustomer;

  void setCustomerTicket(CustomerModelPosCurrent? selectedCustomerCurrent) {
    selectedCustomer = selectedCustomerCurrent;
    notifyListeners();

  }
}
