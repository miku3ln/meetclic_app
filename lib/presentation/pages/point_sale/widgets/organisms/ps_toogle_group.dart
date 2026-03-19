import 'package:flutter/material.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../molecules/ps_toogle_option.dart';



enum SellType { unit, weight }

class PsSellTypeSelector extends StatelessWidget {
  final SellType value;
  final Function(SellType) onChanged;

  const PsSellTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vendido por",
          style: AppTextStyles.bodySecondary(context),
        ),

        AppSpacing.spaceBetweenInputs,

        Row(
          children: [
            PsToggleOption(
              icon: Icons.inventory_2_outlined,
              label: "Unidad",
              isSelected: value == SellType.unit,
              onTap: () => onChanged(SellType.unit),
            ),

            const SizedBox(width: 8),

            PsToggleOption(
              icon: Icons.scale_outlined,
              label: "Peso",
              isSelected: value == SellType.weight,
              onTap: () => onChanged(SellType.weight),
            ),
          ],
        ),
      ],
    );
  }
}