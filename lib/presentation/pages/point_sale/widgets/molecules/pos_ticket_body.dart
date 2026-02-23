import 'package:flutter/material.dart';//oki

class PosTicketBody extends StatelessWidget {
  final List<dynamic> items; // cámbialo luego por List<PostTicketItem>
  final void Function(dynamic item) onMinus;
  final void Function(dynamic item) onPlus;

  const PosTicketBody({
    super.key,
    required this.items,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _TicketRowItem(
          item: items[i],
          onMinus: () => onMinus(items[i]),
          onPlus: () => onPlus(items[i]),
        ),
      ),
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
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
          Text('${item.amount.toStringAsFixed(0)}'),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}
