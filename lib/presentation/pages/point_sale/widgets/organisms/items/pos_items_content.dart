import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_discounts_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_modifiers_management_section.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../state/pos_items_controller.dart';
import 'dart:async';

import '../../sections/items/pos_items_management_section.dart';

class PosItemsContent extends StatelessWidget {
  const PosItemsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final section = context.watch<PosItemsController>().section;
    return Container(
      color: Colors.white,
      child: Column(children: [Expanded(child: _buildSection(section))]),
    );
  }

  Widget _buildSection(PosItemsSection s) {
    switch (s) {
      case PosItemsSection.items:
        return const PosItemsManagementSection();
      case PosItemsSection.categories:
        return const PosCategoriesManagementSection();
      case PosItemsSection.modifiers:
        return const PosModifiersManagementSection();
      case PosItemsSection.discounts:
        return const PosDiscountsManagementSection();
    }
  }
}

class FakeCategoriesApi {
  final int total;

  const FakeCategoriesApi({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final start = (current - 1) * rowCount;
    final end = (start + rowCount) > total ? total : (start + rowCount);

    if (start >= total) {
      return PaginatedResponse(
        current: current,
        rowCount: rowCount,
        rows: const [],
        total: total,
      );
    }

    final rows = List.generate(end - start, (index) {
      final itemNumber = start + index + 1;

      return GenericListItem<Map<String, dynamic>>(
        id: itemNumber,
        title: 'Categoria $itemNumber',
        subtitle: 'Estado: activa',
        description: 'Descripcion de categoria #$itemNumber',
        image: 'https://meetclic.com/public//uploads/business/gamification/default/tinkuy-encuentro-08.jpg',
        businessId: '1',
        countData: 50 + (start + index),
      );
    });

    return PaginatedResponse(
      current: current,
      rowCount: rowCount,
      rows: rows,
      total: total,
    );
  }
}

class FakeItemsApi {
  final int total;

  const FakeItemsApi({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final start = (current - 1) * rowCount;
    final end = (start + rowCount) > total ? total : (start + rowCount);

    if (start >= total) {
      return PaginatedResponse(
        current: current,
        rowCount: rowCount,
        rows: const [],
        total: total,
      );
    }

    final rows = List.generate(end - start, (index) {
      final itemNumber = start + index + 1;

      return GenericListItem<Map<String, dynamic>>(
        id: itemNumber,
        title: 'Producto $itemNumber',
        subtitle: 'Estado: activa',
        description: 'Impresora de recibos y cocina #$itemNumber',
        image: null,
        data: {
          'id': itemNumber,
          'source': '/uploads/printers/default/printer-$itemNumber.png',
          'title': 'Impresora $itemNumber',
          'subtitle': 'Estado: activa',
          'description': 'Impresora simulada #$itemNumber',
          'state': 'ACTIVE',
          'business_name': 'MEETCLIC',
          'points': 40,
        },
      );
    });

    return PaginatedResponse(
      current: current,
      rowCount: rowCount,
      rows: rows,
      total: total,
    );
  }
}
