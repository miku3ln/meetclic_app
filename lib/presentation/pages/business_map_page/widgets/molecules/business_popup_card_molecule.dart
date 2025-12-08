// presentation/pages/business_map_page/widgets/molecules/business_popup_card_molecule.dart
import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../atoms/business_header_atom.dart';
import '../atoms/business_info_row_atom.dart';
import 'business_gamification_section_molecule.dart';

class BusinessPopupCardMolecule extends StatelessWidget {
  final BusinessModel business;
  final int type; // 0 = marcador ubicación, 1 = marcador negocio

  final VoidCallback onTap;

  // Colores opcionales (con defaults)
  final Color? cardColor;
  final Color? titleColor;

  const BusinessPopupCardMolecule({
    super.key,
    required this.business,
    required this.onTap,
    required this.type,
    this.cardColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context); // por si luego lo usamos

    final Color resolvedCardColor = cardColor ?? Colors.white;
    final Color resolvedTitleColor = titleColor ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: resolvedCardColor,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Header: rating + nombre empresa
                BusinessHeaderAtom(
                  business: business,
                  titleColor: resolvedTitleColor,
                ),
                const SizedBox(height: 6),

                // 2) Info: logo + categoría + teléfono
                BusinessInfoRowAtom(business: business),
                const SizedBox(height: 10),

                // 3) Sección de gamificación completa
                BusinessGamificationSectionMolecule(business: business),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
