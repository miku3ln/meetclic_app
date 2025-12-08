// presentation/pages/business_map_page/widgets/atoms/business_header_atom.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:meetclic_app/domain/models/business_model.dart';

class BusinessHeaderAtom extends StatelessWidget {
  final BusinessModel business;
  final Color? titleColor;

  const BusinessHeaderAtom({
    super.key,
    required this.business,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double rawRating = business.summary?.rating.averageStars ?? 0.0;
    final double rating = rawRating.isNaN
        ? 0.0
        : rawRating.clamp(0.0, 5.0).toDouble();

    final Color resolvedTitleColor = titleColor ?? theme.colorScheme.onSurface;

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
              color: resolvedTitleColor,
            ),
          ),
        ),
      ],
    );
  }
}
