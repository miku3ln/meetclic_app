import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../widgets/toogle-manager.dart';
import '../../state/pos_checkout_state.dart';
import '../layouts/pos_main_controller.dart';



class PosCheckoutActionToggle extends StatelessWidget {
  final PosMainController controller;
  final String title;

  const PosCheckoutActionToggle({
    super.key,
    required this.controller,
    this.title = 'Tipo Gestión',
  });

  @override
  Widget build(BuildContext context) {
    final checkout = controller.checkout;
    final c = checkout.toggleColors;
    final i = checkout.toggleIcons;

    return PsSegmentToggle<PosCheckoutAction>(
      title: title,

      value: checkout.checkoutAction,

      borderColor: c.border,

      thumbColor: checkout.isPaySelected
          ? c.payActiveBg
          : c.saveActiveBg,

      inactiveForegroundColor: c.inactiveFg,

      items: [
        PsSegmentItem(
          value: PosCheckoutAction.save,
          activeIcon: i.save,
          inactiveIcon: i.save,
          activeColor: c.saveActiveFg,
        ),

        PsSegmentItem(
          value: PosCheckoutAction.pay,
          activeIcon: i.pay,
          inactiveIcon: i.pay,
          activeColor: c.payActiveFg,
        ),
      ],

      onChanged: checkout.setCheckoutAction,
    );
  }
}