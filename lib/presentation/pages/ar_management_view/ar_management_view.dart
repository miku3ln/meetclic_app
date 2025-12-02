// lib/features/ar_management_view/ar_management_view.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/totem_management.dart'; // ItemAR, itemsSources
import 'services/ar_config.dart';
import 'services/ar_service.dart';
import 'services/download_helper.dart';
import 'widgets/center_reticle.dart';
import 'widgets/info_card_ar.dart';

/// Estado de carga del AR
enum ARLoadStatus { idle, loading, success, error }

class ARManagementView extends StatefulWidget {
  const ARManagementView({super.key});

  @override
  State<ARManagementView> createState() => _ARManagementViewState();
}

class _ARManagementViewState extends State<ARManagementView> {
  // ===== Pinch-to-zoom (en % del base) con throttle =====
  static const Duration _kPinchThrottle = Duration(milliseconds: 80);
  bool _isPinching = false;
  double _pinchStartScale = ARConfig.uniformScale;
  bool _pinchTickScheduled = false;
  double? _pendingPercent;

  void _applyScalePercentThrottled(double percent) {
    _pendingPercent = percent;
    if (_pinchTickScheduled) return;
    _pinchTickScheduled = true;

    Future.delayed(_kPinchThrottle, () async {
      final val = _pendingPercent;
      _pendingPercent = null;
      _pinchTickScheduled = false;

      if (val != null && _ar.currentNode != null) {
        await _ar.setUniformScalePercent(val);
      }
    });
  }

  Future<void> _flushPinchPercent() async {
    final val = _pendingPercent;
    _pendingPercent = null;
    _pinchTickScheduled = false;
    if (val != null && _ar.currentNode != null) {
      await _ar.setUniformScalePercent(val);
    }
  }

  // ===== Captura =====
  bool _isCapturing = false;
  bool _hideUiDuringCapture = false;

  // ===== AR =====
  final ARService _ar = ARService();
  late ItemAR _selected;
  ARLoadStatus _status = ARLoadStatus.idle;
  String? _lastError;
  bool _showReticle = true;
  final GlobalKey _captureKey = GlobalKey();

  // ===== Descarga / Progreso / Reuso =====
  double _progress = 0.0; // 0..1
  bool _progressKnown = false; // t>0
  String? _lastLoadedPath; // opcional (hoy no-op para web)
  // Reuso explícito por modelo (clave = URL original del modelo)
  final Map<String, String> _resolvedPathsByUrl = {};

  @override
  void initState() {
    super.initState();
    _selected = itemsSources.first;
  }

  @override
  void dispose() {
    // Hoy no-op (por si luego usas blob: en web), mantenemos el patrón.
    DownloadHelper.revokeIfNeeded(_lastLoadedPath);
    _ar.dispose();
    super.dispose();
  }

  void _setStatus(ARLoadStatus s, {String? err}) {
    setState(() {
      _status = s;
      _lastError = err;
    });
  }

