import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../dialogs/pos_open_shift_dialog.dart';
import '../organisms/pos_header_bar.dart';
import '../models/pos_product_item.dart'; // PosCategoryItem
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'package:provider/provider.dart';

class PosTabletPortraitLayout extends StatefulWidget {
  const PosTabletPortraitLayout({super.key});

  @override
  State<PosTabletPortraitLayout> createState() =>
      _PosTabletPortraitLayoutState();
}

class _PosTabletPortraitLayoutState extends State<PosTabletPortraitLayout> {
  late final PosTabletLandscapeController controller;
  late final List<PosCategoryItem> productCategories;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅

  String? selectedProductCategoryId;

  String query = '';

  @override
  void initState() {
    super.initState();
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
  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }
  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
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
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PosHeaderBar(
        controllerMain:controller ,
        productCategories: productCategories,
        selectedProductCategoryId: selectedProductCategoryId,
        onProductCategoryChanged: (id) {
          setState(() => selectedProductCategoryId = id);
          debugPrint('productCategory => $id');
        },
        onMenuTap: () {},
        onUserTap: (context, data) => controller.ui.onUserTap(context,null,controller),
        onMoreTap: () {},
        onSearchChanged: (text) {
          setState(() => query = text);
          debugPrint('search: $text');
        },
        onSearchSubmitted: (text) {
          setState(() => query = text);
          debugPrint('submit: $text');
        },
      ),
      body: Center(
        child: Text(
          'POS Tablet Portrait\ncategory=$selectedProductCategoryId\nquery="$query"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
