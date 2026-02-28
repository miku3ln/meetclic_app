import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/pos_checkout_style.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../molecules/pos_checkout_action_toggle.dart';
import '../molecules/pos_checkout_primary_button.dart';
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
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Columna izquierda 60%
        Expanded(
          flex: 6,
          child: Column(
            children: [
              // ✅ Fila 1: 40% / 60%
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 80,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: PosCheckoutActionToggle(controller: controller),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6, // 60%
                    child: SizedBox(
                      height: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Formas de Pago',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // ✅ el bar ocupa el ancho disponible
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: PosPaymentMethodsBar(
                                controller: controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),



              // ✅ Fila 2: 100%
              SizedBox(
                height: 40,
                width: double.infinity,
                child: PosCheckoutPrimaryButton(
                  controller: controller,
                  height: 40,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ✅ Columna derecha 40%
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: totalsCardWidth, // tu ancho fijo
              child: PosTotalsCardBox(
                widthFactor: 1,
                subtotal: controller.subtotal,
                tax: controller.subtotalTax,
                total: controller.total,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
