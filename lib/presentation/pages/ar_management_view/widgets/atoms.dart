import 'dart:async';

import 'package:flutter/material.dart';

class ARIconCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Opcional: ajusta la sensación del “hold-to-repeat”
  final Duration initialDelay; // pausa antes de empezar a repetir
  final Duration repeatInterval; // intervalo entre repeticiones

  const ARIconCircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.initialDelay = const Duration(milliseconds: 300),
    this.repeatInterval = const Duration(milliseconds: 90),
  });

  @override
  State<ARIconCircleButton> createState() => _ARIconCircleButtonState();
}

class _ARIconCircleButtonState extends State<ARIconCircleButton> {
  Timer? _delayTimer;
  Timer? _repeatTimer;

  void _startRepeat() {
    if (widget.onPressed == null) return;
    _stopRepeat(); // limpieza por si acaso
    _delayTimer = Timer(widget.initialDelay, () {
      _repeatTimer = Timer.periodic(widget.repeatInterval, (_) {
        widget.onPressed?.call();
      });
    });
  }

  void _stopRepeat() {
    _delayTimer?.cancel();
    _repeatTimer?.cancel();
    _delayTimer = null;
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final core = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(14),
        backgroundColor: Colors.black.withOpacity(0.40),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      // Toque corto => 1 vez
      onPressed: widget.onPressed,
      child: Icon(widget.icon, size: 22),
    );

    // Envolvemos para detectar inicio/fin del long-press y repetir
    final wrapped = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _startRepeat(),
      onLongPressEnd: (_) => _stopRepeat(),
      child: core,
    );

    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: wrapped)
        : wrapped;
  }
}
