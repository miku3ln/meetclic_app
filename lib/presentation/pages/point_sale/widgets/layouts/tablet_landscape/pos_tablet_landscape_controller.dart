import 'package:flutter/material.dart';
import '../../../models/pos_payment_method.dart';
import '../../models/pos_product_item.dart';

String _ticketIdNow() => DateTime.now().microsecondsSinceEpoch.toString();

class PosTabletLandscapeController extends ChangeNotifier {
  // UI triggers
  VoidCallback? onRequestOpenShift;

  // Shift
  bool isShiftOpen = false;

  static const String kAll = 'all';
  static const String kGrid = 'grid';

  // (1) Product Categories (dropdown)
  List<PosCategoryItem> productCategories = const [];
  String? selectedProductCategoryId;

  // (2) Menu Categories (bottom bar)
  List<PosCategoryItem> menuCategories = const [];
  String? selectedMenuCategoryId;

  // Products
  List<PosProductItem> allProducts = const [];
  List<PosProductItem> products = const [];

  // (3) Search
  String query = '';

  void init({
    required List<PosProductItem> initialProducts,
    required List<PosCategoryItem> initialProductCategories,
    required List<PosCategoryItem> initialMenuCategories,
    String? initialSelectedProductCategoryId,
    String? initialSelectedMenuCategoryId,
  }) {
    allProducts = initialProducts;
    productCategories = initialProductCategories;
    menuCategories = initialMenuCategories;

    selectedProductCategoryId =
        initialSelectedProductCategoryId ??
        (productCategories.isNotEmpty ? productCategories.first.id : null);

    selectedMenuCategoryId =
        initialSelectedMenuCategoryId ??
        (menuCategories.isNotEmpty ? menuCategories.first.id : null);

    _applyFilters();
    notifyListeners();
  }

  // (1) Dropdown change
  void onProductCategoryChanged(String? id) {
    if (id == null) return;
    selectedProductCategoryId = id;
    _applyFilters();
    notifyListeners();
  }

  // (2) Bottom bar tap
  void onMenuCategoryTap(String id) {
    selectedMenuCategoryId = id;
    _applyFilters();
    notifyListeners();
  }

  // (3) Search
  void onSearchChanged(String q) {
    query = q;
    _applyFilters();
    notifyListeners();
  }

  void onSearchSubmitted(String q) {
    query = q;
    _applyFilters();
    notifyListeners();
  }

  // Shift
  void onOpenShiftTap() => onRequestOpenShift?.call();

  Future<void> openShift(double initialCash) async {
    isShiftOpen = true;
    notifyListeners();
  }

  // Filters (1 + 2 + 3)
  void _applyFilters() {
    final q = query.trim().toLowerCase();
    Iterable<PosProductItem> result = allProducts;

    final pc = selectedProductCategoryId;
    if (pc != null && pc != kAll) {
      result = result.where((p) => p.productCategoryId == pc);
    }

    final mc = selectedMenuCategoryId;
    if (mc != null && mc != kAll && mc != kGrid) {
      result = result.where((p) => p.menuCategoryId == mc);
    }

    if (q.isNotEmpty) {
      result = result.where((p) => p.name.toLowerCase().contains(q));
    }

    products = result.toList(growable: false);
  }

  void onSave() {
    // Guardar ticket (borrador) / guardar cambios
    // Recomendación: si no hay turno abierto, no guardes venta.
    if (!isShiftOpen) {
      debugPrint('onSave -> turno cerrado (no se puede guardar)');
      // Si quieres: pedir abrir turno
      onRequestOpenShift?.call();
      return;
    }

    debugPrint('onSave -> guardar ticket');
    // TODO: tu lógica real (persistir ticket en memoria/db)
    notifyListeners();
  }

  void onPay() {
    // Cobrar (proceso de pago)
    if (!isShiftOpen) {
      debugPrint('onPay -> turno cerrado (no se puede cobrar)');
      onRequestOpenShift?.call();
      return;
    }

    debugPrint('onPay -> cobrar');
    // TODO: abrir modal de pago / ir a pantalla de pago
    notifyListeners();
  }

  // -------------------------
  // ✅ TICKET STATE (para PosRightPanel)
  // -------------------------
  String? currentTicketId;
  String? currentCustomerId;
  String? currentTicketDescription;

  final List<PostTicketItem> _ticketItems = [];

  List<PostTicketItem> get ticketItems => List.unmodifiable(_ticketItems);

  double _subtotal = 0;
  double _subtotalTax = 0;
  double _total = 0;

  double get subtotal => _subtotal;

  double get subtotalTax => _subtotalTax;

  double get total => _total;

