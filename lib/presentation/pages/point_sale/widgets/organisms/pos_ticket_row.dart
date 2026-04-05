import 'package:flutter/material.dart';

import '../../theme/pos_ticket_styles.dart';
import '../models/pos_product_item.dart';

class PosTicketRow extends StatelessWidget {
  final PostTicketItem item;
  final PosTicketStyles styles;
  final bool isEdit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// ✅ toggle para activar/desactivar backgrounds de diseño
  final bool debug;

  /// ✅ configuración UI completa
  final PosTicketRowUi ui;

  const PosTicketRow({
    super.key,
    required this.item,
    required this.styles,
    required this.onMinus,
    required this.onPlus,
    required this.onEdit,
    required this.onDelete,
    this.debug = false,
    required this.isEdit,
    this.ui = const PosTicketRowUi(),
  });

  @override
  Widget build(BuildContext context) {
    final p = item.productItem;
    final hasCoupon = item.coupon != null;
    return Container(
      color: hasCoupon
          ? ui.couponRowBackground
          : ui.rowBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =========================
          // FILA 1
          // =========================
          SizedBox(
            height: ui.rowHeight,
            child: Row(
              children: [
                Expanded(
                  //DETAILS
                  flex: isEdit ? 7 : 10, // 🔥 ocupa todo si no es edit
                  child: _Dbg(
                    debug: debug,
                    color: ui.debugCol1Row1Bg,
                    child: Container(
                      height: ui.rowHeight,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                        horizontal: ui.titlePaddingX,
                      ),
                      decoration: BoxDecoration(
                        color: debug ? ui.debugTitleBoxBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(ui.titleRadius),
                      ),
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ui.titleTextStyle,
                      ),
                    ),
                  ),
                ),
                if (isEdit)
                  Expanded(
                    //ACTIONS
                    flex: 3,
                    child: _Dbg(
                      debug: debug,
                      color: ui.debugCol2Row1Bg,
                      child: Container(
                        height: ui.rowHeight,
                        padding: EdgeInsets.symmetric(
                          horizontal: ui.actionsPaddingX,
                        ),
                        alignment: Alignment.centerRight,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionIcon(
                                  ui: ui,
                                  onTap: onEdit,
                                  icon: ui.editIcon,
                                ),
                                SizedBox(width: ui.iconGap),
                                _ActionIcon(
                                  ui: ui,
                                  onTap: onDelete,
                                  icon: ui.deleteIcon,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // =========================
          // FILA 2
          // =========================
          SizedBox(
            height: ui.rowHeight,
            child: Row(
              children: [
                Expanded(
                  flex: isEdit ? 7 : 10, // 🔥 ocupa todo si no es edit
                  child: Row(
                    children: [
                      // 40% imagen
                      Expanded(
                        flex: 4,
                        child: _Dbg(
                          debug: debug,
                          color: ui.debugImageBg,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ui.imageRadius),
                            child: Container(
                              color: debug
                                  ? ui.debugImageBoxBg
                                  : Colors.transparent,
                              child: Image.network(
                                p.imageUrl ?? '',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;

                                  final expected = progress.expectedTotalBytes;
                                  final loaded = progress.cumulativeBytesLoaded;
                                  final value =
                                      (expected != null && expected > 0)
                                      ? loaded / expected
                                      : null;

                                  return Center(
                                    child: SizedBox(
                                      width: ui.loadingSize,
                                      height: ui.loadingSize,
                                      child: CircularProgressIndicator(
                                        strokeWidth: ui.loadingStroke,
                                        value: value,
                                        color: ui.loadingColor,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      ui.imageErrorIcon,
                                      size: ui.imageErrorIconSize,
                                      color: ui.imageErrorIconColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 60% precio / total
                      Expanded(
                        flex: 6,
                        child: _Dbg(
                          debug: debug,
                          color: ui.debugPriceBg,
                          child: _PriceTotalBox(
                            ui: ui,
                            debug: debug,
                            unitPrice: item.unitPrice,
                            qty: item.amount,
                            taxPct: (p.taxPercentage ?? 0).toDouble(),
                            hasCoupon: hasCoupon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEdit)
                  // stepper qty
                  Expanded(
                    flex: 3,
                    child: _Dbg(
                      debug: debug,
                      color: ui.debugQtyBg,
                      child: _QtyStepperPill(
                        ui: ui,
                        height: ui.qtyHeight,
                        valueText: '${item.amount}',
                        onMinus: onMinus,
                        onPlus: onPlus,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// ✅ CONFIGURACIÓN CENTRAL
/// =======================================================
class PosTicketRowUi {
  // general
  final Color rowBackground;
  final Color couponRowBackground;

  final double rowHeight;

  // debug backgrounds (para diseñar)
  final Color debugCol1Row1Bg;
  final Color debugCol2Row1Bg;
  final Color debugImageBg;
  final Color debugPriceBg;
  final Color debugQtyBg;

  // cajas internas (cuando debug está ON)
  final Color debugTitleBoxBg;
  final Color debugImageBoxBg;

  // title
  final TextStyle titleTextStyle;
  final double titlePaddingX;
  final double titleRadius;

  // actions
  final double actionsPaddingX;
  final double iconGap;

  // action icon button style
  final double actionHit;
  final double actionBox;
  final double actionRadius;
  final Color actionBg;
  final Color actionIconColor;
  final double actionIconSize;
  final IconData editIcon;
  final IconData deleteIcon;

  // image
  final double imageRadius;
  final double loadingSize;
  final double loadingStroke;
  final Color loadingColor;
  final IconData imageErrorIcon;
  final double imageErrorIconSize;
  final Color imageErrorIconColor;

  // qty stepper
  final double qtyHeight;
  final Color qtyPillBg;
  final Color qtyPillBorder;
  final double qtyPillRadius;
  final double qtySideIconSize;
  final Color qtySideIconColor;
  final double qtySideMinW;
  final double qtySideMaxW;
  final double qtyGapMin;
  final double qtyGapMax;
  final double qtyCenterRadius;
  final Color qtyCenterBg;
  final Color qtyCenterBorder;
  final TextStyle qtyTextStyle;

  // price/total
  final Color priceBg;
  final double pricePaddingX;
  final TextStyle unitTextStyle;
  final TextStyle totalTextStyle;
  final double priceLineGap;

  const PosTicketRowUi({
    // general
    this.rowBackground = Colors.transparent,
    this.couponRowBackground = const Color(0x33FFCC00),

    this.rowHeight = 42,

    // debug section colors
    this.debugCol1Row1Bg = const Color(0x334C4CFF),
    this.debugCol2Row1Bg = const Color(0x33FFCC00),
    this.debugImageBg = const Color(0x335C5CFF),
    this.debugPriceBg = const Color(0x334C4CFF),
    this.debugQtyBg = const Color(0x33FFFFFF),

    // internal debug boxes
    this.debugTitleBoxBg = const Color(0xFF4C4CFF),
    this.debugImageBoxBg = const Color(0xFF5C5CFF),

    // title
    this.titleTextStyle = const TextStyle(
      color: Colors.blue,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    this.titlePaddingX = 10,
    this.titleRadius = 10,

    // actions
    this.actionsPaddingX = 6,
    this.iconGap = 8,

    // action icon button
    this.actionHit = 42,
    this.actionBox = 34,
    this.actionRadius = 12,
    this.actionBg = Colors.white,
    this.actionIconColor = const Color(0xFF2C2C2C),
    this.actionIconSize = 18,
    this.editIcon = Icons.edit_outlined,
    this.deleteIcon = Icons.delete_outline,

    // image
    this.imageRadius = 10,
    this.loadingSize = 18,
    this.loadingStroke = 2,
    this.loadingColor = Colors.white,
    this.imageErrorIcon = Icons.image_not_supported_outlined,
    this.imageErrorIconSize = 18,
    this.imageErrorIconColor = Colors.white,

    // qty
    this.qtyHeight = 40,
    this.qtyPillBg = const Color(0xFFF3F5FA),
    this.qtyPillBorder = const Color(0xFFE6EAF2),
    this.qtyPillRadius = 999,
    this.qtySideIconSize = 18,
    this.qtySideIconColor = const Color(0xFF6B7280),
    this.qtySideMinW = 24,
    this.qtySideMaxW = 36,
    this.qtyGapMin = 2,
    this.qtyGapMax = 6,
    this.qtyCenterRadius = 10,
    this.qtyCenterBg = Colors.white,
    this.qtyCenterBorder = const Color(0xFFE6EAF2),
    this.qtyTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: Color(0xFF2C2C2C),
      height: 1.0,
    ),

    // price/total
    this.priceBg = const Color(0xFF4C4CFF),
    this.pricePaddingX = 10,
    this.unitTextStyle = const TextStyle(
      fontSize: 11,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: Colors.amber,
    ),
    this.totalTextStyle = const TextStyle(
      fontSize: 15,
      height: 1.0,
      fontWeight: FontWeight.w800,
      color: Colors.cyan,
    ),
    this.priceLineGap = 1,
  });
}

/// =======================================================
/// ✅ DEBUG WRAPPER (pinta background SOLO si debug = true)
/// =======================================================
class _Dbg extends StatelessWidget {
  final bool debug;
  final Color color;
  final Widget child;

  const _Dbg({required this.debug, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!debug) return child;
    return Container(color: color, child: child);
  }
}

/// =======================================================
/// ✅ ICONOS DE ACCIÓN
/// =======================================================
class _ActionIcon extends StatelessWidget {
  final PosTicketRowUi ui;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.ui,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: ui.actionHit,
        height: ui.actionHit,
        child: Center(
          child: Container(
            width: ui.actionBox,
            height: ui.actionBox,
            decoration: BoxDecoration(
              color: ui.actionBg,
              borderRadius: BorderRadius.circular(ui.actionRadius),
            ),
            child: Icon(
              icon,
              size: ui.actionIconSize,
              color: ui.actionIconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// ✅ STEPPER QTY
/// =======================================================
class _QtyStepperPill extends StatelessWidget {
  final PosTicketRowUi ui;
  final double height;
  final String valueText;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyStepperPill({
    required this.ui,
    required this.height,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final centerH = height - 10;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        final gap = (w * 0.04).clamp(ui.qtyGapMin, ui.qtyGapMax);
        final sideW = (w * 0.22).clamp(ui.qtySideMinW, ui.qtySideMaxW);

        return Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: gap),
          decoration: BoxDecoration(
            color: ui.qtyPillBg,
            borderRadius: BorderRadius.circular(ui.qtyPillRadius),
            border: Border.all(color: ui.qtyPillBorder),
          ),
          child: Row(
            children: [
              SizedBox(
                width: sideW,
                height: double.infinity,
                child: _PillSideButton(
                  ui: ui,
                  icon: Icons.remove,
                  onTap: onMinus,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Center(
                  child: Container(
                    height: centerH,
                    padding: EdgeInsets.symmetric(horizontal: gap * 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ui.qtyCenterBg,
                      borderRadius: BorderRadius.circular(ui.qtyCenterRadius),
                      border: Border.all(color: ui.qtyCenterBorder),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(valueText, style: ui.qtyTextStyle),
                    ),
                  ),
                ),
              ),
              SizedBox(width: gap),
              SizedBox(
                width: sideW,
                height: double.infinity,
                child: _PillSideButton(ui: ui, icon: Icons.add, onTap: onPlus),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PillSideButton extends StatelessWidget {
  final PosTicketRowUi ui;
  final IconData icon;
  final VoidCallback onTap;

  const _PillSideButton({
    required this.ui,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Center(
        child: Icon(icon, size: ui.qtySideIconSize, color: ui.qtySideIconColor),
      ),
    );
  }
}

/// =======================================================
/// ✅ PRICE / TOTAL (2 líneas si cabe)
/// =======================================================
class _PriceTotalBox extends StatelessWidget {
  final PosTicketRowUi ui;
  final bool debug;
  final double unitPrice;
  final int qty;
  final double taxPct;
  final bool hasCoupon;

  const _PriceTotalBox({
    required this.ui,
    required this.debug,
    required this.unitPrice,
    required this.qty,
    required this.taxPct,
    required this.hasCoupon,
  });

  @override
  Widget build(BuildContext context) {
    final hasTax = taxPct > 0;
    final unitShown = hasTax ? (unitPrice * (1 + taxPct / 100)) : unitPrice;
    final totalShown = unitShown * qty;

    String money(double v) => v.toStringAsFixed(2);

    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight.isFinite ? c.maxHeight : ui.rowHeight;
        final oneLine = h < 36;
        return Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: ui.pricePaddingX),
          decoration: BoxDecoration(
            color: debug
                ? ui.priceBg
                : Colors.transparent, // ✅ solo pinta si debug
          ),
          alignment: Alignment.centerLeft,
          child: oneLine
              ? Text(money(totalShown), style: ui.totalTextStyle)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(money(unitShown), style: ui.unitTextStyle),
                    SizedBox(height: ui.priceLineGap),
                    Text(money(totalShown), style: ui.totalTextStyle),
                  ],
                ),
        );
      },
    );
  }
}
