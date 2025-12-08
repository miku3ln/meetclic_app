// presentation/pages/business_map_page/widgets/molecules/business_popup_card_molecule.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../../helpers/business_marker_visual_resolver.dart'
    show BusinessGamificationTypeResolver;
import '../../models/meet_clic_colors.dart';
import '../atoms/gamification_tag_atom.dart';

class BusinessPopupCardMolecule extends StatelessWidget {
  final BusinessModel business;
  final int
  type; // 0 = marcador ubicación, 1 = marcador negocio (por ahora usamos 1)

  final VoidCallback onTap;

  // Colores opcionales (con defaults)
  final Color? cardColor;
  final Color? titleColor;
  final Color? rewardsIconColor;

  const BusinessPopupCardMolecule({
    super.key,
    required this.business,
    required this.onTap,
    required this.type,
    this.cardColor,
    this.titleColor,
    this.rewardsIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // 🔥 Resolver tipo de gamificación a partir de los flags de la empresa
    final gamificationType = BusinessGamificationTypeResolver.fromBusiness(
      business,
    );
    final gamificationConfig = BusinessGamificationTypeConfig.fromType(
      gamificationType,
    );

    final Color resolvedCardColor = cardColor ?? Colors.white;
    final Color resolvedTitleColor = titleColor ?? theme.colorScheme.onSurface;
    final Color resolvedRewardsIconColor =
        rewardsIconColor ?? gamificationConfig.primaryColor;

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
                // 1) Info base de la empresa
                _buildHeader(theme, resolvedTitleColor),
                const SizedBox(height: 6),
                _buildInfoRow(theme),
                const SizedBox(height: 10),

                // 2) Estado de gamificación (Piedra / Chakana / Inti / Minga)
                _buildGamificationHeader(
                  theme: theme,
                  config: gamificationConfig,
                ),
                const SizedBox(height: 6),

                // 3) Descripción funcional (qué puedo hacer aquí)
                _buildGamificationDescription(
                  theme: theme,
                  config: gamificationConfig,
                ),
                const SizedBox(height: 6),

                // 4) Chips de opciones concretas (canje local / aliados)
                _buildGamificationTags(theme, l10n, gamificationType),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // 1) HEADER: rating + nombre
  // ----------------------------------------------------------
  Widget _buildHeader(ThemeData theme, Color titleColor) {
    final double rawRating = business.summary?.rating.averageStars ?? 0.0;
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

  // ----------------------------------------------------------
  // Logo + categoría + teléfono
  // ----------------------------------------------------------
  Widget _buildInfoRow(ThemeData theme) {
    final hasLogo = business.sourceLogo.isNotEmpty;
    final hasCategory = business.subcategoryName.isNotEmpty;
    final hasPhone = business.phoneValue.isNotEmpty;

    if (!hasLogo && !hasCategory && !hasPhone) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasLogo) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: NetworkImage(business.sourceLogo),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCategory)
                Text(
                  business.subcategoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              if (hasPhone) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        business.phoneValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // 2) HEADER DE GAMIFICACIÓN (icono + nombre andino)
  // ----------------------------------------------------------
  Widget _buildGamificationHeader({
    required ThemeData theme,
    required BusinessGamificationTypeConfig config,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: config.badgeBackgroundColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(config.icon, size: 18, color: config.primaryColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            // Ej: "Piedra – Sin gamificación" / "Inti – Canje local"
            _buildGamificationTitleFromConfig(config),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: config.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  String _buildGamificationTitleFromConfig(
    BusinessGamificationTypeConfig config,
  ) {
    switch (config.type) {
      case BusinessGamificationType.none:
        return '${config.andeanSymbolName} – Sin gamificación';
      case BusinessGamificationType.basic:
        return '${config.andeanSymbolName} – Gamificación activo';
      case BusinessGamificationType.redeemLocal:
        return '${config.andeanSymbolName} – Canje en esta empresa';
      case BusinessGamificationType.redeemAllies:
        return '${config.andeanSymbolName} – Canje en red de aliados';
    }
  }

  // ----------------------------------------------------------
  // 3) DESCRIPCIÓN DE FUNCIONALIDAD (texto corto)
  // ----------------------------------------------------------
  Widget _buildGamificationDescription({
    required ThemeData theme,
    required BusinessGamificationTypeConfig config,
  }) {
    return Text(config.description, style: theme.textTheme.bodySmall);
  }

  // ----------------------------------------------------------
  // 4) CHIPS / TAGS SEGÚN FUNCIONALIDAD REAL
  // ----------------------------------------------------------
  Widget _buildGamificationTags(
    ThemeData theme,
    AppLocalizations l10n,
    BusinessGamificationType gamificationType,
  ) {
    if (business.gamificationId <= 0) {
      // piedra → no mostramos chips
      return const SizedBox.shrink();
    }

    final List<Widget> tags = [];

    // Siempre que haya gamificación, mostramos al menos "Juego activo"
    tags.add(
      const GamificationTagAtom(
        icon: Icons.videogame_asset,
        label: 'Juego activo',
      ),
    );

    // Canje en esta empresa
    if (business.allowExchange == 1) {
      tags.add(
        const GamificationTagAtom(
          icon: Icons.store_mall_directory,
          label: 'Canje en esta empresa',
        ),
      );
    }

    // Canje en empresas aliadas
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
