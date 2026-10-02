import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../../../../app/router/controllers/app_controller.dart';
import '../../../../shared/responsive/device_gesture_observer.dart';
import '../../repositories/config_repository.dart';
import '../../services/pos_labels_service.dart';
import '../../shared/utils.dart';
import '../../state/pos_product_browser_state.dart';

import '../dialogs/moda_managerl.dart';
import '../dialogs/modal_pos_pay.dart';
import '../models/pos_product_item.dart';

import '../../state/pos_shift_state.dart';
import '../../state/pos_ticket_state.dart';
import '../../state/pos_payment_state.dart';
import '../../state/pos_checkout_state.dart';
import '../../state/pos_ui_state.dart';

class PosMainController extends ChangeNotifier {
  final AppController app;
  final PosShiftState shift;
  final PosProductBrowserState browser;
  final PosTicketState ticket;
  final PosPaymentState payment;
  final PosCheckoutState checkout;
  final PosUiState ui;
  final ConfigRepository configRepository;
  final PosLabelsService labels;
  final DeviceState device;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  PosMainController({
    required AppController app,
    required this.configRepository,
    PosShiftState? shift,
    PosProductBrowserState? browser,
    PosTicketState? ticket,
    PosPaymentState? payment,
    PosCheckoutState? checkout,
    PosUiState? ui,
    PosLabelsService? labels,
    DeviceState? device,
  }) : app = app,
       shift = shift ?? PosShiftState(app: app),
       browser = browser ?? PosProductBrowserState(),
       ticket = ticket ?? PosTicketState(),
       payment = payment ?? PosPaymentState(),
       checkout = checkout ?? PosCheckoutState(),
       labels = labels ?? const PosLabelsService(),
       ui = ui ?? PosUiState(),
       device = device ?? DeviceState() {
    typeService = typeServicesData.first;
    initDataConfig();
    _bindStates();
  }
  Future<void> initDataConfig() async {
    final customer = await configRepository.getFinalConsumer();

    if (_isDisposed) {
      return;
    }

    dataCustomerFinal = customer;

    if (dataCustomerFinal != null) {
      setCustomerTicket(dataCustomerFinal);
    }
  }

  // ============================================================
  // BIND STATES
  // ============================================================

  void _bindStates() {
    shift.addListener(notifyListeners);
    browser.addListener(notifyListeners);
    ticket.addListener(notifyListeners);
    payment.addListener(notifyListeners);
    checkout.addListener(notifyListeners);
    ui.addListener(notifyListeners);
    device.addListener(notifyListeners);
  }

  // ============================================================
  // INIT
  // ============================================================

  Future<void> init({
    required List<PosProductItem> initialProducts,
    required List<PosCategoryItem> initialProductCategories,
    required List<PosCategoryItem> initialMenuCategories,
    String? initialSelectedProductCategoryId,
    String? initialSelectedMenuCategoryId,
  }) async {
    // await shift.initLocalStorage(); // INIT DATA CASH

    if (_isDisposed) {
      return;
    }

    browser.init(
      initialProducts: initialProducts,
      initialProductCategories: initialProductCategories,
      initialMenuCategories: initialMenuCategories,
      initialSelectedProductCategoryId: initialSelectedProductCategoryId,
      initialSelectedMenuCategoryId: initialSelectedMenuCategoryId,
    );
  }

  /**
   * ============================================================
   * SHIFT
   * ============================================================
   */

  bool get isShiftOpen => shift.isShiftOpen;

  double? get shiftOpeningAmount => shift.initialCash;

  DateTime? get shiftOpenedAt => shift.openedAt;

  int? get shiftOpenedByUserId => shift.openedByUserId;

  PosShiftSession? get shiftSession => shift.currentSession;

  // ============================================================
  // PRODUCT
  // ============================================================

  void onProductTap(PosProductItem product) {
    ticket.addProduct(product);
  }

  // ============================================================
  // SAVE
  // ============================================================

  void onSave() {
    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }

    debugPrint('onSave -> guardar ticket');

    ticket.saveTicket();
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  void onPay(BuildContext context) {
    // PROCESS-INIT

    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }

