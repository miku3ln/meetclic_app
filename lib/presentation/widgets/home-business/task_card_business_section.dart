import 'package:flutter/material.dart';

class TaskCardBusiness extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double percent;
  final Color accentColor;

  const TaskCardBusiness({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Contenedor blanco principal
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16), // espacio arriba para ícono
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),

              // Subtítulo
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),

              // Progreso con porcentaje
              Row(
                children: [
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percent,
                      color: accentColor,
                      backgroundColor: accentColor.withOpacity(0.2),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Ícono en la parte superior izquierda
        Positioned(
          top: -10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
        ),

        // Esquina inferior derecha decorada con check
        Positioned(
          bottom: 0,
          right: 0,
          child: ClipPath(
            clipper: BottomRightClipper(),
            child: Container(
              width: 28,
              height: 28,
              color: accentColor,
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 8, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
