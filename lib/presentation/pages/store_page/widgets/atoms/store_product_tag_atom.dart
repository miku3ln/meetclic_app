import 'package:flutter/material.dart';

import '../../theme/store_theme.dart';

class StoreProductTagAtom extends StatelessWidget {
  final String text;

  const StoreProductTagAtom({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: StoreTheme.azulClic,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: StoreTheme.azulClic,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
