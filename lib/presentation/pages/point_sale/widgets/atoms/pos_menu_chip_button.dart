import 'package:flutter/material.dart';

class PosMenuChipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool active;
  final bool compact;

  const PosMenuChipButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.active,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: active ? cs.primary : Colors.black26),
        foregroundColor: active ? cs.primary : Colors.black87,
        backgroundColor: active ? cs.primary.withOpacity(0.08) : null,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}