import 'package:flutter/material.dart';

class AvatarCard extends StatelessWidget {
  final double width;
  final double height;
  final Color? backgroundColor; // opcional si se usa gradient
  final Gradient? gradient; // nuevo parámetro opcional
  final ImageProvider image;
  final VoidCallback onSettingsTap;

  const AvatarCard({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.backgroundColor, // opcional
    this.gradient, // opcional
    required this.image,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con imagen y decoración
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: gradient == null
                ? backgroundColor
                : null, // solo si no hay gradient
            gradient: gradient, // si se pasa, se usa
            image: DecorationImage(
              image: image,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        // Botón de configuración flotante
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 20, color: Colors.black),
              onPressed: onSettingsTap,
              tooltip: 'Configuración',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
