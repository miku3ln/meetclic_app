import 'package:flutter/material.dart';

import '../../models/search_location_info_model.dart';

/// --------------------------------------------------------------
/// Pantalla detallada al expandir la card (full screen)
/// --------------------------------------------------------------
class SearchLocationDetailOrganism extends StatelessWidget {
  final SearchLocationInfoModel info;
  final VoidCallback onClose;

  const SearchLocationDetailOrganism({
    required this.info,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final street = info.street ?? 'Dirección no disponible';
    final city = info.city ?? '-';
    final state = info.state ?? '-';
    final country = info.country ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de búsqueda'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Punto actual de búsqueda',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              street,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text('$city, $state, $country', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(
              'Coordenadas',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Latitud:  ${info.latitude.toStringAsFixed(6)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Longitud: ${info.longitude.toStringAsFixed(6)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Desde este punto se buscarán negocios dentro del radio que selecciones en los filtros.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
