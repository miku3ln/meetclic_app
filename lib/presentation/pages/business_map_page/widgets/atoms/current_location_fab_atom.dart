// presentation/pages/business_map_page/widgets/atoms/current_location_fab_atom.dart
import 'package:flutter/material.dart';

class CurrentLocationFabAtom extends StatelessWidget {
  final bool isLoading;
  final bool isGpsEnabled;
  final VoidCallback? onPressed;

  const CurrentLocationFabAtom({
    super.key,
    required this.isLoading,
    required this.isGpsEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      backgroundColor: theme.colorScheme.primary,
      onPressed: isLoading ? null : onPressed,
      tooltip: isGpsEnabled ? 'Ubicación actual' : 'GPS desactivado',
      child: Icon(isGpsEnabled ? Icons.my_location : Icons.location_off),
    );
  }
}
