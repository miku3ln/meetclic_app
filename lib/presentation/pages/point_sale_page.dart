import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/router/controllers/app_controller.dart';

import '../../shared/theme/configuration/app_theme_tokens.dart';
import '../shared/responsive/device_gesture_observer.dart';

import '../pages/point_sale/repositories/config_repository.dart';
import '../pages/point_sale/services/config_api_service.dart';

import '../pages/point_sale/widgets/dialogs/pos_open_shift_dialog.dart';
import '../pages/point_sale/widgets/drawers/pos_app_drawer.dart';

import '../pages/point_sale/widgets/layouts/pos_main_controller.dart';
import '../pages/point_sale/widgets/layouts/tablet_landscape_layout.dart';

class PointSaleScope extends StatefulWidget {
  const PointSaleScope({super.key});

  @override
  State<PointSaleScope> createState() => _PointSaleScopeState();
}

class _PointSaleScopeState extends State<PointSaleScope> {
  late final AppController _app;
  late final PosMainController _controller;

  @override
  void initState() {
    super.initState();
    _app = context.read<AppController>();
    _controller = PosMainController(
      app: _app,
      configRepository: ConfigRepository(ConfigApiService()),
    );
    _app.attachPosMainController(_controller);
    _controller.initDataPointOfSales();
  }

  @override
  void dispose() {
    _app.detachPosMainController(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PosMainController>.value(
      value: _controller,
      child: const PointSalePage(),
    );
  }
}

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

    if (_callbacksInitialized) {
      return;
    }

    final controller = context.read<PosMainController>();
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };

    _callbacksInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosMainController>();

    final device = DeviceGestureObserver.snapshotOf(context);

    /**
     * Ejecutar solamente una vez
     * después de renderizar el primer frame.
     */
    if (!_deviceInitialized) {
      _deviceInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        controller.initManagerDataByDevice(device);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const PosAppDrawer(),
      body: DeviceGestureObserver(
        onEvent: controller.onDeviceEvent,
        child: _buildByLayout(device.layoutType, device),
      ),
    );
  }

  Future<void> _showOpenShiftModal() async {
    final controller = context.read<PosMainController>();
    final opened = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PosOpenShiftDialog(controller: controller),
    );

    if (!mounted) {
      return;
    }

    if (opened != true) {
      return;
    }
  }

  Widget _buildByLayout(
    //INIT PROCESS-MANAGER-UI-01
    LayoutType layout,
    DeviceSnapshot device,
  ) {
    switch (layout) {
      case LayoutType.mobilePortrait:
      case LayoutType.mobileLandscape:
        return LandscapeLayout(device: device);
      case LayoutType.tabletPortrait:
      case LayoutType.tabletLandscape:
        return PosTabletLandscapeLayout(device: device);
    }
  }
}
