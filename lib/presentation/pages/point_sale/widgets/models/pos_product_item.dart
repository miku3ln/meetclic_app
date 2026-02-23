import 'package:flutter/material.dart';

class PosProductItem {
  final String id;
  final String name;

  /// puede ser url (network) o asset. Por ahora lo tratamos como url.
  final String? imageUrl;

  /// fallback background si no hay imagen
  final Color? placeholderColor;

  /// estilo por item
  final Color? titleColor;

  // ids (relación)
  final String productCategoryId; // (1) dropdown arriba
  final String menuCategoryId; // (2) barra abajo
  final double unitPrice;
  final double taxPercentage;

  const PosProductItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.placeholderColor,
    this.titleColor,
    required this.productCategoryId,
    required this.menuCategoryId,
    required this.taxPercentage,
    required this.unitPrice,
  });
}

class PosBaseItem {
  final String id;
  final String value;
  final String description;

  const PosBaseItem({
    required this.id,
    required this.value,
    this.description = '',
  });
}

class PosCategoryItem extends PosBaseItem {
  const PosCategoryItem({
    required super.id,
    required super.value,
    super.description = '',
  });
}

class PostTicketHeader {
  final String id;
  final double subtotal;
  final double subtotalTax;
  final double total;
  final String? description;
  final String? customerId;
  final String? dateCurrent;

  final List<PostTicketItem> items;

  const PostTicketHeader({
    required this.id,
    required this.subtotal,
    required this.subtotalTax,
    required this.total,
    this.customerId,
    required this.dateCurrent,
    this.description,
    required this.items,
  });
}

class PostTicketItem {
  final PosProductItem productItem;
  final double subtotal;
  final double tax;
  final double total;
  final String? description;
  final double unitPrice;


  final int amount;
  final double discount;

  const PostTicketItem({
    required this.productItem,
    required this.tax,
    required this.total,
    required this.amount,
    required this.subtotal,
    required this.unitPrice,

    this.description,
    this.discount = 0,
  });
}