  // -------------------------
  // ✅ PRODUCT TAP => afecta PosRightPanel
  // -------------------------
  void onProductTap(PosProductItem product) {
    _ensureTicket();
    final idx = _ticketItems.indexWhere((i) => i.productItem.id == product.id);

    if (idx == -1) {
      final qty = 1;
      final unit = product.unitPrice;
      final sub = unit * qty;
      final tax = _calcTax(sub, product.taxPercentage);
      final tot = sub + tax;

      _ticketItems.add(
        PostTicketItem(
          productItem: product,
          amount: qty,
          unitPrice: unit,
          subtotal: sub,
          tax: tax,
          total: tot,
        ),
      );
    } else {
      final old = _ticketItems[idx];
      final qty = old.amount + 1;
      final unit = old.unitPrice; // o product.unitPrice
      final sub = unit * qty;
      final tax = _calcTax(sub, product.taxPercentage);
      final tot = sub + tax;

      _ticketItems[idx] = PostTicketItem(
        productItem: old.productItem,
        amount: qty,
        unitPrice: unit,
        subtotal: sub,
        tax: tax,
        total: tot,
        description: old.description,
        discount: old.discount,
      );
    }

    _recalculateTotals();
    notifyListeners();
  }

  // ✅ Cambiar cantidad desde el panel derecho
  void changeItemQty(String productId, int newQty) {
    if (newQty <= 0) {
      final item = getItemByProductId(productId);
      if (item != null) {
        removeItem(item);
      }
      return;
    }
    final idx = _ticketItems.indexWhere((i) => i.productItem.id == productId);
    if (idx == -1) return;

    final old = _ticketItems[idx];
    final unit = old.unitPrice;
    final sub = unit * newQty;
    final tax = _calcTax(sub, old.productItem.taxPercentage);
    final tot = sub + tax;

    _ticketItems[idx] = PostTicketItem(
      productItem: old.productItem,
      amount: newQty,
      unitPrice: unit,
      subtotal: sub,
      tax: tax,
      total: tot,
      description: old.description,
      discount: old.discount,
    );

    _recalculateTotals();
    notifyListeners();
  }
  PostTicketItem? getItemByProductId(String productId) {
    try {
      return _ticketItems.firstWhere(
            (i) => i.productItem.id == productId,
      );
    } catch (e) {
      return null; // si no existe
    }
  }
  void removeItem (PostTicketItem item) {
    _ticketItems.removeWhere((i) => i.productItem.id == item.productItem.id);
    _recalculateTotals();
    notifyListeners();
  }

  void saveTicket() {
    _ticketItems.clear();
    _recalculateTotals();
    // opcional: generar nuevo ticket id
    currentTicketId = _ticketIdNow();
    notifyListeners();
  }

  // -------------------------
  // ✅ HELPERS
  // -------------------------
  void _ensureTicket() {
    currentTicketId ??= _ticketIdNow();
  }

  double _calcTax(double subtotal, double taxPercentage) {
    // porcentaje (ej 16) => 0.16
    return subtotal * (taxPercentage / 100.0);
  }

  void _recalculateTotals() {
    double sub = 0;
    double tax = 0;
    double tot = 0;

    for (final i in _ticketItems) {
      sub += i.subtotal;
      tax += i.tax;
      tot += i.total;
    }

    _subtotal = sub;
    _subtotalTax = tax;
    _total = tot;
  }

  PosPaymentMethod _paymentMethod = PosPaymentMethod.cash;

  PosPaymentMethod get paymentMethod => _paymentMethod;

  void setPaymentMethod(PosPaymentMethod value) {
    if (_paymentMethod == value) return; // evita rebuild innecesario
    _paymentMethod = value;
    notifyListeners();
  }


  bool get isCash => _paymentMethod == PosPaymentMethod.cash;
  bool get isCard => _paymentMethod == PosPaymentMethod.card;
  bool get isQr => _paymentMethod == PosPaymentMethod.qr;

  // ejemplo: si quieres un "code" para backend
  String get paymentMethodCode {
    switch (_paymentMethod) {
      case PosPaymentMethod.cash:
        return 'CASH';
      case PosPaymentMethod.card:
        return 'CARD';
      case PosPaymentMethod.qr:
        return 'QR';
    }
  }

  // ✅ Variables (si quieres controlar modales desde la UI)
  PostTicketItem? editingItem;
  PostTicketItem? optionsItem;

// ------------------------------------
// ✅ TICKET ACTIONS (Right Panel)
// ------------------------------------
  void decreaseItem(PostTicketItem item) {
    final newQty = item.amount - 1;
    changeItemQty(item.productItem.id, newQty);
  }

  void increaseItem(PostTicketItem item) {
    final newQty = item.amount + 1;
    changeItemQty(item.productItem.id, newQty);
  }

// Abre edición (por ejemplo: nota/observación, descuento, cambiar precio, etc.)
  void editTicketItem(PostTicketItem item) {
    editingItem = item;
    // Si usas modal en el panel:
    // onRequestEditTicketItem?.call(item);  // (si quieres callback)
    notifyListeners();
  }

// Abre opciones (por ejemplo: eliminar, duplicar, mover, etc.)
  void openTicketItemOptions(PostTicketItem item) {
    optionsItem = item;
    // Si usas modal en el panel:
    // onRequestOpenTicketItemOptions?.call(item); // (si quieres callback)
    notifyListeners();
  }
}