  // ===== ARView created =====
  Future<void> _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    try {
      await _ar.init(
        sessionManager: sessionManager,
        objectManager: objectManager,
      );
      UiHelpers.showSnack(context, 'AR inicializado');
    } catch (e) {
      _setStatus(ARLoadStatus.error, err: 'Fallo inicializando AR: $e');
      return;
    }
    setState(() => _showReticle = true);
  }

  // ===== Colocación con descarga/caché local (y reuso) =====
  Future<void> _onReticleTap() async {
    if (_status == ARLoadStatus.loading) return;

    _setStatus(ARLoadStatus.loading);
    _progress = 0;
    _progressKnown = false;

    UiHelpers.showSnack(context, 'Colocando: ${_selected.id}');

    Timer? _arLoadTimer;

    // ====================================================
    // Simulación del progreso durante la carga del ARView
    // ====================================================
    void startArProgressSimulation({double start = 0.0}) {
      double base = start.clamp(0.0, 1.0);
      _progressKnown = true;
      _progress = base;
      setState(() {});

      final stopwatch = Stopwatch()..start();
      const totalMs = 900;
      const tickMs = 60;

      _arLoadTimer?.cancel();
      _arLoadTimer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        final frac = (stopwatch.elapsedMilliseconds / totalMs).clamp(0.0, 0.95);
        setState(() {
          _progress = (base + (1.0 - base) * frac).clamp(0.0, 0.95);
        });
      });
    }

    Future<void> stopArProgressSimulation({required bool ok}) async {
      _arLoadTimer?.cancel();
      if (!mounted) return;

      setState(() {
        _progress = ok ? 1.0 : 0.0;
        _progressKnown = ok;
      });
    }

    try {
      final src = _selected.sources;

      // ============================================================
      // A) REUSO: ya está en cache / pool (sin descarga)
      // ============================================================
      if (src.loadedOnce && src.resolvedPath != null) {
        final resolved = src.resolvedPath!;

        // Simular carga AR 0→100%
        startArProgressSimulation(start: 0.0);

        final ok = await _ar.placeGlbInFront(
          url: resolved,
          isLocal: true,
          distanceMeters: ARConfig.distanceMeters,
          uniformScale: ARConfig.uniformScale,
          initialPreset: ARViewPreset.front,
        );

        await stopArProgressSimulation(ok: ok);

        if (ok) {
          setState(() {
            _showReticle = false;
          });
          _setStatus(ARLoadStatus.success);
          UiHelpers.showSnack(context, 'Usando archivo local cacheado');
          _lastLoadedPath = resolved;
          return;
        } else {
          src.resolvedPath = null;
          src.loadedOnce = false;
        }
      }

      // ============================================================
      // B) PRIMERA VEZ: descargar con progreso real
      // ============================================================
      String loadPath = src.glb;

      final res = await DownloadHelper.fetchToCacheVerbose(
        src.glb,
        onProgress: (received, total) {
          if (!mounted) return;

          src.setProgress(received, total > 0 ? total : null);

          setState(() {
            _progressKnown = total > 0;
            _progress = total > 0 ? (received / total) : 0.0;
          });
        },
      );

      if (!res.success || res.data == null) {
        _setStatus(ARLoadStatus.error, err: res.message);
        UiHelpers.showSnack(context, '❌ ${res.message}');
        return;
      }

      loadPath = res.data!;

      _lastLoadedPath = loadPath;

      // ============================================================
      // C) CARGA AR (simulación pequeña si descarga llegó rápido)
      // ============================================================
      if (_progress >= 0.99) {
        // Descarga terminó → falta carga AR
        startArProgressSimulation(start: _progress);
      }

      final ok = await _ar.placeGlbInFront(
        url: loadPath,
        isLocal: true,
        distanceMeters: ARConfig.distanceMeters,
        uniformScale: ARConfig.uniformScale,
        initialPreset: ARViewPreset.front,
      );

      await stopArProgressSimulation(ok: ok);

      if (ok) {
        src.sealAfterFirstLoad(loadPath);
        _setStatus(ARLoadStatus.success);
        setState(() => _showReticle = false);
      } else {
        _setStatus(ARLoadStatus.error, err: 'No se pudo añadir el nodo');
      }
    } catch (e) {
      _arLoadTimer?.cancel();
      _setStatus(ARLoadStatus.error, err: '$e');
    }
  }

  // ===== Cambio de item desde el dropdown =====
  Future<void> _onSelectChanged(ItemAR val) async {
    setState(() => _selected = val);
    _setStatus(ARLoadStatus.idle, err: null);

    // Ya NO removemos del mundo (queda en pool para reuso rápido)
    await _ar.removeCurrentNodeIfAny();

    setState(() {
      _showReticle = true;
      _progress = 0.0;
      _progressKnown = false;
    });

    // No elimines _metaByUrl aquí. Queremos que “loadedOnce/resolvedPath” persista.
    DownloadHelper.revokeIfNeeded(_lastLoadedPath); // hoy no-op
    _lastLoadedPath = null;

    UiHelpers.showSnack(
      context,
      'Seleccionado: ${_selected.id}. Toca la retícula para colocar.',
    );
  }

  // ===== Captura y guardado en galería (oculta InfoCard) =====
  Future<void> _captureAndSavePng() async {
    if (_isCapturing || _ar.currentNode == null) return;

    setState(() {
      _isCapturing = true;
      _hideUiDuringCapture = true;
    });

    try {
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final ctx = _captureKey.currentContext;
      if (ctx == null) throw Exception('Context nulo al capturar.');

      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary no encontrado.');

      // ignore: invalid_use_of_protected_member
      if (boundary.debugNeedsPaint) {
        await WidgetsBinding.instance.endOfFrame;
      }

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('No se pudo generar PNG.');

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final fileName =
          'ar_capture_${DateTime.now().millisecondsSinceEpoch}.png';
      await File('${dir.path}/$fileName').writeAsBytes(bytes);

      final res = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: fileName,
        quality: 100,
        isReturnImagePathOfIOS: true,
      );
      final ok = (res != null) && (res['isSuccess'] == true);
      if (!ok) throw Exception('Fallo al guardar en galería.');

      UiHelpers.showSnack(context, 'Captura guardada en Galería ✅');
    } catch (e) {
      UiHelpers.showSnack(context, 'Error al capturar: $e', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _hideUiDuringCapture = false;
        });
      }
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasModel = _ar.currentNode != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR – Sin hits (dropdown)'),
        actions: [
          IconButton(
            tooltip: 'Recolocar al frente',
            onPressed: () async {
              await _ar.recenterInFront();
              setState(() {});
            },
            icon: const Icon(Icons.center_focus_strong),
          ),
          PopupMenuButton<String>(
            tooltip: 'Vistas',
            onSelected: (k) async {
              switch (k) {
                case 'front':
                  await _ar.applyViewPreset(ARViewPreset.front);
                  break;
                case 'back':
                  await _ar.applyViewPreset(ARViewPreset.back);
                  break;
                case 'left':
                  await _ar.applyViewPreset(ARViewPreset.left);
                  break;
                case 'right':
                  await _ar.applyViewPreset(ARViewPreset.right);
                  break;
                case 'up':
                  await _ar.applyViewPreset(ARViewPreset.up);
                  break;
                case 'down':
                  await _ar.applyViewPreset(ARViewPreset.down);
                  break;
                case 'iso':
                  await _ar.applyViewPreset(ARViewPreset.isometric);
                  break;
                case 'face':
                  await _ar.applyViewPreset(ARViewPreset.faceCamera);
                  break;
              }
              setState(() {});
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'face', child: Text('Mirar a cámara')),
              PopupMenuItem(value: 'front', child: Text('Frontal')),
              PopupMenuItem(value: 'back', child: Text('Trasera')),
              PopupMenuItem(value: 'left', child: Text('Izquierda')),
              PopupMenuItem(value: 'right', child: Text('Derecha')),
              PopupMenuItem(value: 'up', child: Text('Arriba')),
              PopupMenuItem(value: 'down', child: Text('Abajo')),
              PopupMenuItem(value: 'iso', child: Text('Isométrica')),
            ],
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _captureKey,
        child: Stack(
          children: [
            // ARView envuelto en GestureDetector de pinch
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) {
                if (_ar.currentNode == null) return;
                _isPinching = true;
                _pinchStartScale = _ar.getCurrentUniformScale();
                _pendingPercent = null;
                _pinchTickScheduled = false;
              },
              onScaleUpdate: (details) {
                if (!_isPinching || _ar.currentNode == null) return;
                final targetUniform = _pinchStartScale * details.scale;
                final percent = (targetUniform / ARConfig.uniformScale) * 100.0;
                _applyScalePercentThrottled(percent);
              },
              onScaleEnd: (_) async {
                if (!_isPinching) return;
                _isPinching = false;
                await _flushPinchPercent();
              },
              child: ARView(
                onARViewCreated: _onARViewCreated,
                planeDetectionConfig: PlaneDetectionConfig.none,
              ),
            ),

            // Dropdown flotante arriba
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ItemAR>(
                      isExpanded: true,
                      value: _selected,
                      items: itemsSources.map((item) {
                        return DropdownMenuItem<ItemAR>(
                          value: item,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  item.sources.img,
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(
                                    width: 42,
                                    height: 42,
                                    child: Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        if (val == null) return;
                        await _onSelectChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Chip de estado (solo números durante carga)
            Positioned(
              right: 12,
              top: 12 + 56,
              child: Chip(
                label: Text(
                  _status == ARLoadStatus.loading
                      ? (_progressKnown
                            ? '${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                            : '0%') // sin Content-Length → 0%
                      : _status == ARLoadStatus.success
                      ? 'Listo'
                      : _status == ARLoadStatus.error
                      ? 'Error'
                      : 'Listo',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _status == ARLoadStatus.loading
                    ? Colors.amber[700]
                    : _status == ARLoadStatus.success
                    ? Colors.green[700]
                    : _status == ARLoadStatus.error
                    ? Colors.red[700]
                    : Colors.blueGrey[600],
              ),
            ),

            // Overlay de carga (solo número grande)
            if (_status == ARLoadStatus.loading)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: _LoadingOverlay(
                      progress: _progress, // 0..1
                      progressKnown:
                          _progressKnown, // true si hay Content-Length
                    ),
                  ),
                ),
              ),

            // Retícula centrada para colocar
            if (_showReticle) const CenterReticle(),

            // InfoCard + acciones (oculta durante la captura)
            if (!_hideUiDuringCapture)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: InfoCardAR(
                  item: _selected,
                  lastError: _lastError,
                  onCapturePressed: hasModel ? _captureAndSavePng : null,
                  onYawLeft: hasModel
                      ? () async => {_ar.nudgeXawDegrees(-8)}
                      : null,
                  onYawRight: hasModel
                      ? () async => {_ar.nudgeXawDegrees(8)}
                      : null,
                ),
              ),

            // Tap exacto en retícula para colocar el modelo
            if (_showReticle)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _onReticleTap,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ====== Widgets internos ======

class _LoadingOverlay extends StatelessWidget {
  final double progress; // 0..1
  final bool progressKnown; // true si hay Content-Length

  const _LoadingOverlay({
    super.key,
    required this.progress,
    required this.progressKnown,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay tamaño del servidor: 0%. Si hay, usamos progress*100.
    final pctText = progressKnown
        ? '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : '0%';

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        pctText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 56,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
