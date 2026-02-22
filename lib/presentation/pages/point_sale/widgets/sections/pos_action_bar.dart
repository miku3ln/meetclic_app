import 'package:flutter/material.dart';
import '../models/pos_action_item.dart';

class PosActionBar extends StatelessWidget {
  // ✅ Menu categories (bottom bar)
  final List<PosMenuActionItem> menuCategories;
  final String? selectedMenuCategoryId;
  final ValueChanged<String> onMenuCategoryTap;

  // Derecha (fijo)
  final VoidCallback onSave;
  final VoidCallback onPay;

  // Config
  final double height;
  final double rightWidth;
  final EdgeInsets padding;

  const PosActionBar({
    super.key,
    required this.menuCategories,
    required this.selectedMenuCategoryId,
    required this.onMenuCategoryTap,
    required this.onSave,
    required this.onPay,
    this.height = 84,
    this.rightWidth = 360,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              // LEFT: menú inferior (scroll horizontal)
              Expanded(
                child: _MenuCarousel(
                  items: menuCategories,
                  selectedId: selectedMenuCategoryId,
                  onTap: onMenuCategoryTap,
                ),
              ),

              const SizedBox(width: 12),
              const VerticalDivider(width: 1),
              const SizedBox(width: 12),

              // RIGHT: fijo (2 columnas)
              SizedBox(
                width: rightWidth,
                child: _RightFixedActions(
                  onSave: onSave,
                  onPay: onPay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCarousel extends StatelessWidget {
  final List<PosMenuActionItem> items;
  final String? selectedId;
  final ValueChanged<String> onTap;

  const _MenuCarousel({
    required this.items,
    required this.selectedId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Scrollbar(
      thumbVisibility: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((a) {
            final bool isActive = a.id == selectedId;

            // opcional: “grid” como botón especial (toggle)
            final bool isGrid = a.id == 'grid';

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _ChipButton(
                label: a.value,
                enabled: a.enabled,
                active: isActive,
                compact: isGrid,
                onTap: a.enabled ? () => onTap(a.id) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool active;

  /// opcional para el botón grid (más compacto)
  final bool compact;

  const _ChipButton({
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
      onPressed: onTap,
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

class _RightFixedActions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onPay;

  const _RightFixedActions({
    required this.onSave,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('GUARDAR'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('COBRAR'),
          ),
        ),
      ],
    );
  }
}