import 'package:flutter/material.dart';

import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';

class PosRightPanel extends StatelessWidget {
  final PosTabletLandscapeController controller;
  const PosRightPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final items = controller.ticketItems; // tu lista
        final subtotal = controller.subtotal;
        final tax = controller.subtotalTax;
        final total = controller.total;

        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _TicketHeader(title: 'Ticket', itemsCount: items.length),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // ✅ SCROLL SOLO AQUÍ
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _TicketRowItem(
                    item: items[i],
                    onMinus: () => {},
                    onPlus: () =>{}// controller.changeItemQty(items[i].productItem.id),
                  ),
                ),
              ),

              const Divider(height: 1),
              const SizedBox(height: 8),

              _Totals(subtotal: subtotal, tax: tax, total: total),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: controller.clearTicket,
                  child: const Text('Reiniciar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TicketHeader extends StatelessWidget {
  final String title;
  final int itemsCount;

  const _TicketHeader({required this.title, required this.itemsCount});

  @override
  Widget build(BuildContext context) {
    // ✅ ESTA ES LA PARTE QUE TE ESTÁ OVERFLOW
    // solución: Expanded + Text overflow
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Items: $itemsCount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  const _Totals({required this.subtotal, required this.tax, required this.total});

  @override
  Widget build(BuildContext context) {
    String m(double v) => v.toStringAsFixed(2);

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Subtotal')),
            Text('\$${m(subtotal)}'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Expanded(child: Text('Impuesto')),
            Text('\$${m(tax)}'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'TOTAL',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '\$${m(total)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}

class _TicketRowItem extends StatelessWidget {
  final dynamic item; // cambia por PostTicketItem
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _TicketRowItem({
    required this.item,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    // ⚠️ Aquí también suele overflow por textos largos
    // solución: Expanded + ellipsis
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productItem.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}  •  IVA ${item.productItem.taxPercentage.toStringAsFixed(0)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // controles (fijos)
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
          Text('${item.amount.toStringAsFixed(0)}'),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}