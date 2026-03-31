import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers/no_glow_scroll_behavior.dart';
import '../../models/pos_payment_method.dart';
import '../../theme/pos_checkout_style.dart';
import '../atoms/pos_payment_chip.dart';
import '../layouts/pos_main_controller.dart';

class PosPaymentMethodsBar extends StatelessWidget {
  final PosMainController controller;

  const PosPaymentMethodsBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final s = PosCheckoutStyle.of(context);
    final selected = controller.payment.paymentMethod;

    return Container(
   //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: s.barBg,
        borderRadius: BorderRadius.circular(s.radius),
       // border: Border.all(color: s.border),
      ),
      child: SizedBox(
        height: s.chipHeight,
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: ListView(
            padding: EdgeInsets.zero, // ✅ sin padding interno
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              PosPaymentChip(
                label: 'Efectivo',
                icon: Icons.payments_outlined,
                selected: selected == PosPaymentMethod.cash,
                onTap: () => controller.payment.setPaymentMethod(PosPaymentMethod.cash),
              ),
              const SizedBox(width: 9),
              PosPaymentChip(
                label: 'Tarjetas ',
                icon: Icons.credit_card_outlined,
                selected: selected == PosPaymentMethod.card,
                onTap: () => controller.payment.setPaymentMethod(PosPaymentMethod.card),
              ),
              const SizedBox(width: 9),
              PosPaymentChip(
                label: 'QR Code',
                icon: Icons.qr_code_2_outlined,
                selected: selected == PosPaymentMethod.qr,
                onTap: () => controller.payment.setPaymentMethod(PosPaymentMethod.qr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}