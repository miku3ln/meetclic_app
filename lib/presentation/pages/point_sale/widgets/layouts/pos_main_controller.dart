import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

import '../../../../../shared/controllers/app_controller.dart';
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

  PosMainController({
    required AppController app,
    required this.configRepository, // 👈 NUEVO
    PosShiftState? shift,
    PosProductBrowserState? browser,
    PosTicketState? ticket,
    PosPaymentState? payment,
    PosCheckoutState? checkout,
    PosUiState? ui,
    PosLabelsService? labels,
  }) : app = app,
       shift = shift ?? PosShiftState(app: app, storage: PosShiftStorage()),
       browser = browser ?? PosProductBrowserState(),
       ticket = ticket ?? PosTicketState(),
       payment = payment ?? PosPaymentState(),
       checkout = checkout ?? PosCheckoutState(),
       labels = labels ?? const PosLabelsService(),
       ui = ui ?? PosUiState() {
    typeService = typeServicesData.first; // 🔥 AQUÍ
    initDataConfig();
    _bindStates();
  }

  void initDataConfig() async {
    /// 🔥 CARGAR CONFIG
    dataCustomerFinal = await configRepository.getFinalConsumer();
    if (dataCustomerFinal != null) {
      setCustomerTicket(dataCustomerFinal);
    }
  }

  void _bindStates() {
    shift.addListener(notifyListeners);
    browser.addListener(notifyListeners);
    ticket.addListener(notifyListeners);
    payment.addListener(notifyListeners);
    checkout.addListener(notifyListeners);
    ui.addListener(notifyListeners);
  }

  Future<void> init({
    required List<PosProductItem> initialProducts,
    required List<PosCategoryItem> initialProductCategories,
    required List<PosCategoryItem> initialMenuCategories,
    String? initialSelectedProductCategoryId,
    String? initialSelectedMenuCategoryId,
  }) async {
    await shift.init();

    browser.init(
      initialProducts: initialProducts,
      initialProductCategories: initialProductCategories,
      initialMenuCategories: initialMenuCategories,
      initialSelectedProductCategoryId: initialSelectedProductCategoryId,
      initialSelectedMenuCategoryId: initialSelectedMenuCategoryId,
    );
  }

  void onProductTap(PosProductItem product) {
    ticket.addProduct(product);
  }

  void onSave() {
    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }

    debugPrint('onSave -> guardar ticket');
    ticket.saveTicket();
  }

  void onPay(BuildContext context) {
    //PROCESS-INIT
    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }
    final controller = PosPaymentLayoutController(main: this);
    if (true) //TYPE VIEW POS SALE
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
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0), // 👉 entra desde derecha
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          },
        ),
      );
    if (false)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AnimatedBuilder(
            animation: Listenable.merge([this, controller]),
            // animation: this, // 🔥 ESCUCHA CAMBIOS DEL MAIN
            builder: (_, __) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: buildPaymentModal(main: this, controller: controller),
                ),
              );
            },
          );
        },
      );
  }

  void onPrimaryCheckoutTap(BuildContext context) {
    if (checkout.checkoutAction == PosCheckoutAction.pay) {
      onPay(context);
    } else {
      onSave();
    }
  }

  @override
  void dispose() {
    shift.removeListener(notifyListeners);
    browser.removeListener(notifyListeners);
    ticket.removeListener(notifyListeners);
    payment.removeListener(notifyListeners);
    checkout.removeListener(notifyListeners);
    ui.removeListener(notifyListeners);
    ui.isSummaryExpanded.dispose();
    super.dispose();
  }

  CustomerModelPosCurrent? selectedCustomer;
  CustomerModelPosCurrent? dataCustomerFinal;

  Future<void> initDataPointOfSales() async {
    browser.setLoadingData(true);
    final products = await PosTabletLandscapeFixtures.getProductsData();

    browser.allProducts = products;
    init(
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
    browser.setLoadingData(false);
    notifyListeners();
  }

  void setCustomerTicket(CustomerModelPosCurrent? selectedCustomerCurrent) {
    selectedCustomer = selectedCustomerCurrent;
    notifyListeners();
  }

  List<TypeService> typeServicesData = [
    TypeService(
      label: 'Para servirse',
      icon: Icons.restaurant,
      value: 'servirse',
    ),
    TypeService(
      label: 'Para llevar',
      icon: Icons.shopping_bag,
      value: 'llevar',
    ),
    TypeService(
      label: 'A domicilio',
      icon: Icons.delivery_dining,
      value: 'domicilio',
    ),
  ];

  bool get hasCustomerSelected => selectedCustomer != null;
  late TypeService typeService;

  void setTypeService(TypeService typeSelected) {
    typeService = typeSelected;
    debugPrint('setTypeService: ${typeService.value}');

    notifyListeners();
  }

  // 🔥 CATEGORY
  String? selectedProductCategoryId;

  void setProductCategory(String id) {
    selectedProductCategoryId = id;
    notifyListeners();
  }

  // 🔥 SEARCH
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
    } else {}
    return result;
  }

  String get labelTitleWayPayment => "Formas de Pago";

  CustomerModelPosCurrent get customerInUse {
    return selectedCustomer ?? dataCustomerFinal!;
  }

  bool get canUseCoupons {
    return ticket.items.isNotEmpty && shift.isShiftOpen;
  }

  void onDeviceEvent(DeviceSnapshot device, GestureEvent event) {
    switch (event.type) {
      case GestureEventType.orientationChanged:
        debugPrint('Orientación: ${device.orientation.name}');
        if (device.orientation.name == 'portrait') {
          if (device.layoutType == LayoutType.mobilePortrait) {
          } else if (device.layoutType == LayoutType.tabletPortrait) {
            setColsNumberRowPosSales(4);
          }
        } else if (device.orientation.name == 'landscape') {
          if (device.layoutType == LayoutType.mobileLandscape) {
          } else if (device.layoutType == LayoutType.tabletLandscape) {
            setColsNumberRowPosSales(5);
          }
        }
        break;

      case GestureEventType.metricsChanged:
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
}
