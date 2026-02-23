

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/pos_checkout_style.dart';
import '../atoms/pos_totals_row.dart';

class PosTotalsCard extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  const PosTotalsCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final s = PosCheckoutStyle.of(context);
    String m(double v) => v.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: s.totalsBg,
        borderRadius: BorderRadius.circular(s.radius),
        border: Border.all(color: s.border),
      ),
      child: Column(
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
    );
  }
}
