import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/pos_main_controller.dart';
import '../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../home/modals/show_register_user.dart';
import '../models/pos_product_item.dart';
import '../organisms/pos_search_overlay.dart';
class PosHeaderDefaultLayout extends StatefulWidget
    implements PreferredSizeWidget {

  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  final VoidCallback onMenuTap;
  final void Function(BuildContext context, dynamic data) onUserTap;
  final void Function(BuildContext context, dynamic data) onMoreTap;

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
  State<PosHeaderDefaultLayout> createState() =>
      _PosHeaderDefaultLayoutState();
}

class _PosHeaderDefaultLayoutState
    extends State<PosHeaderDefaultLayout> {

  final GlobalKey _searchKey = GlobalKey();

  bool _open = false;

  bool get isMobile =>
      MediaQuery.sizeOf(context).width < 600;

  void _toggleSearch() {
    setState(() {
      _open = !_open;
    });

    if (_open) {
      PosSearchOverlay.show(
        context: context,
        anchorKey: _searchKey,
        onClose: () {
          if (!mounted) return;

          setState(() {
            _open = false;
          });
        },
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
      );
    } else {
      PosSearchOverlay.hide();
      widget.onSearchChanged?.call('');
    }
  }

  Future<void> _refresh() async {
    await widget.controllerMain.initDataPointOfSales();
  }

  @override
  void dispose() {
    PosSearchOverlay.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return PosHeaderMobile(
        productCategories: widget.productCategories,
        selectedProductCategoryId:
        widget.selectedProductCategoryId,
        onProductCategoryChanged:
        widget.onProductCategoryChanged,
        onMenuTap: widget.onMenuTap,
        onUserTap: widget.onUserTap,
        onMoreTap: widget.onMoreTap,
        onSearchTap: _toggleSearch,
        searchKey: _searchKey,
        searchOpen: _open,
        controllerMain: widget.controllerMain,
      );
    }

    return PosHeaderTablet(
      productCategories: widget.productCategories,
      selectedProductCategoryId:
      widget.selectedProductCategoryId,
      onProductCategoryChanged:
      widget.onProductCategoryChanged,
      onMenuTap: widget.onMenuTap,
      onUserTap: widget.onUserTap,
      onMoreTap: widget.onMoreTap,
      onSearchTap: _toggleSearch,
      searchKey: _searchKey,
      searchOpen: _open,
      onRefresh: _refresh,
      controllerMain: widget.controllerMain,
    );
  }
}
class PosHeaderMobile extends StatelessWidget {

  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  final VoidCallback onMenuTap;
  final void Function(BuildContext context, dynamic data) onUserTap;
  final void Function(BuildContext context, dynamic data) onMoreTap;

  final VoidCallback onSearchTap;
  final GlobalKey searchKey;
  final bool searchOpen;

  final PosMainController controllerMain;

  const PosHeaderMobile({
    super.key,
    required this.productCategories,
    required this.selectedProductCategoryId,
    required this.onProductCategoryChanged,
    required this.onMenuTap,
    required this.onUserTap,
    required this.onMoreTap,
    required this.onSearchTap,
    required this.searchKey,
    required this.searchOpen,
    required this.controllerMain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    final hasCategories =
        productCategories.isNotEmpty;

    String? selectedId =
        selectedProductCategoryId;

    if (hasCategories) {
      final exists = productCategories.any(
            (item) => item.id == selectedId,
      );

      if (!exists) {
        selectedId =
            productCategories.first.id;
      }
    } else {
      selectedId = null;
    }

    final customer =
        controllerMain.selectedCustomer;

    final isAddCustomer =
        customer == null;

    return AppBar(
      backgroundColor: colors.primary,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,

      leading: IconButton(
        tooltip: 'Menú',
        onPressed: onMenuTap,
        icon: Icon(
          Icons.menu,
          color: colors.white,
        ),
      ),

      title: Row(
        children: [

          Expanded(
            child: PosHeaderCategory(
              productCategories: productCategories,
              selectedProductCategoryId: selectedId,
              onProductCategoryChanged:
              onProductCategoryChanged,
            ),
          ),

          PosHeaderSearchButton(
            searchKey: searchKey,
            open: searchOpen,
            onTap: onSearchTap,
          ),
        ],
      ),

      actions: [

        PosHeaderCustomerButton(
          isAddCustomer: isAddCustomer,
          customerName: customer?.name,
          showName: false,
          onTap: () {
            onUserTap(
              context,
              {
                "source": "header",
                "type": isAddCustomer
                    ? "create_user"
                    : "update_user",
              },
            );
          },
        ),

        PosHeaderMoreButton(
          onTap: () {
            onMoreTap(
              context,
              {
                "source": "header",
                "type": "",
              },
            );
          },
        ),
      ],
    );
  }
}
class PosHeaderTablet extends StatelessWidget {

  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  final VoidCallback onMenuTap;
  final void Function(BuildContext context, dynamic data) onUserTap;
  final void Function(BuildContext context, dynamic data) onMoreTap;

  final VoidCallback onSearchTap;
  final GlobalKey searchKey;
  final bool searchOpen;

  final VoidCallback onRefresh;

