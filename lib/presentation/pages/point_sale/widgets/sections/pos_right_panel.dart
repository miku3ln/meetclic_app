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
      // aquí tuneas TODO “en cada punto”
      leftThumbSize: 56,
      rightColumnWidth: 122,
      iconButtonSize: 34,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final items = controller.ticketItems; // tu lista
        return Container(
          padding: const EdgeInsets.all(12),
          child: controller.isShiftOpen
              ? Column(
                  children: [
                    PosTicketHeader(title: 'Ticket', itemsCount: items.length),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    PosTicketBody(
                      items: controller.ticketItems,
                      // List<PostTicketItem>
                      styles: styles,
                      onMinus: (it) => controller.decreaseItem(it),
                      onPlus: (it) => controller.increaseItem(it),
                      onEdit: (it) => controller.editTicketItem(it),
                      onDelete: (it) => controller.removeItem(it),
                    ),
                    PosTicketCheckout(controller: controller),
                  ],
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
