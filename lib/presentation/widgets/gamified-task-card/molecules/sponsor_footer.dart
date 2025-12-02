import 'package:flutter/material.dart';

class SponsorFooter extends StatelessWidget {
  final String sponsor;
  final String sponsorTitle;

  final String endDate;
  final String endDateTitle;

  final VoidCallback? onSponsorTap;

  const SponsorFooter({
    super.key,
    required this.sponsor,
    required this.sponsorTitle,
    required this.endDateTitle,
    required this.endDate,
    this.onSponsorTap, // Nueva propiedad
  });

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8, // Espacio horizontal entre elementos
      runSpacing: 4, // Espacio vertical entre filas si se desborda
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          sponsorTitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        GestureDetector(
          onTap: onSponsorTap,
          child: Text(
            sponsor,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          endDateTitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          endDate,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
