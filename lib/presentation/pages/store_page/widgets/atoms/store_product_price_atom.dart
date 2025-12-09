import 'package:flutter/material.dart';

import '../../theme/store_theme.dart';

class StoreProductPriceAtom extends StatelessWidget {
  final double price;

  const StoreProductPriceAtom({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${price.toStringAsFixed(0)}',
      style: const TextStyle(
        color: StoreTheme.rojoPrecio,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
