import 'package:flutter/material.dart';

import '../../theme/business_filters_colors.dart';
import '../atoms/toggle_filter_tile_atom.dart';

class GamificationFiltersMolecule extends StatelessWidget {
  final BusinessFiltersColors colors;

  final bool onlyWithGamesActive;
  final bool onlyWithRedeemableRewards;
  final bool onlyAlliedCompanies;

  final ValueChanged<bool> onChangedOnlyWithGamesActive;
  final ValueChanged<bool> onChangedOnlyWithRedeemableRewards;
  final ValueChanged<bool> onChangedOnlyAlliedCompanies;

  const GamificationFiltersMolecule({
    super.key,
    required this.colors,
    required this.onlyWithGamesActive,
    required this.onlyWithRedeemableRewards,
    required this.onlyAlliedCompanies,
    required this.onChangedOnlyWithGamesActive,
    required this.onChangedOnlyWithRedeemableRewards,
    required this.onChangedOnlyAlliedCompanies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Opciones de juegos y premios',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.categoriesTitleColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Filtra empresas según su configuración de gamificación y alianzas.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.categoriesSubtitleColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 🔵 Switches (átomos reutilizables)
       /* ToggleFilterTileAtom(
          title: 'Solo empresas con juegos activos',
          subtitle:
              'Muestra negocios que tienen tareas o misiones disponibles.',
          value: onlyWithGamesActive,
          onChanged: onChangedOnlyWithGamesActive,
        ),*/
        ToggleFilterTileAtom(
          title: 'Solo empresas donde puedo canjear premios',
          subtitle:
              'Filtra empresas que permiten canje de puntos por recompensas.',
          value: onlyWithRedeemableRewards,
          onChanged: onChangedOnlyWithRedeemableRewards,
        ),
        ToggleFilterTileAtom(
          title: 'Solo empresas aliadas entre empresas',
          subtitle:
              'Muestra empresas con alianzas activas para compartir o usar puntos de otras empresas.',
          value: onlyAlliedCompanies,
          onChanged: onChangedOnlyAlliedCompanies,
        ),
      ],
    );
  }
}