  final PosMainController controllerMain;

  const PosHeaderTablet({
    super.key,
    required this.productCategories,
    required this.selectedProductCategoryId,
    required this.onProductCategoryChanged,
    required this.onMenuTap,
    required this.onUserTap,
    required this.onMoreTap,
    required this.onSearchTap,
    required this.searchKey,
    required this.searchOpen,
    required this.onRefresh,
    required this.controllerMain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    final hasCategories =
        productCategories.isNotEmpty;

    String? selectedId =
        selectedProductCategoryId;

    if (hasCategories) {
      final exists = productCategories.any(
            (item) => item.id == selectedId,
      );

      if (!exists) {
        selectedId =
            productCategories.first.id;
      }
    } else {
      selectedId = null;
    }

    final customer =
        controllerMain.selectedCustomer;

    final isAddCustomer =
        customer == null;

    return AppBar(
      backgroundColor: colors.primary,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,

      leading: IconButton(
        tooltip: 'Menú',
        onPressed: onMenuTap,
        icon: Icon(
          Icons.menu,
          color: colors.white,
        ),
      ),

      title: Row(
        children: [

          // CATEGORÍA
          Expanded(
            flex: 3,
            child: PosHeaderCategory(
              productCategories:
              productCategories,
              selectedProductCategoryId:
              selectedId,
              onProductCategoryChanged:
              onProductCategoryChanged,
            ),
          ),

          // SEARCH
          PosHeaderSearchButton(
            searchKey: searchKey,
            open: searchOpen,
            onTap: onSearchTap,
          ),

          // REFRESH
          PosHeaderRefreshButton(
            onTap: onRefresh,
          ),

          // TICKET
          Expanded(
            flex: 2,
            child: PosHeaderTicket(
              text: controllerMain.labels.ticket,
            ),
          ),
        ],
      ),

      actions: [

        PosHeaderCustomerButton(
          isAddCustomer: isAddCustomer,
          customerName: customer?.name,
          showName: true,
          onTap: () {
            onUserTap(
              context,
              {
                "source": "header",
                "type": isAddCustomer
                    ? "create_user"
                    : "update_user",
              },
            );
          },
        ),

        PosHeaderMoreButton(
          onTap: () {
            onMoreTap(
              context,
              {
                "source": "header",
                "type": "",
              },
            );
          },
        ),
      ],
    );
  }
}
class PosHeaderCategory extends StatelessWidget {

  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  const PosHeaderCategory({
    super.key,
    required this.productCategories,
    required this.selectedProductCategoryId,
    required this.onProductCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    final hasCategories =
        productCategories.isNotEmpty;

    return Container(
      height: 42,
      margin: const EdgeInsets.only(
        left: 4,
        right: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
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
          value: selectedProductCategoryId,
          isExpanded: true,
          isDense: true,

          icon: Icon(
            Icons.arrow_drop_down,
            color: colors.primary,
          ),

          items: hasCategories
              ? productCategories.map(
                (category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(
                  category.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .merge(
                    AppStyles
                        .labelDropdownItemByPrimary,
                  ),
                ),
              );
            },
          ).toList()
              : const [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Sin categorías',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          onChanged: hasCategories
              ? onProductCategoryChanged
              : null,
        ),
      ),
    );
  }
}
class PosHeaderSearchButton extends StatelessWidget {

  final GlobalKey searchKey;
  final bool open;
  final VoidCallback onTap;

  const PosHeaderSearchButton({
    super.key,
    required this.searchKey,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: searchKey,
      tooltip: open
          ? 'Cerrar búsqueda'
          : 'Buscar producto',
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(
        open
            ? Icons.close
            : Icons.search,
        color: Colors.white,
      ),
    );
  }
}
class PosHeaderRefreshButton extends StatelessWidget {

  final VoidCallback onTap;

  const PosHeaderRefreshButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Actualizar información',
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: const Icon(
        Icons.refresh_rounded,
        color: Colors.white,
      ),
    );
  }
}
class PosHeaderTicket extends StatelessWidget {

  final String text;

  const PosHeaderTicket({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: AppStyles.textTitleMainPrimary,
      ),
    );
  }
}
class PosHeaderCustomerButton extends StatelessWidget {

  final bool isAddCustomer;
  final String? customerName;
  final bool showName;
  final VoidCallback onTap;

  const PosHeaderCustomerButton({
    super.key,
    required this.isAddCustomer,
    required this.customerName,
    required this.showName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    if (!showName) {
      return IconButton(
        tooltip: isAddCustomer
            ? 'Agregar cliente'
            : customerName ?? 'Cliente',
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(
          isAddCustomer
              ? Icons.person_add_alt_1
              : Icons.quick_contacts_mail_outlined,
          color: colors.white,
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (!isAddCustomer &&
                customerName != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 100,
                ),
                child: Text(
                  customerName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            Icon(
              isAddCustomer
                  ? Icons.person_add_alt_1
                  : Icons.quick_contacts_mail_outlined,
              color: colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
class PosHeaderMoreButton extends StatelessWidget {

  final VoidCallback onTap;

  const PosHeaderMoreButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Más opciones',
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
    );
  }
}