import 'package:flutter/material.dart';
import '../../theme/pos_ticket_styles.dart';

class PosTicketItemMeta extends StatelessWidget {
  final String title;
  final String subtitle;
  final double ivaPct;
  final double total; // 14.18 (azul abajo)

  final PosTicketStyles styles;

  const PosTicketItemMeta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ivaPct,
    required this.total,
    required this.styles,
  });

  String _money(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        // opcional: para que respire como en la imagen
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.titleStyle,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.subtitleStyle.copyWith(color: styles.mutedText),
            ),
            const SizedBox(height: 4),
            Text(
              'IVA ${ivaPct.toStringAsFixed(0)}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.ivaStyle.copyWith(color: styles.mutedText),
            ),
            const SizedBox(height: 6),
            Text(
              _money(total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // 👇 azul como tu imagen (recomendado meterlo al styles si quieres 100% config)
              style: styles.totalRightStyle.copyWith(color: const Color(0xFF2F66FF)),
            ),
          ],
        ),
      ),
    );
  }
}