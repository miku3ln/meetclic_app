import 'package:flutter/material.dart';
import '../atoms/pos_product_tile.dart';
import '../models/pos_product_item.dart';

class PosProductGrid extends StatelessWidget {
  final List<PosProductItem> products;
  final ValueChanged<PosProductItem> onProductTap;
  final int columns;
  final Color placeholderColor;
  final Color titleColor;
  final double spacing;
  final double runSpacing;

  const PosProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.columns = 5,
    this.placeholderColor = const Color(0xFF5A5A5A),
    this.titleColor = Colors.black,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      primary: false, // ✅ importante si hay scroll arriba
      physics: const ClampingScrollPhysics(), // ✅ Android tablet
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (_, i) {
        final item = products[i];
        return PosProductTile(
          item: item,
          defaultPlaceholderColor: placeholderColor,
          defaultTitleColor: titleColor,
          onTap: () => onProductTap(item),
        );
      },
    );
  }
}