    final controller = PosPaymentLayoutController(main: this);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) {
          return Scaffold(
            body: AnimatedBuilder(
              animation: Listenable.merge([this, controller]),
              builder: (_, __) {
                return buildPaymentModal(main: this, controller: controller);
              },
            ),
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // CHECKOUT
  // ============================================================

  void onPrimaryCheckoutTap(BuildContext context) {
    if (checkout.checkoutAction == PosCheckoutAction.pay) {
      onPay(context);
    } else {
      onSave();
    }
  }

  // ============================================================
  // DISPOSE STATE
  // ============================================================

  bool _isDisposed = false;

  // ============================================================
  // INIT POINT OF SALES
  // ============================================================

  Future<void> initDataPointOfSales() async {
    if (_isDisposed) return;

    browser.setLoadingData(true);

    try {
      await shift.loadData();

      if (_isDisposed) return;

      final products = await PosTabletLandscapeFixtures.getProductsData();

      if (_isDisposed) return;

      browser.allProducts = products;

      await init(
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

      if (_isDisposed) return;

      browser.setLoadingData(false);

      notifyListeners();
    } catch (e, stackTrace) {
      if (_isDisposed) return;

      browser.setLoadingData(false);

      debugPrint('Error initDataPointOfSales: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _isDisposed = true;

    shift.removeListener(notifyListeners);

    browser.removeListener(notifyListeners);

    ticket.removeListener(notifyListeners);

    payment.removeListener(notifyListeners);

    checkout.removeListener(notifyListeners);

    ui.removeListener(notifyListeners);

    /// NUEVO
    device.removeListener(notifyListeners);

    ui.isSummaryExpanded.dispose();

    /// PosMainController creó DeviceState
    /// cuando no fue inyectado externamente.
    ///
    /// En tu implementación actual DeviceState
    /// pertenece al ciclo de vida de este controller.
    device.dispose();

    super.dispose();
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  CustomerModelPosCurrent? selectedCustomer;

  CustomerModelPosCurrent? dataCustomerFinal;

  void setCustomerTicket(CustomerModelPosCurrent? selectedCustomerCurrent) {
    selectedCustomer = selectedCustomerCurrent;

    notifyListeners();
  }

  // ============================================================
  // TYPE SERVICES
  // ============================================================

  List<TypeService> typeServicesData = [
    TypeService(
      label: 'Para servirse',
      icon: Icons.restaurant,
      value: 'servirse',
      key: "DINE_IN",
    ),
    TypeService(
      label: 'Para llevar',
      icon: Icons.shopping_bag,
      value: 'llevar',
      key: "TAKEAWAY",
    ),
    TypeService(
      label: 'A domicilio',
      icon: Icons.delivery_dining,
      value: 'domicilio',
      key: "DELIVERY",
    ),
  ];

  bool get hasCustomerSelected => selectedCustomer != null;

  late TypeService typeService;

  void setTypeService(TypeService typeSelected) {
    typeService = typeSelected;

    debugPrint('setTypeService: ${typeService.value}');

    notifyListeners();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  String? selectedProductCategoryId;

  void setProductCategory(String id) {
    selectedProductCategoryId = id;

    notifyListeners();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  String query = '';

  void setQuery(String value) {
    query = value;

    notifyListeners();
  }

  List<PosCategoryItem> get productCategories => browser.productCategories;
  bool allowManagementPost() {
    late bool result =
        selectedCustomer != null &&
        shift.isShiftOpen &&
        ticket.items.isNotEmpty;

    if (checkout.isPaySelected) {
      // Mantener lógica actual.
    } else {
      // Mantener lógica actual.
    }

    return result;
  }

  String get labelTitleWayPayment => "Formas de Pago";

  CustomerModelPosCurrent get customerInUse {
    return selectedCustomer ?? dataCustomerFinal!;
  }

  bool get canUseCoupons {
    return ticket.items.isNotEmpty && shift.isShiftOpen;
  }

  void initManagerDataByDevice(DeviceSnapshot snapshot) {

    device.update(snapshot);

    setCurrentManagerDevice(snapshot);

    setColsNumberRowPosSales(getColsNumberRowPosSales(snapshot));
  }

  // ============================================================
  // DEVICE EVENTS
  // ============================================================

  void onDeviceEvent(DeviceSnapshot snapshot, GestureEvent event) {
    switch (event.type) {

      case GestureEventType.orientationChanged:
        initManagerDataByDevice(snapshot);
        break;
      case GestureEventType.metricsChanged:
        initManagerDataByDevice(snapshot);

        break;

      case GestureEventType.tap:
        break;

      case GestureEventType.doubleTap:
        break;

      case GestureEventType.longPress:
        break;

      case GestureEventType.panUpdate:
        break;

      case GestureEventType.scaleStart:
        break;

      case GestureEventType.scaleUpdate:
        break;

      case GestureEventType.scaleEnd:
        break;
    }
  }
  int colsNumberRowPosSales = 5;
  void setColsNumberRowPosSales(int value) {
    colsNumberRowPosSales = value;

    notifyListeners();
  }

  DeviceSnapshot? currentManagerDevice;

  void setCurrentManagerDevice(DeviceSnapshot value) {
    currentManagerDevice = value;

    notifyListeners();
  }

  int getColsNumberRowPosSales(DeviceSnapshot device) {
    switch (device.layoutType) {
      case LayoutType.mobilePortrait:
        return 2;

      case LayoutType.mobileLandscape:
        return 3;

      case LayoutType.tabletPortrait:
        return 4;

      case LayoutType.tabletLandscape:
        return 5;
    }
  }
}
