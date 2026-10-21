import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../../../../app/router/controllers/app_controller.dart';
import '../../../../../domain/services/session_service.dart';
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

  Future<void> onSave(
      BuildContext context,
      ) async {
    if (!shift.isShiftOpen) {
      shift.onRequestOpenShift?.call();
      return;
    }

    final result =
    await showModalBottomSheet<
        Map<String, dynamic>>(
      context: context,

      // El contenido puede crecer.
      isScrollControlled: true,

      useSafeArea: true,

      // No cerrar tocando afuera.
      isDismissible: false,

      // No cerrar arrastrando.
      enableDrag: false,

      backgroundColor:
      Colors.transparent,

      builder: (_) {
        return PosSaveTicketModal(
          main: this,

          // ==============================================
          // PRINT
          // ==============================================

          onPrint: (
              invoice,
              ) async {
            final invoiceId =
            invoice['id'];

            debugPrint(
              'Imprimir ticket '
                  'invoice_id: $invoiceId',
            );

            // Aquí posteriormente conectas
            // tu servicio real de impresión.
          },
        );
      },
    );

    // ============================================================
    // MODAL CLOSED WITHOUT COMPLETING
    // ============================================================

    if (result?['completed'] !=
        true) {
      return;
    }

    // ============================================================
    // COMPLETED
    // ============================================================

    final invoiceId =
    result?['invoice_id'];

    final invoice =
    result?['invoice'];

    debugPrint(
      'Compra finalizada en POS. '
          'invoice_id: $invoiceId',
    );

    debugPrint(
      'Invoice: $invoice',
    );

    // ============================================================
    // AQUÍ VA TU RESET REAL
    // ============================================================

    // ticket.clear();
    // payment.reset();
    // checkout.reset();
    //
    // Si también deseas quitar el cliente:
    // selectedCustomer = null;

    notifyListeners();
  }
  Map<String, dynamic> getTicketDraftData(total,paymentMethod,invoiceId) {//GENERATE TICKET
    final businessId = SessionService().businessId;
    final currentSession = SessionService().currentSession;
    final userId = currentSession?.userId;
    final typeSave ='SAVE';
    return {
      'header': {
        'paymentMethod': paymentMethod,
        'total': total,
        'userId': userId,
        'invoice_id': invoiceId,
        'business_id': businessId,
        'typeSave': typeSave,
      },
    };
  }
  Map<String, dynamic> getTicketData() {//GENERATE TICKET
    final customerId = selectedCustomer?.id;
    final businessId = SessionService().businessId;
    final currentSession = SessionService().currentSession;
    final userId = currentSession?.userId;
    final paymentMethod = payment.paymentMethodCode;
    final typeSave = checkout.checkoutAction == PosCheckoutAction.pay
        ? 'SAVE'
        : 'NOT-SAVE';

    final itemsBody = ticket.items.map((item) {
      return PostTicketItemSave(
        id: item.productItem.id,
        code: item.productItem.code,
        name: item.productItem.name,
        description: item.description ?? '',
        type: item.productItem.type,
        amount: item.amount.toDouble(),
        hasTax: item.tax > 0 ? 'SI' : 'NO',
        valuePercentageTax: item.tax,
        pvPrice: item.unitPrice,
        total: item.total,
        subtotal: item.subtotal,
        valuePercentageDiscount:
        item.discount + item.couponDiscount,
      );
    }).toList();

    return {
      'body': itemsBody
          .map(
            (e) => {
          'id': e.id,
          'code': e.code,
          'name': e.name,
          'description': e.description,
          'type': e.type,
          'amount': e.amount,
          'hasTax': e.hasTax,
          'valuePercentageTax': e.valuePercentageTax,
          'pvPrice': e.pvPrice,
          'subtotal': e.subtotal,
          'total': e.total,
          'valuePercentageDiscount':
          e.valuePercentageDiscount,
        },
      )
          .toList(),

      'header': {
        'paymentMethod': paymentMethod,
        'customer_id': customerId,
        'userId': userId,
        'business_id': businessId,
        'typeSave': typeSave,
        'typeService': typeService.value,
      },
    };
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
      onSave(context);
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

class PosSaveTicketModal extends StatefulWidget {
  final PosMainController main;

  /// Callback para imprimir el ticket.
  /// Recibe exactamente el objeto:
  ///
  /// result['data']['invoice']
  ///
  final Future<void> Function(
      Map<String, dynamic> invoice,
      )? onPrint;

  const PosSaveTicketModal({
    super.key,
    required this.main,
    this.onPrint,
  });

  @override
  State<PosSaveTicketModal> createState() =>
      _PosSaveTicketModalState();
}

class _PosSaveTicketModalState
    extends State<PosSaveTicketModal> {
  // ============================================================
  // STATE
  // ============================================================

  bool _isSaving = false;
  bool _isCompleted = false;
  bool _isPrinting = false;

  String? _errorMessage;

  /// Contiene exactamente:
  ///
  /// result['data']['invoice']
  ///
  Map<String, dynamic>? _invoice;

  // ============================================================
  // INVOICE DATA
  // ============================================================

  /// ID real de invoice_sale.
  ///
  /// Ejemplo API:
  /// "id": 10
  ///
  /// ESTE ES EL NÚMERO PRINCIPAL QUE EL EMPLEADO
  /// UTILIZARÁ PARA BUSCAR LA COMPRA.
  int? get _invoiceId {
    final value = _invoice?['id'];

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  /// Número mostrado al cliente.
  ///
  /// Ejemplo:
  /// 10
  String get _ticketNumber {
    return _invoiceId?.toString() ?? '---';
  }

  /// Estado visual.
  ///
  /// API:
  /// DRAFT
  ///
  /// UI:
  /// Pendiente de pago
  String get _status {
    final status =
    _invoice?['status']?.toString();

    if (status == 'DRAFT') {
      return 'Pendiente de pago';
    }

    return status ?? '-';
  }

  /// invoice_code retornado por Laravel.
  ///
  /// NO es el ID principal del ticket.
  String get _invoiceCode {
    return _invoice?['invoice_code']
        ?.toString() ??
        '-';
  }

  String get _establishment {
    return _invoice?['establishment']
        ?.toString() ??
        '-';
  }

  String get _emissionPoint {
    return _invoice?['emission_point']
        ?.toString() ??
        '-';
  }

  String get _invoiceDate {
    return _invoice?['invoice_date']
        ?.toString() ??
        '-';
  }

  double get _subtotal {
    return _toDouble(
      _invoice?['subtotal'],
    );
  }

  double get _taxes {
    return _toDouble(
      _invoice?['value_taxes'],
    );
  }

  double get _discount {
    return _toDouble(
      _invoice?['discount_value'],
    );
  }

  /// Actualmente tu API devuelve:
  ///
  /// "invoice_value": 0
  ///
  /// Por eso mantenemos el fallback.
  double get _total {
    final invoiceValue = _toDouble(
      _invoice?['invoice_value'],
    );

    if (invoiceValue > 0) {
      return invoiceValue;
    }

    return (_subtotal + _taxes) -
        _discount;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

  String _money(dynamic value) {
    return '\$${_toDouble(value).toStringAsFixed(2)}';
  }

  // ============================================================
  // GENERATE TICKET
  // ============================================================

  Future<void> _generateTicket() async {//GENERATE TICKET
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final body =
      widget.main.getTicketData();
      final result =
      await PosTicketService.generateTicket(
        body,
      );

      if (!mounted) {
        return;
      }
      if (result['success'] != true) {
        setState(() {
          _isSaving = false;
          _errorMessage =
              result['message']?.toString() ??
                  result['msj']?.toString() ??
                  'No se pudo registrar la compra.';
        });
        return;
      }
      final data = result['data'];
      if (data is! Map) {
        setState(() {
          _isSaving = false;
          _errorMessage =
          'El servidor no devolvió '
              'la información de la compra.';
        });
        return;
      }
      final invoiceData =
      data['invoice'];

      if (invoiceData is! Map) {
        setState(() {
          _isSaving = false;
          _errorMessage =
          'No se recibió la información '
              'de la factura.';
        });

        return;
      }

      final invoice =
      Map<String, dynamic>.from(
        invoiceData,
      );

      // ========================================================
      // VALIDATE ID
      // ========================================================

      if (invoice['id'] == null) {
        setState(() {
          _isSaving = false;
          _errorMessage =
          'La compra fue registrada, '
              'pero no se recibió el número '
              'del ticket.';
        });
        return;
      }
      setState(() {
        _invoice = invoice;
        _isSaving = false;
        _isCompleted = true;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage =
            e.toString();
      });
    }
  }

  // ============================================================
  // PRINT
  // ============================================================

  Future<void> _printTicket() async {
    if (_invoice == null ||
        _isPrinting) {
      return;
    }

    if (widget.onPrint == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'La impresión todavía '
                'no está configurada.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      await widget.onPrint!(
        _invoice!,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo imprimir '
                'el ticket: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  // ============================================================
  // CLOSE COMPLETED TICKET
  // ============================================================

  void _closeCompletedTicket(PosMainController main ) {//TICKET

    main.ticket.onCompleteSave();
    Navigator.pop(
      context,
      {
        'completed': true,

        /// Invoice completa.
        'invoice': _invoice,

        /// ID principal.
        'invoice_id': _invoiceId,
      },
    );

  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final media =
    MediaQuery.of(context);

    return PopScope(
      canPop: !_isSaving,
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
          media.size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,
          borderRadius:
          const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds: 280,
          ),
          child: _isCompleted
              ? _buildSuccess( widget.main)
              : _buildSummary(
            widget.main,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STEP 1
  // RESUMEN DE LA COMPRA
  // ============================================================

  Widget _buildSummary(
      PosMainController main,
      ) {
    final items =
        main.ticket.items;

    final subtotal =
    items.fold<double>(
      0,
          (total, item) =>
      total + item.subtotal,
    );

    final total =
    items.fold<double>(
      0,
          (total, item) =>
      total + item.total,
    );

    return Column(
      key: const ValueKey(
        'ticket-summary',
      ),
      mainAxisSize:
      MainAxisSize.min,
      children: [
        // ======================================================
        // INDICATOR
        // ======================================================

        _buildDragIndicator(),

        // ======================================================
        // HEADER
        // ======================================================

        Padding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            12,
            12,
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons
                      .receipt_long_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Guardar compra',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    SizedBox(
                      height: 2,
                    ),

                    Text(
                      'El cliente podrá pagar '
                          'esta compra después.',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Cerrar',
                onPressed: _isSaving
                    ? null
                    : () =>
                    Navigator.pop(
                      context,
                    ),
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
        ),

        // ======================================================
        // PRODUCTS
        // ======================================================

        Flexible(
          child:
          ListView.separated(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16,
            ),
            shrinkWrap: true,
            itemCount:
            items.length,
            separatorBuilder:
                (_, __) =>
            const Divider(
              height: 22,
            ),
            itemBuilder:
                (_, index) {
              final item =
              items[index];

              return Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  // ============================================
                  // QUANTITY
                  // ============================================

                  Container(
                    constraints:
                    const BoxConstraints(
                      minWidth: 42,
                      minHeight: 38,
                    ),
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 8,
                    ),
                    alignment:
                    Alignment.center,
                    decoration:
                    BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),
                    child: Text(
                      '${item.amount}x',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  // ============================================
                  // PRODUCT
                  // ============================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          item.productItem
                              .name,
                          maxLines: 2,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          '${_money(item.unitPrice)} c/u',
                          style:
                          TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  // ============================================
                  // TOTAL ITEM
                  // ============================================

                  Text(
                    _money(
                      item.total,
                    ),
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ======================================================
        // TOTALS
        // ======================================================

        Container(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            8,
          ),
          decoration:
          BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerLow,
            border: Border(
              top: BorderSide(
                color:
                Theme.of(context)
                    .dividerColor,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildMoneyRow(
                'Subtotal',
                subtotal,
              ),

              const SizedBox(
                height: 8,
              ),

              _buildMoneyRow(
                'Total',
                total,
                emphasized: true,
              ),
            ],
          ),
        ),

        // ======================================================
        // ERROR
        // ======================================================

        if (_errorMessage !=
            null)
          Padding(
            padding:
            const EdgeInsets
                .fromLTRB(
              20,
              12,
              20,
              0,
            ),
            child:
            _buildErrorMessage(),
          ),

        // ======================================================
        // SAVE BUTTON
        // ======================================================

        Padding(
          padding:
          const EdgeInsets.all(
            20,
          ),
          child: Column(
            children: [
              SizedBox(
                width:
                double.infinity,
                height: 54,
                child:
                FilledButton.icon(
                  onPressed:
                  _isSaving
                      ? null
                      : _generateTicket,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 19,
                    height: 19,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .save_rounded,
                  ),
                  label: Text(
                    _isSaving
                        ? 'GUARDANDO COMPRA...'
                        : 'GUARDAR PARA PAGAR DESPUÉS',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'No se registrará un pago '
                    'en este momento.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // COMPRA REGISTRADA
  // ============================================================


  Widget _buildSuccess(   PosMainController main ) {
    return SingleChildScrollView(
      key: const ValueKey(
        'ticket-success',
      ),
      padding:
      const EdgeInsets.fromLTRB(
        22,
        10,
        22,
        24,
      ),
      child: Column(
        children: [
          _buildDragIndicator(),

          const SizedBox(
            height: 18,
          ),

          // ====================================================
          // SUCCESS ICON
          // ====================================================

          Container(
            width: 68,
            height: 68,
            decoration:
            BoxDecoration(
              color:
              Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 42,
              color:
              Colors.green.shade700,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'Compra guardada',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Pendiente de pago',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.orange.shade800,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // ====================================================
          // PRINCIPAL ID
          // ====================================================

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            decoration:
            BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'N.º DE TICKET',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight
                        .w700,
                    letterSpacing:
                    1.2,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                SelectableText(
                  _ticketNumber,
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    height: 1,
                    fontWeight:
                    FontWeight
                        .w800,
                    letterSpacing: 2,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Indique este número al cliente.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ====================================================
          // INFORMATION MESSAGE
          // ====================================================

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.orange.shade50,
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: Colors
                    .orange.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Icon(
                  Icons
                      .info_outline_rounded,
                  color: Colors
                      .orange.shade800,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    'Cuando el cliente regrese, '
                        'el empleado debe buscar la compra '
                        'usando el N.º de ticket '
                        '$_ticketNumber.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors
                          .orange
                          .shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          // ====================================================
          // PURCHASE INFORMATION
          // ====================================================

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(
              16,
            ),
            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color:
                Theme.of(context)
                    .dividerColor,
              ),
            ),
            child: Column(
              children: [
                // ==============================================
                // STATUS
                // ==============================================

                _buildInformationRow(
                  'Estado',
                  _status,
                ),

                const Divider(
                  height: 22,
                ),

                // ==============================================
                // DATE
                // ==============================================

                _buildInformationRow(
                  'Fecha',
                  _invoiceDate,
                ),

                const Divider(
                  height: 22,
                ),

                // ==============================================
                // INVOICE CODE
                // ==============================================

                _buildInformationRow(
                  'N.º comprobante',
                  _invoiceCode,
                ),

                const Divider(
                  height: 22,
                ),

                // ==============================================
                // ESTABLISHMENT
                // ==============================================

                _buildInformationRow(
                  'Establecimiento',
                  _establishment,
                ),

                const Divider(
                  height: 22,
                ),

                // ==============================================
                // EMISSION POINT
                // ==============================================

                _buildInformationRow(
                  'Punto de emisión',
                  _emissionPoint,
                ),

                const Divider(
                  height: 22,
                ),

                // ==============================================
                // SUBTOTAL
                // ==============================================

                _buildInformationRow(
                  'Subtotal',
                  _money(
                    _subtotal,
                  ),
                ),

                // ==============================================
                // TAX
                // ==============================================

                if (_taxes > 0) ...[
                  const Divider(
                    height: 22,
                  ),

                  _buildInformationRow(
                    'Impuestos',
                    _money(
                      _taxes,
                    ),
                  ),
                ],

                // ==============================================
                // DISCOUNT
                // ==============================================

                if (_discount >
                    0) ...[
                  const Divider(
                    height: 22,
                  ),

                  _buildInformationRow(
                    'Descuento',
                    '- ${_money(_discount)}',
                  ),
                ],

                const Divider(
                  height: 22,
                ),

                // ==============================================
                // TOTAL
                // ==============================================

                _buildInformationRow(
                  'Total',
                  _money(
                    _total,
                  ),
                  emphasized: true,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          // ====================================================
          // ACTIONS
          // ====================================================

          Row(
            children: [
              // =================================================
              // PRINT
              // =================================================

              Expanded(
                child: SizedBox(
                  height: 52,
                  child:
                  OutlinedButton.icon(
                    onPressed:
                    _isPrinting
                        ? null
                        : _printTicket,
                    icon: _isPrinting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Icon(
                      Icons
                          .print_rounded,
                    ),
                    label: Text(
                      _isPrinting
                          ? 'IMPRIMIENDO...'
                          : 'IMPRIMIR',
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // =================================================
              // FINISH
              // =================================================

              Expanded(
                child: SizedBox(
                  height: 52,
                  child:
                  FilledButton.icon(
                    onPressed:
                    _isPrinting
                        ? null
                        : () => _closeCompletedTicket(widget.main),
                    icon: const Icon(
                      Icons
                          .check_rounded,
                    ),
                    label: const Text(
                      'FINALIZAR',
                      style: TextStyle(
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            'Al finalizar se cerrará este ticket '
                'y podrá iniciar una nueva compra.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
              Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DRAG INDICATOR
  // ============================================================

  Widget _buildDragIndicator() {
    return Center(
      child: Container(
        margin:
        const EdgeInsets.only(
          top: 2,
        ),
        width: 44,
        height: 5,
        decoration:
        BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MONEY ROW
  // ============================================================

  Widget _buildMoneyRow(
      String label,
      double value, {
        bool emphasized = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize:
              emphasized
                  ? 16
                  : 14,
              fontWeight:
              emphasized
                  ? FontWeight
                  .w700
                  : FontWeight
                  .w500,
            ),
          ),
        ),

        Text(
          _money(value),
          style: TextStyle(
            fontSize:
            emphasized
                ? 20
                : 15,
            fontWeight:
            emphasized
                ? FontWeight
                .w800
                : FontWeight
                .w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _buildInformationRow(
      String label,
      String value, {
        bool emphasized = false,
      }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color:
              Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.right,
            style: TextStyle(
              fontSize:
              emphasized
                  ? 18
                  : 14,
              fontWeight:
              emphasized
                  ? FontWeight
                  .w800
                  : FontWeight
                  .w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        13,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.red.shade50,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
          Colors.red.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .error_outline_rounded,
            color:
            Colors.red.shade700,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors
                    .red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}