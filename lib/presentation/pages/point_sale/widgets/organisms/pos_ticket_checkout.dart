import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/pos_checkout_style.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../molecules/pos_payment_methods_bar.dart';
import '../molecules/pos_totals_card.dart';

class PosTicketCheckout extends StatelessWidget {
  final PosTabletLandscapeController controller;
  final double totalsCardWidth;

  const PosTicketCheckout({
    super.key,
    required this.controller,
    this.totalsCardWidth = 190,
  });

  @override
  Widget build(BuildContext context) {
    final s = PosCheckoutStyle.of(context);

    final subtotal = controller.subtotal;
    final tax = controller.subtotalTax;
    final total = controller.total;

    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  PosPaymentMethodsBar(controller: controller),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: s.saveHeight,
                    child: ElevatedButton(
                      onPressed: controller.saveTicket,
                      style: s.saveButtonStyle,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: totalsCardWidth,
              child: PosTotalsCard(subtotal: subtotal, tax: tax, total: total),
            ),
          ],
        ),
      ],
    );
  }
}

