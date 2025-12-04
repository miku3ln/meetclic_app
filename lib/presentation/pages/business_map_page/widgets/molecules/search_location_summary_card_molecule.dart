import 'package:flutter/material.dart';

import '../../models/search_location_info_model.dart';
import '../../theme/business_filters_colors.dart';

/// --------------------------------------------------------------
/// Card “cerrada” que se ve dentro del BottomSheet
/// --------------------------------------------------------------
class SearchLocationSummaryCard extends StatelessWidget {
  final SearchLocationInfoModel info;
  final BusinessFiltersColors colors;
  final VoidCallback onTap;

  const SearchLocationSummaryCard({
    required this.info,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final street = info.street ?? 'Dirección no disponible';
    final parts = <String>[];
    if ((info.city ?? '').isNotEmpty) parts.add(info.city!);
    if ((info.state ?? '').isNotEmpty) parts.add(info.state!);
    if ((info.country ?? '').isNotEmpty) parts.add(info.country!);
    final locationLine = parts.isNotEmpty
        ? parts.join(', ')
        : 'Ubicación aproximada';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.headerBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.distanceSliderInactiveColor.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.distanceSliderActiveColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.my_location,
                color: colors.distanceSliderActiveColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación de búsqueda',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.categoriesTitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    street,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.distanceTitleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.categoriesSubtitleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lat: ${info.latitude.toStringAsFixed(5)}   ·   Lng: ${info.longitude.toStringAsFixed(5)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.distanceLabelColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_full, size: 18),
          ],
        ),
      ),
    );
  }
}
