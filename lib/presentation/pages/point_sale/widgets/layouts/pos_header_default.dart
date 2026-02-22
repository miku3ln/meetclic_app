import 'package:flutter/material.dart';
import '../organisms/pos_search_overlay.dart';

class PosHeaderDefaultLayout extends StatefulWidget implements PreferredSizeWidget {
  final List<String> dropdownItems;
  final String selectedItem;

  final VoidCallback onMenuTap;
  final VoidCallback onUserTap;
  final VoidCallback onMoreTap;

  final ValueChanged<String?> onDropdownChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const PosHeaderDefaultLayout({
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
  State<PosHeaderDefaultLayout> createState() => _PosHeaderDefaultLayoutState();
}

class _PosHeaderDefaultLayoutState extends State<PosHeaderDefaultLayout> {
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
    final w = MediaQuery.of(context).size.width;
    final dropdownMax = (w < 600) ? 220.0 : 340.0;

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
          // IZQUIERDA: “Todos los artículos” + dropdown
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dropdownMax),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedItem,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: widget.dropdownItems
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ))
                    .toList(),
                onChanged: widget.onDropdownChanged,
              ),
            ),
          ),

          const Spacer(),

          // IZQUIERDA (antes de Ticket): 🔍 search
          IconButton(
            key: _searchKey,
            onPressed: _toggleSearch,
            icon: Icon(_open ? Icons.close : Icons.search),
          ),

          const SizedBox(width: 10),

          // DERECHA: Ticket
          const Text('Ticket', maxLines: 1, overflow: TextOverflow.ellipsis),

          const Spacer(),
        ],
      ),
    );
  }
}
