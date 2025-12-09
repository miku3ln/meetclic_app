import 'package:flutter/material.dart';

import '../../theme/store_theme.dart';

class StorePromoCardMolecule extends StatelessWidget {
  const StorePromoCardMolecule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: StoreTheme.amarilloVital.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'A Summer Surprise',
            style: TextStyle(fontSize: 12, color: StoreTheme.grisTexto),
          ),
          SizedBox(height: 8),
          Text(
            '30% OFF',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StoreTheme.azulClic,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Use el código para tus compras de verano.',
            style: TextStyle(fontSize: 11, color: StoreTheme.grisTexto),
          ),
        ],
      ),
    );
  }
}
