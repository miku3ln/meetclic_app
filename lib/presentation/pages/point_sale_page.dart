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


/// ===============================================================
/// PROVIDER / SCOPE DEL MÓDULO POS
/// ===============================================================
///
/// Este Scope es el propietario de la instancia de PosMainController.
///
/// Mientras /sales permanezca en el stack:
///
/// - PosMainController permanece vivo.
/// - Shift puede utilizar la misma instancia.
/// - Business puede utilizar la misma instancia.
/// - Items puede utilizar la misma instancia.
/// - Settings puede utilizar la misma instancia.
/// - Loyalty puede utilizar la misma instancia.
///
/// AppController solamente conserva una referencia a esta instancia.
///
class PointSaleScope extends StatefulWidget {
  const PointSaleScope({
    super.key,
  });

  @override
  State<PointSaleScope> createState() =>
      _PointSaleScopeState();
}

class _PointSaleScopeState
    extends State<PointSaleScope> {

  late final AppController _app;

  late final PosMainController _controller;

  @override
  void initState() {
    super.initState();

    /**
     * AppController ya existe por encima
     * de MaterialApp / navegación.
     */
    _app = context.read<AppController>();

    /**
     * Crear UNA SOLA instancia del
     * controlador principal del POS.
     */
    _controller = PosMainController(
      app: _app,
      configRepository: ConfigRepository(
        ConfigApiService(),
      ),
    );

    /**
     * Registrar esta instancia en AppController.
     *
     * AppController NO administra la lógica
     * interna del POS.
     *
     * Solamente conserva una referencia
     * a la instancia activa.
     */
    _app.attachPosMainController(
      _controller,
    );

    /**
     * Inicializar información del POS.
     */
    _controller.initDataPointOfSales();
  }

  @override
  void dispose() {
    /**
     * Quitamos la referencia solamente
     * si AppController todavía tiene
     * exactamente esta instancia.
     */
    _app.detachPosMainController(
      _controller,
    );

    /**
     * Como nosotros creamos el controller
     * usando Provider.value, nosotros
     * también somos responsables de dispose.
     */
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /**
     * IMPORTANTE:
     *
     * .value porque _controller ya fue
     * creado por este State.
     *
     * Provider NO debe crear ni destruir
     * esta instancia.
     */
    return ChangeNotifierProvider<
        PosMainController>.value(
      value: _controller,
      child: const PointSalePage(),
    );
  }
}


/// ===============================================================
/// PÁGINA PRINCIPAL POS
/// ===============================================================
class PointSalePage extends StatefulWidget {
  const PointSalePage({
    super.key,
  });

  @override
  State<PointSalePage> createState() =>
      _PointSalePageState();
}

class _PointSalePageState
    extends State<PointSalePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();

  bool _callbacksInitialized = false;

  bool _deviceInitialized = false;


  /// =============================================================
  /// INIT
  /// =============================================================
  @override
  void initState() {
    super.initState();
  }


  /// =============================================================
  /// DEPENDENCIAS
  /// =============================================================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_callbacksInitialized) {
      return;
    }

    final controller =
    context.read<PosMainController>();

    /**
     * Abrir turno.
     */
    controller.shift.onRequestOpenShift =
        _showOpenShiftModal;

    /**
     * Abrir drawer.
     */
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState
          ?.openDrawer();
    };

    _callbacksInitialized = true;
  }


  /// =============================================================
  /// BUILD
  /// =============================================================
  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<PosMainController>();

    final device =
    DeviceGestureObserver.snapshotOf(
      context,
    );

    /**
     * Ejecutar solamente una vez
     * después de renderizar el primer frame.
     */
    if (!_deviceInitialized) {
      _deviceInitialized = true;

      WidgetsBinding.instance
          .addPostFrameCallback((_) {

        if (!mounted) {
          return;
        }

        controller.initManagerDataByDevice(
          device,
        );
      });
    }

    return Scaffold(
      key: _scaffoldKey,

      resizeToAvoidBottomInset: false,

      drawer: const PosAppDrawer(),

      body: DeviceGestureObserver(
        onEvent: controller.onDeviceEvent,
        child: _buildByLayout(
          device.layoutType,
        ),
      ),
    );
  }


  /// =============================================================
  /// OPEN SHIFT
  /// =============================================================
  Future<void> _showOpenShiftModal() async {
    final controller =
    context.read<PosMainController>();

    /**
     * INIT DATA CASH / ALLOW POINT SALES
     */
    final opened =
    await showDialog<bool>(
      context: context,

      barrierDismissible: true,

      builder: (_) =>
          PosOpenShiftDialog(
            controller: controller,
          ),
    );

    if (!mounted) {
      return;
    }

    if (opened != true) {
      return;
    }
  }


  /// =============================================================
  /// LAYOUT
  /// =============================================================
  Widget _buildByLayout(
      LayoutType layout,
      ) {
    switch (layout) {
      case LayoutType.mobilePortrait:
      case LayoutType.mobileLandscape:
      case LayoutType.tabletPortrait:
      case LayoutType.tabletLandscape:
        return const PosTabletLandscapeLayout();
    }
  }
}