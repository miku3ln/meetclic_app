import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../state/pos_checkout_state.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';

class PosCheckoutActionToggle extends StatelessWidget {
  final PosTabletLandscapeController controller;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: CupertinoSlidingSegmentedControl<PosCheckoutAction>(
            groupValue: checkout.checkoutAction,
            padding: const EdgeInsets.all(4),
            thumbColor: checkout.isPaySelected
                ? c.payActiveBg
                : c.saveActiveBg,
            children: {
              PosCheckoutAction.save: _segIcon(
                icon: i.save,
                active: checkout.isSaveSelected,
                activeFg: c.saveActiveFg,
                inactiveFg: c.inactiveFg,
              ),
              PosCheckoutAction.pay: _segIcon(
                icon: i.pay,
                active: checkout.isPaySelected,
                activeFg: c.payActiveFg,
                inactiveFg: c.inactiveFg,
              ),
            },
            onValueChanged: (v) {
              if (v == null) return;
              checkout.setCheckoutAction(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _segIcon({
    required IconData icon,
    required bool active,
    required Color activeFg,
    required Color inactiveFg,
  }) {
    final fg = active ? activeFg : inactiveFg;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Icon(icon, size: 20, color: fg),
    );
  }
}