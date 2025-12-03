// presentation/pages/business_map_page/widgets/atoms/loading_overlay_atom.dart
import 'package:flutter/material.dart';

class LoadingOverlayAtom extends StatelessWidget {
  final bool isLoading;

  const LoadingOverlayAtom({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
