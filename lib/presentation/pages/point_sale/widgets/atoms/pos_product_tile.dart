import 'package:flutter/material.dart';
import '../models/pos_product_item.dart';

class PosProductTile extends StatelessWidget {
  final PosProductItem item;
  final VoidCallback onTap;

  // fallbacks
  final Color defaultPlaceholderColor;
  final Color defaultTitleColor;

  // estilos configurables (como te gusta)
  final double radius;
  final double badgesGap;
  final EdgeInsets badgesPadding;
  final double badgeHeight;
  final TextStyle badgeTextStyle;

  final double bottomBarHeight;
  final Color bottomBarColor;
  final TextStyle titleStyle;

  const PosProductTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.defaultPlaceholderColor,
    required this.defaultTitleColor,

    // defaults según tu imagen
    this.radius = 10,
    this.badgesGap = 6,
    this.badgesPadding = const EdgeInsets.all(8),
    this.badgeHeight = 26,
    this.badgeTextStyle = const TextStyle(
      fontSize:9,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
    this.bottomBarHeight = 58,
    this.bottomBarColor = const Color(0xFF9E9E9E), // gris barra
    this.titleStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.0,
    ),
  });

  bool get _hasImage => (item.imageUrl ?? '').trim().isNotEmpty;

  String _money(double v) => '\$${v.toStringAsFixed(2)}';
  String _iva(double pct) => 'Iva ${pct.toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    final bg = item.placeholderColor ?? defaultPlaceholderColor;
    final titleColor = item.titleColor ?? defaultTitleColor;

    // si quieres que el titleStyle respete defaultTitleColor:
    final effectiveTitleStyle = titleStyle.copyWith(

        color: titleStyle.color ?? titleColor,


    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen o placeholder
              if (_hasImage)
                Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: bg),
                )
              else
                Container(color: bg),

              // ✅ Badges arriba-izquierda (precio + IVA)
              Positioned(
                left: badgesPadding.left,
                top: badgesPadding.top,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Pill(
                      text: _money(item.unitPrice),
                      height: badgeHeight,
                      // turquesa como tu ejemplo
                      background: const Color(0xFF11C5D9),
                      style: badgeTextStyle,
                    ),
                    SizedBox(height: badgesGap),
                    _Pill(
                      text: _iva(item.taxPercentage),
                      height: badgeHeight,
                      // azul como tu ejemplo
                      background: const Color(0xFF1E63FF),
                      style: badgeTextStyle,
                    ),
                  ],
                ),
              ),

              // ✅ Barra inferior gris con título centrado
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: bottomBarHeight,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: bottomBarColor.withOpacity(0.90),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: effectiveTitleStyle,
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

class _Pill extends StatelessWidget {
  final String text;
  final double height;
  final Color background;
  final TextStyle style;

  const _Pill({
    required this.text,
    required this.height,
    required this.background,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: style),
    );
  }
}