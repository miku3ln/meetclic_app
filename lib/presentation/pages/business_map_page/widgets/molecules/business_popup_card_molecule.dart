// presentation/pages/business_map_page/widgets/molecules/business_popup_card_molecule.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../../models/business_model.dart';
import '../atoms/gamification_tag_atom.dart';

class BusinessPopupCardMolecule extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onTap;

  // Colores opcionales (con defaults)
  final Color? cardColor;
  final Color? titleColor;
  final Color? rewardsIconColor;

  const BusinessPopupCardMolecule({
    super.key,
    required this.business,
    required this.onTap,
    this.cardColor,
    this.titleColor,
    this.rewardsIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final Color resolvedCardColor = cardColor ?? Colors.white;
    final Color resolvedTitleColor = titleColor ?? theme.colorScheme.onSurface;
    final Color resolvedRewardsIconColor =
        rewardsIconColor ?? theme.colorScheme.secondary;

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
                // ===== HEADER: Estrellas (izquierda) + nombre empresa (derecha) =====
                _buildHeader(theme, resolvedTitleColor),

                const SizedBox(height: 8),

                // Estado de premios / juegos
                _buildRewardsRow(theme, l10n, resolvedRewardsIconColor),

                const SizedBox(height: 8),

                // Tags de opciones de juego / canje
                _buildGamificationTags(theme, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header con rating a la izquierda y nombre empresa a la derecha
  Widget _buildHeader(ThemeData theme, Color titleColor) {
    // Aseguramos rango de 0 a 5
    final double rawRating = business.qualification;
    final double rating = rawRating.isNaN
        ? 0.0
        : rawRating.clamp(0.0, 5.0).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Estrellas + número
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBarIndicator(
              rating: rating,
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemSize: 18,
              unratedColor: theme.disabledColor.withOpacity(0.3),
            ),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Nombre empresa (ocupa el resto del espacio)
        Expanded(
          child: Text(
            business.businessName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsRow(
    ThemeData theme,
    AppLocalizations l10n,
    Color iconColor,
  ) {
    if (!business.hasGamification) {
      return Row(
        children: [
          Icon(Icons.videogame_asset_off, size: 18, color: theme.disabledColor),
          const SizedBox(width: 6),
          Text(
            // l10n.translate('business_map.no_rewards')
            'Sin juegos ni premios activos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.emoji_events, size: 20, color: iconColor),
        const SizedBox(width: 6),
        Text(
          // l10n.translate('business_map.rewards_available')
          'Premios disponibles para canje',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGamificationTags(ThemeData theme, AppLocalizations l10n) {
    if (!business.hasGamification) {
      return const SizedBox.shrink();
    }

    final List<Widget> tags = [];

    if (business.canRedeemHere) {
      tags.add(
        GamificationTagAtom(
          icon: Icons.store_mall_directory,
          // l10n.translate('business_map.redeem_here')
          label: 'Canje en esta empresa',
        ),
      );
    }

    if (business.canRedeemWithAllies) {
      tags.add(
        GamificationTagAtom(
          icon: Icons.group_work,
          // l10n.translate('business_map.redeem_allies')
          label: 'Canje con empresas aliadas',
        ),
      );
    }

    // Si no hay ninguna opción específica, mostramos un genérico
    if (tags.isEmpty) {
      tags.add(
        GamificationTagAtom(
          icon: Icons.videogame_asset,
          // l10n.translate('business_map.game_active')
          label: 'Juego activo',
        ),
      );
    }

    return Wrap(children: tags);
  }
}
