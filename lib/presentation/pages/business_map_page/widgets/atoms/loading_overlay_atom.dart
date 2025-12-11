import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/themes/app_colors.dart';

import '../../../../../infrastructure/assets/app_images.dart';

enum LoadingOverlayType { circular, image }

class LoadingOverlayAtom extends StatefulWidget {
  final bool isLoading;

  /// Tipo de contenido a mostrar en el centro
  final LoadingOverlayType type;

  /// Ruta del asset de imagen cuando [type] == LoadingOverlayType.image
  final String? imageAssetPath;

  /// Color de fondo del overlay (por defecto blanco translúcido)
  final Color backgroundColor;

  const LoadingOverlayAtom({
    super.key,
    required this.isLoading,
    this.type = LoadingOverlayType.image, // por defecto circular
    this.imageAssetPath = AppImages.splashBackground,
    this.backgroundColor = const Color(0x1AFFFFFF), // blanco 70% opacidad
  });

  @override
  State<LoadingOverlayAtom> createState() => _LoadingOverlayAtomState();
}

class _LoadingOverlayAtomState extends State<LoadingOverlayAtom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _stepOpacity; // 1..10

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true); // sube 1→10 y baja 10→1 en bucle

    _stepOpacity = StepTween(begin: 1, end: 10).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant LoadingOverlayAtom oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si deja de estar en loading, paramos la animación
    if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }

    // Si entra en loading de nuevo, reanudamos
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCenterContent() {
    switch (widget.type) {
      case LoadingOverlayType.circular:
        return const CircularProgressIndicator(color: AppColors.amarilloVital);

      case LoadingOverlayType.image:
        if (widget.imageAssetPath != null &&
            widget.imageAssetPath!.isNotEmpty) {
          // Usamos AnimatedBuilder para recalcular opacidad por “pasos”
          return AnimatedBuilder(
            animation: _stepOpacity,
            builder: (context, child) {
              final opacity = _stepOpacity.value / 10.0; // 0.1, 0.2...1.0
              return Opacity(opacity: opacity, child: child);
            },
            child: Image.asset(
              widget.imageAssetPath!,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          );
        } else {
          return const CircularProgressIndicator(
            color: AppColors.amarilloVital,
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();

    return Container(
      color: widget.backgroundColor,
      child: Center(child: _buildCenterContent()),
    );
  }
}
