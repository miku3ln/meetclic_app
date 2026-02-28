import 'package:flutter/material.dart';
import '../../theme/pos_ticket_styles.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../molecules/pos_ticket_header.dart';
import '../organisms/pos_ticket_checkout.dart';
import '../organisms/pos_ticket_list.dart';
class PosRightPanel extends StatelessWidget {
  final PosTabletLandscapeController controller;

  const PosRightPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final styles = const PosTicketStyles().copyWith(
      leftThumbSize: 30,
      rightColumnWidth: 100,
      iconButtonSize: 25,
    );



    return AnimatedBuilder(

      animation: controller,
      builder: (_, __) {
        final items = controller.ticketItems;

        return Container(
          padding: const EdgeInsets.all(12),
          child: controller.isShiftOpen
              ? Column(
            children: [
              PosTicketHeader(title: 'Ticket', itemsCount: items.length),
              const SizedBox(height: 50), // ✅ antes 50
              const Divider(height: 1),

              // ✅ Lista ocupa todo menos checkout
              Expanded(
                child: PosTicketBody(
                  items: controller.ticketItems,
                  styles: styles,
                  onMinus: (it) => controller.decreaseItem(it),
                  onPlus: (it) => controller.increaseItem(it),
                  onEdit: (it) => controller.editTicketItem(it),
                  onDelete: (it) => controller.removeItem(it),
                ),
              ),

              // ✅ Checkout fijo
              SizedBox(
                height: 245,
                child: PosTicketCheckout(controller: controller),
              ),
            ],
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
