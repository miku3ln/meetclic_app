import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/atoms/pos_menu_carousel.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/atoms/pos_right_fixed_actions.dart';

import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../models/pos_action_item.dart';

class PosActionBar extends StatelessWidget {
  final PosTabletLandscapeController controller;
  final List<PosMenuActionItem> menuCategories;

  // config
  final double height;
  final double rightWidthFactor; // ✅ porcentaje (0.0 - 1.0)
  final double minRightWidth;    // ✅ seguridad
  final double maxRightWidth;    // ✅ seguridad
  final EdgeInsets padding;

  const PosActionBar({
    super.key,
    required this.controller,
    required this.menuCategories,
    this.height = 150,
    this.rightWidthFactor = 0.40, // ✅ 30% por defecto
    this.minRightWidth = 300,     // ✅ evita que se vuelva muy angosto
    this.maxRightWidth = 520,     // ✅ evita que se vuelva gigante
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ancho disponible dentro del padding
              final double totalW = constraints.maxWidth;

              // calcula porcentaje
              double rightW = totalW * rightWidthFactor;

              // clamp con mínimos/máximos (Clean UX)
              if (rightW < minRightWidth) rightW = minRightWidth;
              if (rightW > maxRightWidth) rightW = maxRightWidth;

              return Row(
                children: [
                  Expanded(
                    child: PosMenuCarousel(
                      items: menuCategories,
                      selectedId: controller.selectedMenuCategoryId,
                      onTap: controller.onMenuCategoryTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const VerticalDivider(width: 1),
                  const SizedBox(width: 12),

                  SizedBox(
                    width: rightW,
                    child: PosRightFixedActions(
                      controller: controller,
                      onSave: controller.onSave,
                      onPay: controller.onPay,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}