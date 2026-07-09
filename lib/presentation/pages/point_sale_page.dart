import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:meetclic_app/presentation/pages/point_sale/repositories/config_repository.dart';
import 'package:meetclic_app/presentation/pages/point_sale/services/config_api_service.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/dialogs/pos_open_shift_dialog.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/drawers/pos_app_drawer.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/pos_main_controller.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/models/pos_product_item.dart';
import '../../../../../app/router/controllers/app_controller.dart';

import '../../shared/theme/configuration/app_theme_tokens.dart';
import '../../shared/utils/util_common.dart';
import '../shared/responsive/device_gesture_observer.dart';

import '../pages/point_sale/widgets/layouts/mobile_portrait_layout.dart';
import '../pages/point_sale/widgets/layouts/mobile_landscape_layout.dart';
import '../pages/point_sale/widgets/layouts/tablet_portrait_layout.dart';
import '../pages/point_sale/widgets/layouts/tablet_landscape_layout.dart';
import 'package:provider/provider.dart';

/// ===============================================================
///
/// PROVIDER DEL MÓDULO POS
///
/// ===============================================================
class PointSaleScope extends StatelessWidget {
  const PointSaleScope({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    final colors = AppThemeTokens.of(context);
    return ChangeNotifierProvider(
      create: (_) => PosMainController(
        app: app,
        configRepository: ConfigRepository(
          ConfigApiService(),
        ),
      )..initDataPointOfSales(),
      child: const PointSalePage(),
    );
  }
}

/// ===============================================================
///
/// PÁGINA PRINCIPAL POS
///
/// ===============================================================

/// ===============================================================
/// PÁGINA PRINCIPAL POS
/// ===============================================================
class PointSalePage extends StatefulWidget {
  const PointSalePage({super.key});

  @override
  State<PointSalePage> createState() => _PointSalePageState();
}

class _PointSalePageState extends State<PointSalePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  bool _callbacksInitialized = false;
  bool _deviceInitialized = false;
  @override
  void initState() {
    super.initState();

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_callbacksInitialized) return;

    final controller = context.read<PosMainController>();

    /// Abrir turno
    controller.shift.onRequestOpenShift = _showOpenShiftModal;

    /// Abrir drawer
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };

    _callbacksInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosMainController>();
    final device = DeviceGestureObserver.snapshotOf(context);

    /// ✅ SOLO EJECUTAR UNA VEZ Y DESPUÉS DEL FRAME
    if (!_deviceInitialized) {
      _deviceInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initManagerDataByDevice(device);
      });
    }

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

  Future<void> _showOpenShiftModal() async {
    final controller = context.read<PosMainController>();

    final opened = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PosOpenShiftDialog(
        controller: controller,
      ),
    );

    if (!mounted) return;
    if (opened != true) return;
  }

  Widget _buildByLayout(LayoutType layout) {
    switch (layout) {
      case LayoutType.mobilePortrait:
      case LayoutType.mobileLandscape:
      case LayoutType.tabletPortrait:
      case LayoutType.tabletLandscape:
        return const PosTabletLandscapeLayout();
    }
  }
}
