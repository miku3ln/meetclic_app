import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_discounts_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_modifiers_management_section.dart';
import 'package:provider/provider.dart';
import '../../../../../../domain/services/session_service.dart';
import '../../../../../../infrastructure/config/server_config.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/utils/util_common.dart';
import '../../../state/pos_items_controller.dart';
import 'dart:async';

import '../../sections/items/pos_items_management_section.dart';

class PosItemsContent extends StatelessWidget {
  const PosItemsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final section = context
        .watch<PosItemsController>()
        .section;
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
        image:
        'https://meetclic.com/public//uploads/business/gamification/default/tinkuy-encuentro-08.jpg',
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

class PosItemsManagementApi {
  final int total;

  final api = PaginatedApiService(baseUrl: ServerConfig.baseUrl);

  PosItemsManagementApi({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
  }) {
    return api.fetchPage<Map<String, dynamic>>(
      endpoint: 'pointsales/products-sales',
      queryParams: {
        'current': '$current',
        'rowCount': '$rowCount',
        'searchPhrase': '',
        'business_id': '1',
      },
      totalKey: 'total',
      rowsKey: 'rows',
      // 🔥 AQUÍ está toda tu lógica real ahora
      mapper: (json) {
        final stock = json['stock'] ?? {};
        final price = json['price'] ?? {};

        return GenericListItem<Map<String, dynamic>>(
          id: json['id'],
          title: json['name'] ?? '',
          subtitle: 'Stock: ${stock['quantity']} ${stock['unit']}',
          description: json['category'] ?? '',
          image: json['source'],
          data: json,
        );
      },
    );
  }
}
