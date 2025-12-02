// lib/ar/preview/widgets/glb_preview_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:model_viewer_plus/model_viewer_plus.dart';

class GlbPreviewView extends StatefulWidget {
  /// Ej: 'assets/totems/examples/mikasa/gothic__elegance_texture_anime_girl.glb'
  final String uri;
  final bool isLocal;

  /// Opcional: por si necesitas inyectar algo (no se usa aquí)
  final dynamic controller;

  const GlbPreviewView({
    super.key,
    required this.uri,
    required this.isLocal,
    this.controller,
  });

  @override
  State<GlbPreviewView> createState() => _GlbPreviewViewState();
}

class _GlbPreviewViewState extends State<GlbPreviewView> {
  String? _error;

  Future<void> _assertLocalAssetExists() async {
    if (!widget.isLocal) return;
    try {
      // Verifica que el asset exista EXACTAMENTE con esa ruta declarada en pubspec.yaml
      await rootBundle.load(widget.uri);
      debugPrint(
        '[GlbPreviewView] Asset OK---------------------------------------------: ${widget.uri}',
      );
    } catch (e) {
      final msg =
          'Asset no encontrado o inaccesible ------------------------------------- :: ${widget.uri}\n$e';
      debugPrint('[GlbPreviewView] $msg');
      setState(() => _error = msg);
    }
  }

  @override
  void initState() {
    super.initState();
    // Chequea el asset en el primer frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _assertLocalAssetExists(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final src =
        widget.uri; // Para locales: la ruta exacta del pubspec, no 'asset:///'
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint(
          '[GlbPreviewView] constraints -> '
          'w=${constraints.maxWidth}, h=${constraints.maxHeight}, src=$src, isLocal=${widget.isLocal}',
        );

        return Stack(
          children: [
            // Lienzo 3D ocupando toda el área disponible
            ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(
                child: ModelViewer(
                  key: ValueKey(src),
                  src: src,
                  alt: 'GLB preview',
                  ar: false,
                  autoRotate: false,
                  cameraControls: true,
                  shadowIntensity: 1.0,
                  // Opcional: prueba un orbit para ver mejor el modelo
                  // cameraOrbit: '0deg 75deg 2.0m',
                  // fieldOfView: '45deg',
                  // backgroundColor: Colors.black, // si usas la prop nueva del plugin
                ),
              ),
            ),

            // Overlay de error (asset faltante o diagnóstico manual)
            if (_error != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No se pudo renderizar el modelo.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
