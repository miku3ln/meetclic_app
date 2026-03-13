// lib/presentation/widgets/gamification/gamification_task_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';


import '../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../gamification_page/utils/gamification_task_card_resolver.dart';
import '../models/gamification_page_all_model.dart';

class GamificationTaskCardAll extends StatelessWidget {
  final C2BGamificationTask task;
  final GamificationCardVariant? variant;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryAction; // por ejemplo "Realizar"

  const GamificationTaskCardAll({
    super.key,
    required this.task,
    this.variant,
    this.onTap,
    this.onPrimaryAction,
  });
  // 👇 helper para envolver callbacks con try/catch
  VoidCallback? _safeCallback(VoidCallback? cb, String originTag) {
    if (cb == null) return null;

    return () {
      try {
        cb();
      } catch (e, st) {
        debugPrint(
          '[GamificationTaskCardAll][$originTag] ERROR en callback de ${task.code}: $e\n$st',
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    try {
      final resolvedVariant =
          variant ?? GamificationCardTypeResolver.resolve(task);

      switch (resolvedVariant.layout) {
        case GamificationCardLayout.imageLeft:
        case GamificationCardLayout.full:
          return _buildImageLeftCard(context, theme, resolvedVariant);
        case GamificationCardLayout.compact:
          return _buildCompactCard(context, theme, resolvedVariant);
        case GamificationCardLayout.others:
          return _buildCompactCard(context, theme, resolvedVariant);
      }
    } catch (e, st) {
      // 🔴 Log en consola para depurar
      debugPrint(
        '[GamificationTaskCardAll] ERROR al construir card de ${task.code}: $e\n$st',
      );
      // 🔁 Fallback: card simple con datos quemados
      return _buildFallbackErrorCard(theme, e.toString());
    }
  }

  // ============= CARD PRINCIPAL (Imagen izquierda + contenido derecha) =============

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
              if (variant.showImage) _buildImageSection(),
              Expanded(child: _buildInfoSection(theme, variant)),
            ],
          ),
        ),
      ),
    );
  }

  // Versión compacta, sin imagen
  Widget _buildCompactCard(
    BuildContext context,
    ThemeData theme,
    GamificationCardVariant variant,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  // ====================== FALLBACK: CARD DE ERROR ======================

  Widget _buildFallbackErrorCard(ThemeData theme, String errorMessage) {
    final String codeSafe =
        task.code; // si fuera nullable: task.code ?? 'SIN-CÓDIGO';

    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No se pudo mostrar esta misión de gamificación.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código: $codeSafe',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 🔍 Si quieres ver el error en UI (solo en dev)
                  Text(
                    'Detalle: $errorMessage',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== SECCIÓN: IMAGEN ======================

  Widget _buildImageSection() {
    final String url = task.sourceUrl ?? '';

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

  // ====================== SECCIÓN: CONTENIDO ======================

  Widget _buildInfoSection(ThemeData theme, GamificationCardVariant variant) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    String? validityText;
    if (task.hasExpiration && task.endDate != null) {
      validityText = 'Válido hasta ${dateFormat.format(task.endDate!)}';
    }

    final String rewardTypeLabel = task.typePoints == 'suma-yapitas'
        ? 'Yapitas Premium'
        : 'Yapitas';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: título + botón compartir opcional
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulClic,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: acción compartir (deep link / share)
                },
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Código + Auspiciante
          Text(
            '${task.code} · Auspicia: ${task.companyName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.azulClic,
            ),
          ),

          const SizedBox(height: 6),

          // Descripción
          Text(
            task.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.azulClic,
            ),
          ),

          const Spacer(),

          // Fila inferior: puntos, tipo recompensa, fecha/badge, botón acción
          Row(
            children: [
              // PUNTOS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: variant.rewardColor.withOpacity(0.1),
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

              // BADGE FECHA
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

              // BOTÓN PRINCIPAL (ej. "Realizar")
              if (onPrimaryAction != null)
                TextButton(
                  onPressed: onPrimaryAction,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.azulClic,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
