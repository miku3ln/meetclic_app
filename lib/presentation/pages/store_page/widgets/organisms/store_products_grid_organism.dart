import 'package:flutter/material.dart';

import '../../models/store_product_model.dart';
import '../molecules/store_product_card_molecule.dart';
import '../molecules/store_promo_card_molecule.dart';

class StoreProductsGridOrganism extends StatelessWidget {
  final List<StoreProductModel> products;
  final VoidCallback? onAddProduct;

  const StoreProductsGridOrganism({
    super.key,
    required this.products,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 0.70,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];

        if (product.isPromo) {
          return const StorePromoCardMolecule();
        }

        return StoreProductCardMolecule(product: product, onAdd: onAddProduct);
      },
    );
  }
}
