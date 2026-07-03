import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/pos_main_controller.dart';
import '../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../home/modals/show_register_user.dart';
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
  final void Function(BuildContext context, dynamic data) onUserTap;
  final void Function(BuildContext context, dynamic data) onMoreTap;

  // ✅ (3) search
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final PosMainController controllerMain;

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
    required this.controllerMain,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<PosHeaderDefaultLayout> createState() => _PosHeaderDefaultLayoutState();
}

class _PosHeaderDefaultLayoutState extends State<PosHeaderDefaultLayout> {

  String? selectedProductCategoryId;
  String query = '';
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

  Future<void> initDataPointOfSales( ) async {
    await widget.controllerMain.initDataPointOfSales();
  }



  @override
  void initState() {
    super.initState();
    //initControllerMain();
  }

  @override
  void dispose() {
    PosSearchOverlay.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = AppThemeTokens.of(context);
    final colorHeader = colors.primary;
    final dropdownMax = (w < 600) ? 220.0 : 340.0;
    final hasCats = widget.productCategories.isNotEmpty;
    // ✅ asegura que el selected exista dentro de los items
    String? safeSelectedId = widget.selectedProductCategoryId;
    if (hasCats) {
      final exists = widget.productCategories.any(
        (c) => c.id == safeSelectedId,
      );
      safeSelectedId = exists
          ? safeSelectedId
          : widget.productCategories.first.id;
    } else {
      safeSelectedId = null;
    }
    bool isAddCustomer = widget.controllerMain.selectedCustomer == null
        ? true
        : false;

    String fullName = !isAddCustomer
        ? widget.controllerMain.selectedCustomer!.name
        : "";
    return AppBar(
      backgroundColor: colorHeader,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: widget.onMenuTap,
        icon: Icon(Icons.menu, color: colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () => widget.onUserTap(context, {
            "source": "header",
            "type": isAddCustomer ? "create_user" : "update_user",
          }),
          icon: isAddCustomer
              ? Icon(Icons.person_add_alt_1, color: colors.white)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        color: colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.quick_contacts_mail_outlined,
                      color: colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),
        IconButton(
          onPressed: () =>
              widget.onMoreTap(context, {"source": "header", "type": ""}),
          icon: Icon(Icons.more_vert, color: colors.white),
        ),
      ],
      title: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dropdownMax),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.white, // Azul de la marca
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.white),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: safeSelectedId,
                  isExpanded: true,
                  style: Theme.of(context).textTheme.bodyMedium!.merge(
                    AppStyles.labelDropdownByPrimary,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: colors.primary),
                  items: hasCats
                      ? widget.productCategories
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(
                                  c.value,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .merge(
                                        AppStyles.labelDropdownItemByPrimary,
                                      ),
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
          ),

          // IZQUIERDA: dropdown (categorías de producto)
          const Spacer(),
          // 🔍 Search
          IconButton(
            key: _searchKey,
            onPressed: _toggleSearch,
            icon: Icon(_open ? Icons.close : Icons.search, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Actualizar información',
            onPressed: () async {
              // Capturas el evento aquí
              await initDataPointOfSales();
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          // DERECHA: Ticket (placeholder como antes)
          Text(
            widget.controllerMain.labels.ticket,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.textTitleMainPrimary,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
