import 'package:flutter/material.dart';

import 'dart:async';
import 'package:intl/intl.dart';
class LakeMaritimeViewHeader extends StatefulWidget {
  final String nombreEmbarcacion;
  final String fecha;
  final String nombreResponsable;
  final String identificacion;
  final String imageUrl;

  const LakeMaritimeViewHeader({
    super.key,
    required this.nombreEmbarcacion,
    required this.fecha,
    required this.nombreResponsable,
    required this.identificacion,
    required this.imageUrl,
  });

  @override
  State<LakeMaritimeViewHeader> createState() => _LakeMaritimeViewHeaderState();
}

class _LakeMaritimeViewHeaderState extends State<LakeMaritimeViewHeader> {
  late String horaActual;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _actualizarHora();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _actualizarHora());
  }

  void _actualizarHora() {
    final now = DateTime.now();
    final formatted = DateFormat('hh:mm a').format(now); // ej: 04:52 PM
    setState(() {
      horaActual = formatted;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final imageSize = availableWidth * 0.15; // 15% para la imagen

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen circular
              ClipOval(
                child: Image.network(
                  widget.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nombreEmbarcacion.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _infoItem("FECHA", widget.fecha),
                        _infoItem("HORA", horaActual),
                        _infoItem("RESPONSABLE", widget.nombreResponsable),
                        _infoItem("IDENTIFICACION", widget.identificacion),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _infoItem(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
