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

  Future<void> initControllerMain() async {
    final app = context.read<AppController>();

    controller = PosMainController(
      app: app,
      configRepository: ConfigRepository(
        ConfigApiService(), // 👈 mock por ahora
      ),
    )..addListener(_onChanged);

    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta request del controller al modal (porque aquí sí hay context)
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta evento del controller al Drawer
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };
    await controller.initDataPointOfSales();
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
    controller.initManagerDataByDevice(device);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const PosAppDrawer(),
      body: DeviceGestureObserver(
        onEvent: controller.onDeviceEvent,
        child: _buildByLayout(device.layoutType),
      ),
    );
  }

  Widget _buildByLayout(LayoutType layout) {
    switch (layout) {
      case LayoutType.mobilePortrait:
        return PosTabletLandscapeLayout(controller: controller);
      case LayoutType.mobileLandscape:
        return PosTabletLandscapeLayout(controller: controller);
      case LayoutType.tabletPortrait:
        return PosTabletLandscapeLayout(controller: controller);
      case LayoutType.tabletLandscape:
        return PosTabletLandscapeLayout(controller: controller);
    }
  }
}

class _PointSalePageState2 extends State<PointSalePage> {
  late final PosMainController controller;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initController();
    await _loadInitialData();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _initController() async {
    final app = context.read<AppController>();
    controller = PosMainController(
      app: app,
      configRepository: ConfigRepository(ConfigApiService()),
    );

    controller.addListener(_onChanged);
    _bindControllerEvents();
  }

  void _bindControllerEvents() {
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };
  }

  Future<void> _loadInitialData() async {
    final products = await PosTabletLandscapeFixtures.getProductsData();
    controller.browser.allProducts = products;
    controller.init(
      initialProducts: products,
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(
        products,
      ),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(
        products,
      ),
      initialSelectedProductCategoryId: 'all',
      initialSelectedMenuCategoryId: 'all',
    );
    final categories = PosTabletLandscapeFixtures.getCategoriesData(products);
    if (categories.isNotEmpty) {
      controller.setProductCategory(categories.first.id);
    }
  }

  Future<void> _showOpenShiftModal() async {
    await showDialog(
      context: context,
      builder: (_) => PosOpenShiftDialog(controller: controller),
    );
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final device = DeviceGestureObserver.snapshotOf(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const PosAppDrawer(),
      body: DeviceGestureObserver(
        onEvent: controller.onDeviceEvent,
        child: _buildByLayout(device.layoutType),
      ),
    );
  }

  Widget _buildByLayout(LayoutType layout) {
    switch (layout) {
      case LayoutType.mobilePortrait:
        return PosTabletLandscapeLayout(controller: controller);
      case LayoutType.mobileLandscape:
        return PosTabletLandscapeLayout(controller: controller);
      case LayoutType.tabletPortrait:
        return PosTabletLandscapeLayout(controller: controller);
      case LayoutType.tabletLandscape:
        return PosTabletLandscapeLayout(controller: controller);
    }
  }
}
