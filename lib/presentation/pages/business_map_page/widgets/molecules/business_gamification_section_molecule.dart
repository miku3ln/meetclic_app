// presentation/pages/business_map_page/widgets/molecules/business_gamification_section_molecule.dart
import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../../helpers/business_marker_visual_resolver.dart'
    show BusinessGamificationTypeResolver;
import '../../models/meet_clic_colors.dart';
import '../atoms/gamification_status_atom.dart';
import '../atoms/gamification_tag_atom.dart';

class BusinessGamificationSectionMolecule extends StatelessWidget {
  final BusinessModel business;

  const BusinessGamificationSectionMolecule({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Resolver tipo de gamificación (Piedra / Chakana / Inti / Minga)
    final gamificationType = BusinessGamificationTypeResolver.fromBusiness(
      business,
    );
    final config = BusinessGamificationTypeConfig.fromType(gamificationType);

    // Sin gamificación → no mostramos nada (o podrías mostrar solo la Piedra, si quieres)
    if (gamificationType == BusinessGamificationType.none) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1) Estado (icono + título andino)
        GamificationStatusAtom(config: config),
        const SizedBox(height: 6),

        // 2) Descripción corta
        Text(config.description, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),

        // 3) Chips de funcionalidad concreta
        _buildGamificationTags(theme: theme, l10n: l10n, business: business),
      ],
    );
  }

  Widget _buildGamificationTags({
    required ThemeData theme,
    required AppLocalizations l10n,
    required BusinessModel business,
  }) {
    final List<Widget> tags = [];

    // Siempre que haya gamificación, mostramos al menos "Juego activo"
    tags.add(
      const GamificationTagAtom(
        icon: Icons.videogame_asset,
        label: 'Juego activo',
      ),
    );

    if (business.allowExchange == 1) {
      tags.add(
        const GamificationTagAtom(
          icon: Icons.store_mall_directory,
          label: 'Canje en esta empresa',
        ),
      );
    }

    if (business.allowExchangeBusiness == 1) {
      tags.add(
        const GamificationTagAtom(
          icon: Icons.group_work,
          label: 'Canje con empresas aliadas',
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 4, children: tags);
  }
}
