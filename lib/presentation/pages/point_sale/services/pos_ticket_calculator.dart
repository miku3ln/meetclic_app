

import '../widgets/models/pos_product_item.dart';

class PosTicketTotals {
  final double subtotal;
  final double tax;
  final double total;

  const PosTicketTotals({
    required this.subtotal,
    required this.tax,
    required this.total,
  });
}

class PosTicketCalculator {
  static PostTicketItem buildNewItem({
    required PosProductItem product,
  }) {
    const qty = 1;
    final unit = product.unitPrice;
    final sub = unit * qty;
    final tax = _calcTax(sub, product.taxPercentage);

    return PostTicketItem(
      productItem: product,
      amount: qty,
      unitPrice: unit,
      subtotal: sub,
      tax: tax,
      total: sub + tax,
    );
  }

  static PostTicketItem rebuildWithQty({
    required PostTicketItem item,
    required int newQty,
  }) {
    final sub = item.unitPrice * newQty;
    final tax = _calcTax(sub, item.productItem.taxPercentage);

    return PostTicketItem(
      productItem: item.productItem,
      amount: newQty,
      unitPrice: item.unitPrice,
      subtotal: sub,
      tax: tax,
      total: sub + tax,
      description: item.description,
      discount: item.discount,
    );
  }

  static PosTicketTotals calculate(List<PostTicketItem> items) {
    double sub = 0;
    double tax = 0;
    double total = 0;

    for (final item in items) {
      sub += item.subtotal;
      tax += item.tax;
      total += item.total;
    }

    return PosTicketTotals(
      subtotal: sub,
      tax: tax,
      total: total,
    );
  }

  static double _calcTax(double subtotal, double taxPercentage) {
    return subtotal * (taxPercentage / 100.0);
  }
}