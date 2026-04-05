import 'package:flutter/material.dart';

import '../services/pos_ticket_calculator.dart';
import '../widgets/models/pos_product_item.dart';

String ticketIdNow() => DateTime.now().microsecondsSinceEpoch.toString();

class PosTicketState extends ChangeNotifier {
  String? currentTicketId;
  String? currentCustomerId;
  String? currentTicketDescription;

  final List<PostTicketItem> _items = [];

  List<PostTicketItem> get items => List.unmodifiable(_items);

  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;

  double get subtotal => _subtotal;
  double get subtotalTax => _tax;
  double get total => _total;

  PostTicketItem? editingItem;
  PostTicketItem? optionsItem;

  void addProduct(PosProductItem product) {
    _ensureTicket();
    final idx = _items.indexWhere((i) => i.productItem.id == product.id);
    if (idx == -1) {
      _items.add(
        PosTicketCalculator.buildNewItem(product: product),
      );
    } else {
      _items[idx] = PosTicketCalculator.rebuildWithQty(
        item: _items[idx],
        newQty: _items[idx].amount + 1,
      );
    }

    _recalculate();
    notifyListeners();
  }

  void changeItemQty(String productId, int newQty) {
    if (newQty <= 0) {
      _items.removeWhere((i) => i.productItem.id == productId);
      _recalculate();
      notifyListeners();
      return;
    }

    final idx = _items.indexWhere((i) => i.productItem.id == productId);
    if (idx == -1) return;

    _items[idx] = PosTicketCalculator.rebuildWithQty(
      item: _items[idx],
      newQty: newQty,
    );

    _recalculate();
    notifyListeners();
  }

  void decreaseItem(PostTicketItem item) {
    changeItemQty(item.productItem.id, item.amount - 1);
  }

  void increaseItem(PostTicketItem item) {
    changeItemQty(item.productItem.id, item.amount + 1);
  }

  void removeItem(PostTicketItem item) {
    _items.removeWhere((i) => i.productItem.id == item.productItem.id);
    _recalculate();
    notifyListeners();
  }

  PostTicketItem? getItemByProductId(String productId) {
    try {
      return _items.firstWhere((i) => i.productItem.id == productId);
    } catch (_) {
      return null;
    }
  }

  void editTicketItem(PostTicketItem item) {
    editingItem = item;
    notifyListeners();
  }

  void openTicketItemOptions(PostTicketItem item) {
    optionsItem = item;
    notifyListeners();
  }

  void saveTicket() {
    _items.clear();
    currentTicketId = ticketIdNow();
    _recalculate();
    notifyListeners();
  }

  void _ensureTicket() {
    currentTicketId ??= ticketIdNow();
  }

  void _recalculate() {
    final result = PosTicketCalculator.calculate(_items);
    _subtotal = result.subtotal;
    _tax = result.tax;
    _total = result.total;
  }


  bool applyCoupon(PosCoupon coupon) {
    if (coupon.isExpired) return false;

    final idx = _items.indexWhere(
          (i) => i.productItem.id == coupon.productId,
    );

    if (idx == -1) return false;

    final item = _items[idx];

    /// 🔥 calcular descuento dinámico
    double discountAmount;
    discountAmount = item.unitPrice * (coupon.discount / 100);

    /// 🔥 evitar negativos
    double newTotal = (item.total - discountAmount).clamp(0, double.infinity);

    /// 🔥 usar copyWith (NO crear manual)
    final newItem = item.copyWith(
      total: newTotal,
      discount: item.discount + discountAmount,
      coupon: coupon, // 🔥 guardamos TODO el objeto
    );

    _items[idx] = newItem;

    _recalculate();
    notifyListeners();

    return true;
  }
  void removeCoupon(PostTicketItem item) {
    final index = _items.indexOf(item);
    if (index == -1) return;

    /// 🔥 restaurar total (IMPORTANTE)
    final restoredTotal = item.total + item.couponDiscount;

    _items[index] = item.copyWith(
      total: restoredTotal,
      discount: item.discount - item.couponDiscount,
      coupon: null,
      couponDiscount: 0,
    );

    _recalculate();
    notifyListeners();
  }
}