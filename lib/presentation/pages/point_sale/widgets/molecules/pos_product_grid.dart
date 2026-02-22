import 'package:flutter/material.dart';
import '../atoms/pos_product_tile.dart';
import '../models/pos_product_item.dart';

class PosProductGrid extends StatelessWidget {
  final List<PosProductItem> products;
  final ValueChanged<PosProductItem> onProductTap;
  /// Tablet Landscape: 5 columnas
  final int columns;
  /// estilos globales (fallback)
  final Color placeholderColor;
  final Color titleColor;

  /// separaciones
  final double spacing;
  final double runSpacing;

  const PosProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.columns = 5,
    this.placeholderColor = const Color(0xFF5A5A5A),
    this.titleColor = Colors.white,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 🔥 scroll lo maneja el panel
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1.15, // ajusta si quieres más “cuadrado”
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