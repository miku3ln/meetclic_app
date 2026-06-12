import 'package:flutter/material.dart';
enum AlertPosition {
  top,
  center,
  bottom,
}


class AlertService {
  static OverlayEntry? _currentAlert;

  static void show(
      BuildContext context, {
        String message = 'Operación realizada correctamente',
        Duration duration = const Duration(seconds: 3),
        AlertPosition position = AlertPosition.top,
        IconData? icon,
        Color? backgroundColor,
        Color textColor = Colors.white,
      }) {
    _currentAlert?.remove();

    final overlay = Overlay.of(context);

    final bgColor = backgroundColor ?? Colors.black87;
    final alertIcon = icon ?? Icons.info_outline;

    _currentAlert = OverlayEntry(
      builder: (_) => _AlertWidget(
        message: message,
        duration: duration,
        position: position,
        icon: alertIcon,
        backgroundColor: bgColor,
        textColor: textColor,
      ),
    );

    overlay.insert(_currentAlert!);

    Future.delayed(duration, () {
      _currentAlert?.remove();
      _currentAlert = null;
    });
  }

  static void success(
      BuildContext context, {
        String message = 'Operación realizada correctamente',
        AlertPosition position = AlertPosition.top,
      }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
    );
  }

  static void error(
      BuildContext context, {
        String message = 'Ocurrió un error',
        AlertPosition position = AlertPosition.top,
      }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.error,
      backgroundColor: Colors.red,
    );
  }

  static void warning(
      BuildContext context, {
        String message = 'Advertencia',
        AlertPosition position = AlertPosition.top,
      }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.warning_amber,
      backgroundColor: Colors.orange,
    );
  }

  static void info(
      BuildContext context, {
        String message = 'Información',
        AlertPosition position = AlertPosition.top,
      }) {
    show(
      context,
      message: message,
      position: position,
      icon: Icons.info,
      backgroundColor: Colors.blue,
    );
  }
}
class _AlertWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final AlertPosition position;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const _AlertWidget({
    required this.message,
    required this.duration,
    required this.position,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  State<_AlertWidget> createState() => _AlertWidgetState();
}

class _AlertWidgetState extends State<_AlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(controller);

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    double? top;
    double? bottom;

    switch (widget.position) {
      case AlertPosition.top:
        top = 40;
        break;

      case AlertPosition.center:
        top = MediaQuery.of(context).size.height * .45;
        break;

      case AlertPosition.bottom:
        bottom = 40;
        break;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: opacity,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.textColor,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}