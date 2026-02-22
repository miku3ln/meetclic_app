import 'package:flutter/material.dart';
import '../models/pos_product_item.dart';

class PosProductTile extends StatelessWidget {
  final PosProductItem item;
  final VoidCallback onTap;
  final Color defaultPlaceholderColor;
  final Color defaultTitleColor;

  const PosProductTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.defaultPlaceholderColor,
    required this.defaultTitleColor,
  });

  bool get _hasImage => (item.imageUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bg = item.placeholderColor ?? defaultPlaceholderColor;
    final titleColor = item.titleColor ?? defaultTitleColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // background: imagen o color
              if (_hasImage)
                Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: bg),
                )
              else
                Container(color: bg),

              // overlay para que el texto se lea
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.45),
                      ],
                    ),
                  ),
                ),
              ),

              // título abajo
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}