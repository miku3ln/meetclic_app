import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/repositories/config_repository.dart';
import 'package:meetclic_app/presentation/pages/point_sale/services/config_api_service.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/dialogs/pos_open_shift_dialog.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/drawers/pos_app_drawer.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/pos_main_controller.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/models/pos_product_item.dart';
import '../../shared/controllers/app_controller.dart';
import '../shared/responsive/device_gesture_observer.dart';

import '../pages/point_sale/widgets/layouts/mobile_portrait_layout.dart';
import '../pages/point_sale/widgets/layouts/mobile_landscape_layout.dart';
import '../pages/point_sale/widgets/layouts/tablet_portrait_layout.dart';
import '../pages/point_sale/widgets/layouts/tablet_landscape_layout.dart';
import 'package:provider/provider.dart';

class PointSalePage extends StatefulWidget {
  const PointSalePage({super.key});

  @override
  State<PointSalePage> createState() => _PointSalePageState();
}
class _PointSalePageState extends State<PointSalePage> {
  late final PosMainController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅
  late final List<PosCategoryItem> productCategories;
  String? selectedProductCategoryId;
  // ✅ (3) search
  String query = '';
  @override
  @override
  void initState() {
    super.initState();
    initControllerMain();
  }
  Future<void> initControllerMain() async{
    final app = context.read<AppController>();

    controller = PosMainController(app: app,configRepository: ConfigRepository(
        ConfigApiService(), // 👈 mock por ahora
    ))..addListener(_onChanged);

    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta request del controller al modal (porque aquí sí hay context)
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta evento del controller al Drawer
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };
    final products = await PosTabletLandscapeFixtures.getProductsData();
    controller.browser.allProducts=products;

    // ✅ Carga data inicial (fixtures)
    controller.init(
      initialProducts:products,
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(products),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(products),
      // opcional:
      initialSelectedProductCategoryId: 'all',
      initialSelectedMenuCategoryId: 'all',
    );
    productCategories = PosTabletLandscapeFixtures.getCategoriesData(products);
    selectedProductCategoryId = productCategories.isNotEmpty
        ? productCategories.first.id
        : null;
    controller.setProductCategory(selectedProductCategoryId!);

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
  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final device = DeviceGestureObserver.snapshotOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: const PosAppDrawer(), // ✅ tu drawer estilo Drive
      body: DeviceGestureObserver(
        onEvent: (d, e) {
          debugPrint('DEVICE => $d');
          debugPrint('EVENT  => $e');
        },
        child: _buildByLayout(device.layoutType),
      ),
    );
  }
  Widget _buildByLayout(LayoutType layout) {
    switch (layout) {
      case LayoutType.mobilePortrait:
        return PosMobilePortraitLayout(controller: controller,scaffoldKey: _scaffoldKey);

      case LayoutType.mobileLandscape:
        return PosMobileLandscapeLayout(controller: controller,scaffoldKey: _scaffoldKey);

      case LayoutType.tabletPortrait:
        return PosTabletLandscapeLayout(controller: controller);//TODO DESIGN

      case LayoutType.tabletLandscape:
        return PosTabletLandscapeLayout(controller: controller);
    }
  }
}