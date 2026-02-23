import 'package:flutter/material.dart';

import '../../helpers/no_glow_scroll_behavior.dart';
import '../../models/pos_payment_method.dart';
import '../../theme/pos_checkout_style.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../molecules/pos_ticket_body.dart';
import '../molecules/pos_ticket_header.dart';
import '../organisms/pos_ticket_checkout.dart';

class PosRightPanel extends StatelessWidget {
  final PosTabletLandscapeController controller;
  const PosRightPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final items = controller.ticketItems; // tu lista
        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              PosTicketHeader(title: 'Ticket', itemsCount: items.length),
              const SizedBox(height: 8),
              const Divider(height: 1),
              PosTicketBody(
                items: items,
                onMinus: (item) {
                  // controller.decreaseItem(item); // cuando lo tengas
                },
                onPlus: (item) {
                  // controller.increaseItem(item); // cuando lo tengas
                },
              ),
              PosTicketCheckout(controller: controller)

            ],
          ),
        );
      },
    );
  }
}

