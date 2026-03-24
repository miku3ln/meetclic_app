import 'package:flutter/material.dart';

import '../models/pos_product_item.dart';
import '../organisms/pos_search_overlay.dart';


class PosHeaderMobilePortraitLayout extends StatefulWidget
    implements PreferredSizeWidget {
  // ✅ (1) Product categories (dropdown)
  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  // top actions
  final VoidCallback onMenuTap;
  final void Function(BuildContext context, dynamic data) onUserTap;
  final VoidCallback onMoreTap;

  // ✅ (3) search
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const PosHeaderMobilePortraitLayout({
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
  State<PosHeaderMobilePortraitLayout> createState() =>
      _PosHeaderMobilePortraitLayoutState();
}

class _PosHeaderMobilePortraitLayoutState
    extends State<PosHeaderMobilePortraitLayout> {
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
    // ✅ fallback seguro si no hay categorías
    final hasCats = widget.productCategories.isNotEmpty;

    // ✅ Asegura que el value exista en los items (si no, usa el primero)
    String? safeSelectedId = widget.selectedProductCategoryId;
    if (hasCats) {
      final exists = widget.productCategories.any((c) => c.id == safeSelectedId);
      safeSelectedId = exists ? safeSelectedId : widget.productCategories.first.id;
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
          onPressed: ()=> widget.onUserTap(context, {
            "source": "header",
            "type": "create_user",
          }),
          icon: const Icon(Icons.person_add_alt_1),
        ),
        IconButton(
          onPressed: widget.onMoreTap,
          icon: const Icon(Icons.more_vert),
        ),
      ],
      title: Row(
        children: [
          // ✅ dropdown ocupa lo que pueda
          Expanded(
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
                      maxLines: 1,
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
                onChanged: hasCats ? widget.onProductCategoryChanged : null,
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