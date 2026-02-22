import 'package:flutter/material.dart';

class PosSearchOverlay {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required VoidCallback onClose,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    hide();

    final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final iconOffset = renderBox.localToGlobal(Offset.zero);
    final iconSize = renderBox.size;
    final screenW = MediaQuery.of(context).size.width;

    const margin = 12.0;
    final left = margin;
    final right = screenW - (iconOffset.dx + iconSize.width) + margin;
    final top = iconOffset.dy + iconSize.height + 8;

    final ctrl = TextEditingController();
    final focus = FocusNode();

    _entry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  onChanged?.call('');
                  onClose();
                  hide();
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              right: right,
              top: top,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          focusNode: focus,
                          decoration: const InputDecoration(
                            hintText: 'Buscar...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          textInputAction: TextInputAction.search,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ctrl.clear();
                          onChanged?.call('');
                          onClose();
                          hide();
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    WidgetsBinding.instance.addPostFrameCallback((_) => focus.requestFocus());
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
