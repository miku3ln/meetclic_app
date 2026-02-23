import 'package:flutter/material.dart';//oki

class PosTicketHeader extends StatelessWidget {
  final String title;
  final int itemsCount;
  const PosTicketHeader({super.key, required this.title, required this.itemsCount});

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
            'Productos: $itemsCount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}