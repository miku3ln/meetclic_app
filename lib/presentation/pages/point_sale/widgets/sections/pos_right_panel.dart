import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import '../../../../../shared/controllers/app_controller.dart';
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

    final app = context.watch<AppController>(); // ✅ lee modo global
    final bool isLoginMode = app.isLoginRequired;
    final double heightPostTicket=isLoginMode?170:200;
    final styles = const PosTicketStyles().copyWith(
      leftThumbSize: 30,
      rightColumnWidth: 100,
      iconButtonSize: 25,
    );
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final items = controller.ticket.items;
        return Container(
          padding: const EdgeInsets.all(12),
          child: controller.shift. isShiftOpen
              ? Column(
            children: [
              PosTicketHeader(title: 'Ticketsss', itemsCount: items.length,controllerMain:controller),
              const SizedBox(height: 50), // ✅ antes 50
              const Divider(height: 0),
              // ✅ Lista ocupa todo menos checkout
              Expanded(
                child: PosTicketBody(
                  items: controller.ticket.items,
                  styles: styles,
                  onMinus: (it) => controller.ticket. decreaseItem(it),
                  onPlus: (it) => controller.ticket.increaseItem(it),
                  onEdit: (it) => controller.ticket.editTicketItem(it),
                  onDelete: (it) => controller.ticket.removeItem(it),
                ),
              ),

              // ✅ Checkout fijo
              SizedBox(
                height: heightPostTicket,
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
