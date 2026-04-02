
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

enum AlertType { success, warning, error }

class PosAlertMessage extends StatefulWidget {
  final String message;
  final String? subtitle;
  final AlertType type;
  final Duration duration;
  final VoidCallback? onClose;

  const PosAlertMessage({
    super.key,
    required this.message,
    this.subtitle,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onClose,
  });

  @override
  State<PosAlertMessage> createState() => _PosAlertMessageState();
}

class _PosAlertMessageState extends State<PosAlertMessage> {
  @override
  void initState() {
    super.initState();

    /// 🔥 auto close
    Future.delayed(widget.duration, () {
      if (mounted) widget.onClose?.call();
    });
  }

  Color get bgColor {
    switch (widget.type) {
      case AlertType.success:
        return Colors.green.shade100;
      case AlertType.warning:
        return Colors.orange.shade100;
      case AlertType.error:
        return Colors.red.shade100;
    }
  }

  Color get borderColor {
    switch (widget.type) {
      case AlertType.success:
        return Colors.green;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.error:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.warning:
        return Icons.info;
      case AlertType.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor),
          const SizedBox(width: 10),

          /// TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.message,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (widget.subtitle != null)
                  Text(widget.subtitle!,
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          /// CERRAR
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }
}