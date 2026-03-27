import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../dialogs/pos_open_shift_dialog.dart';
import '../models/pos_product_item.dart';
import '../organisms/pos_search_overlay.dart';
import 'package:provider/provider.dart';

class PosHeaderDefaultLayout extends StatefulWidget
    implements PreferredSizeWidget {
  // ✅ (1) Product categories (dropdown)
  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  // top actions
  final VoidCallback onMenuTap;
  final void Function(BuildContext context, dynamic data) onUserTap;
  final void Function(BuildContext context, dynamic data)  onMoreTap;

  // ✅ (3) search
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final PosTabletLandscapeController controllerMain;

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
  late final PosTabletLandscapeController controller;
  late final List<PosCategoryItem> productCategories;
  String? selectedProductCategoryId;
  String query = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅
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
  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }
  // ✅ Modal vive aquí
  Future<void> _showOpenShiftModal() async {
    final opened = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PosOpenShiftDialog(controller: controller),
    );

    if (!mounted) return;
    if (opened != true) return;

  }
  void initControllerMain(){
    final app = context.read<AppController>();
    controller = PosTabletLandscapeController(app: app)..addListener(_onChanged);
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta request del controller al modal (porque aquí sí hay context)
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta evento del controller al Drawer
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };
    // ✅ Carga data inicial (fixtures)
    controller.init(
      initialProducts: PosTabletLandscapeFixtures.getProductsData(),
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(),
      // opcional:
      initialSelectedProductCategoryId: 'all',
      initialSelectedMenuCategoryId: 'all',
    );
    productCategories = PosTabletLandscapeFixtures.getCategoriesData();
    selectedProductCategoryId = productCategories.isNotEmpty
        ? productCategories.first.id
        : null;
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

    String fullName=!isAddCustomer?widget.controllerMain.selectedCustomer!.name:"";
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
          onPressed: () => widget.onUserTap(context, {
            "source": "header",
            "type": isAddCustomer ? "create_user" : "update_user",
          }),
          icon: isAddCustomer
              ? const Icon(
            Icons.person_add_alt_1,
            color: Colors.orange,
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children:  [
              Text(
                fullName,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.quick_contacts_mail_outlined,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed:()=> widget.onMoreTap(context, {
          "source": "header",
          "type":"",
          }),
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
                onChanged: hasCats ? widget.onProductCategoryChanged : null,
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
