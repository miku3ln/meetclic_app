import 'package:flutter/cupertino.dart';

import '../../helpers/pos_responsive.dart';
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
    final isMobile = PosResponsive.isMobile(context);
    Widget setTotal= Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: valueStyle ?? s.totalsValueStyle,
    );
   if(isMobile){
     setTotal= Flexible(
       child: Text(
         value,
         maxLines: 1,
         overflow: TextOverflow.ellipsis,
         textAlign: TextAlign.end,
         style: valueStyle ?? s.totalsValueStyle,
       ),
     );
   }
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
        setTotal
      ],
    );
  }
}