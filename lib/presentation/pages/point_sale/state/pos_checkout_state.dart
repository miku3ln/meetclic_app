import 'package:flutter/material.dart';

import '../widgets/layouts/tablet_landscape/settings/pos_checkout_toggle_style.dart';

enum PosCheckoutAction { pay, save }

class PosCheckoutState extends ChangeNotifier {
  ValueChanged<PosCheckoutAction>? onCheckoutActionChanged;

  PosCheckoutAction _checkoutAction = PosCheckoutAction.pay;

  PosCheckoutAction get checkoutAction => _checkoutAction;

  bool get isPaySelected => _checkoutAction == PosCheckoutAction.pay;
  bool get isSaveSelected => _checkoutAction == PosCheckoutAction.save;

  PosCheckoutToggleColors toggleColors = PosCheckoutToggleColors.defaults();
  PosCheckoutToggleIcons toggleIcons = PosCheckoutToggleIcons.defaults();

  void setCheckoutAction(PosCheckoutAction value) {
    if (_checkoutAction == value) return;
    _checkoutAction = value;
    onCheckoutActionChanged?.call(value);
    notifyListeners();
  }
}