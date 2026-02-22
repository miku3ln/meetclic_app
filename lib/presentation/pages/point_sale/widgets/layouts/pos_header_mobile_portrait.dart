import 'package:flutter/material.dart';
import '../organisms/pos_search_overlay.dart';

class PosHeaderMobilePortraitLayout extends StatefulWidget implements PreferredSizeWidget {
  final List<String> dropdownItems;
  final String selectedItem;

  final VoidCallback onMenuTap;
  final VoidCallback onUserTap;
  final VoidCallback onMoreTap;

  final ValueChanged<String?> onDropdownChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const PosHeaderMobilePortraitLayout({
    super.key,
    required this.dropdownItems,
    required this.selectedItem,
    required this.onMenuTap,
    required this.onUserTap,
    required this.onMoreTap,
    required this.onDropdownChanged,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<PosHeaderMobilePortraitLayout> createState() =>
      _PosHeaderMobilePortraitLayoutState();
}

class _PosHeaderMobilePortraitLayoutState extends State<PosHeaderMobilePortraitLayout> {
  final GlobalKey _searchKey = GlobalKey();
  bool _open = false;

  void _toggleSearch() {
    setState(() => _open = !_open);
    if (_open) {
      PosSearchOverlay.show(
        context: context,
        anchorKey: _searchKey,
        onClose: () => setState(() => _open = false),
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
      );
    } else {
      PosSearchOverlay.hide();
      widget.onSearchChanged?.call('');
    }
  }

  @override
  void dispose() {
    PosSearchOverlay.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: widget.onMenuTap,
        icon: const Icon(Icons.menu),
      ),
      actions: [
        IconButton(
          onPressed: widget.onUserTap,
          icon: const Icon(Icons.person_add_alt_1),
        ),
        IconButton(
          onPressed: widget.onMoreTap,
          icon: const Icon(Icons.more_vert),
        ),
      ],
        title: Row(
          children: [
            // ✅ dropdown ocupa lo que pueda, sin pasarse
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.selectedItem,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: widget.dropdownItems
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                      .toList(),
                  onChanged: widget.onDropdownChanged,
                ),
              ),
            ),

            // ✅ search siempre entra (ancho fijo)
            IconButton(
              key: _searchKey,
              onPressed: _toggleSearch,
              icon: Icon(_open ? Icons.close : Icons.search),
            ),
          ],
        ),

    );
  }
}
