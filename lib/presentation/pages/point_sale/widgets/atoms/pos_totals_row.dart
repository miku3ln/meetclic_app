import 'package:flutter/cupertino.dart';

import '../../theme/pos_checkout_style.dart';

class PosTotalsRow  extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const PosTotalsRow ({super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final s = PosCheckoutStyle.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle ?? s.totalsLabelStyle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: valueStyle ?? s.totalsValueStyle,
        ),
      ],
    );
  }
}