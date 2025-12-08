// presentation/pages/business_map_page/widgets/atoms/business_info_row_atom.dart
import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/models/business_model.dart';

class BusinessInfoRowAtom extends StatelessWidget {
  final BusinessModel business;

  const BusinessInfoRowAtom({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}
