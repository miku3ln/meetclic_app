import 'package:flutter/material.dart';
import '../models/pos_product_item.dart';
import '../organisms/pos_search_overlay.dart';


class PosHeaderDefaultLayout extends StatefulWidget
    implements PreferredSizeWidget {
  // ✅ (1) Product categories (dropdown)
  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  // top actions
  final VoidCallback onMenuTap;
  final VoidCallback onUserTap;
  final VoidCallback onMoreTap;

  // ✅ (3) search
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const PosHeaderDefaultLayout({
    super.key,
    required this.productCategories,
    required this.selectedProductCategoryId,
    required this.onProductCategoryChanged,
    required this.onMenuTap,
    required this.onUserTap,
    required this.onMoreTap,
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

    final hasCats = widget.productCategories.isNotEmpty;

    // ✅ asegura que el selected exista dentro de los items
    String? safeSelectedId = widget.selectedProductCategoryId;
    if (hasCats) {
      final exists =
      widget.productCategories.any((c) => c.id == safeSelectedId);
      safeSelectedId =
      exists ? safeSelectedId : widget.productCategories.first.id;
    } else {
      safeSelectedId = null;
    }

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
          // IZQUIERDA: dropdown (categorías de producto)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dropdownMax),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeSelectedId,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: hasCats
                    ? widget.productCategories
                    .map(
                      (c) => DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(
                      c.value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                    .toList()
                    : const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sin categorías'),
                  ),
                ],
                onChanged:
                hasCats ? widget.onProductCategoryChanged : null,
              ),
            ),
          ),

          const Spacer(),

          // 🔍 Search
          IconButton(
            key: _searchKey,
            onPressed: _toggleSearch,
            icon: Icon(_open ? Icons.close : Icons.search),
          ),

          const SizedBox(width: 10),
          // DERECHA: Ticket (placeholder como antes)
          const Text('Tickets', maxLines: 1, overflow: TextOverflow.ellipsis),

          const Spacer(),
        ],
      ),
    );
  }
}