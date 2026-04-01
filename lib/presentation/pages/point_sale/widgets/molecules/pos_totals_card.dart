import 'package:flutter/material.dart';
import '../../theme/pos_checkout_style.dart';
import '../atoms/pos_totals_row.dart';

enum PosTotalsCardVariant { full, compact }

class PosTotalsCard extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  final PosTotalsCardVariant variant;

  const PosTotalsCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.variant = PosTotalsCardVariant.full,
  });

  @override
  Widget build(BuildContext context) {
    final s = PosCheckoutStyle.of(context);
    String m(double v) => v.toStringAsFixed(2);

    if (variant == PosTotalsCardVariant.compact) {
      // ✅ Pastilla "Total  $0.00" (como tu imagen 2)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: s.totalsBg,
          borderRadius: BorderRadius.circular(s.radius),
          border: Border.all(color: s.border),
        ),
        child: PosTotalsRow(
          label: 'Total',
          value: '\$${m(total)}',
          labelStyle: s.totalLabelStyle,
          valueStyle: s.totalValueStyle,
        ),
      );
    }

    // ✅ Completo (como tu imagen 1)
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: s.totalsBg,
        borderRadius: BorderRadius.circular(s.radius),
        border: Border.all(color: s.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PosTotalsRow(label: 'Subtotal', value: '\$${m(subtotal)}'),
            const SizedBox(height: 10),
            PosTotalsRow(label: 'Tax', value: '\$${m(tax)}'),
            const SizedBox(height: 12),
            Divider(height: 1, color: s.border),
            const SizedBox(height: 12),
            PosTotalsRow(
              label: 'Total',
              value: '\$${m(total)}',
              labelStyle: s.totalLabelStyle,
              valueStyle: s.totalValueStyle,
            ),
          ],
        ),
      ),
    );
  }
}


class PosTotalsCardBox extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  /// porcentaje del ancho de su padre (columna derecha)
  final double widthFactor;

  /// si quieres forzar compacto o completo desde afuera
  final bool? forceCompact;

  const PosTotalsCardBox({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.widthFactor = 1,
    this.forceCompact,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.topRight,
      child: LayoutBuilder(
        builder: (context, c) {
          // ✅ Regla: si es muy pequeño (alto o ancho), mostrar compacto
          final bool autoCompact =
              c.maxHeight < 90 || c.maxWidth < 180;

          final bool compact = forceCompact ?? autoCompact;

          return PosTotalsCard(
            subtotal: subtotal,
            tax: tax,
            total: total,
            variant:PosTotalsCardVariant.full,
          );
        },
      ),
    );
  }
}