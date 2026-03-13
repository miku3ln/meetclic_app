import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';


import '../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../models/gamification_page_all_model.dart';
import '../utils/gamification_task_card_resolver.dart';

class GamificationTaskCard extends StatelessWidget {
  final C2BGamificationTask task;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryAction;

  const GamificationTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = GamificationCardTypeResolver.resolve(task);

    // De momento usamos siempre layout imageLeft/compact según variant
    if (variant.showImage) {
      return _buildImageLeftCard(context, theme, variant);
    } else {
      return _buildCompactCard(context, theme, variant);
    }
  }

  // -------- CARD CON IMAGEN IZQUIERDA --------
  Widget _buildImageLeftCard(
    BuildContext context,
    ThemeData theme,
    GamificationCardVariant variant,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              _buildImageSection(),
              Expanded(child: _buildInfoSection(theme, variant)),
            ],
          ),
        ),
      ),
    );
  }

  // -------- CARD COMPACTO (SIN IMAGEN) --------
  Widget _buildCompactCard(
    BuildContext context,
    ThemeData theme,
    GamificationCardVariant variant,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildInfoSection(theme, variant),
        ),
      ),
    );
  }

  // -------- SECCIÓN: IMAGEN --------
  Widget _buildImageSection() {
    final url = task.sourceUrl ?? '';

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: SizedBox(
        width: 140,
        height: double.infinity,
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
              )
            : Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.store, size: 40),
              ),
      ),
    );
  }

  // -------- SECCIÓN: TEXTO Y BADGES --------
  Widget _buildInfoSection(ThemeData theme, GamificationCardVariant variant) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    String? validityText;
    if (task.hasExpiration && task.endDate != null) {
      validityText = 'Válido hasta ${dateFormat.format(task.endDate!)}';
    }

    final String rewardTypeLabel = task.typePoints == 'suma-yapitas'
        ? 'Yapitas premium'
        : 'Yapitas';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // título + código
          Text(
            task.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.azulClic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${task.code} · ${task.companyName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.amarilloVital,
            ),
          ),
          const SizedBox(height: 6),

          // descripción
          Text(
            task.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.amarilloVital,
            ),
          ),

          const Spacer(),

          // fila inferior: puntos + fecha + botón
          Row(
            children: [
              // puntos + tipo recompensa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: variant.rewardColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: variant.rewardColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${task.points} $rewardTypeLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // badge fecha si aplica
              if (validityText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: variant.badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    validityText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: variant.badgeColor,
                    ),
                  ),
                ),

              const Spacer(),

              if (onPrimaryAction != null)
                TextButton(
                  onPressed: onPrimaryAction,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.azulClic,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'REALIZAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
