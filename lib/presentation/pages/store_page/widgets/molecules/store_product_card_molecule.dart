import 'package:flutter/material.dart';

import '../../models/store_product_model.dart';
import '../../theme/store_theme.dart';
import '../atoms/store_product_image_atom.dart';
import '../atoms/store_product_price_atom.dart';
import '../atoms/store_product_tag_atom.dart';

class StoreProductCardMolecule extends StatelessWidget {
  final StoreProductModel product;
  final VoidCallback? onAdd;

  const StoreProductCardMolecule({
    super.key,
    required this.product,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: StoreTheme.blanco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag + botón +
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: StoreProductTagAtom(text: product.origin)),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: StoreTheme.azulClic,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StoreProductImageAtom(imageUrl: product.imageUrl),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: StoreTheme.grisTexto,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.unit,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: StoreProductPriceAtom(price: product.price),
            ),
          ],
        ),
      ),
    );
  }
}
