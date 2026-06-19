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
import 'package:intl/intl.dart';

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
    required String searchPhrase,

    required int rowCount,
  }) async {


    final token = SessionService().apiToken;
    final businessId=SessionService().businessId;
    final uri = Uri.parse('${ServerConfig.baseUrl}/pointsales/products-sales')//POS-PRODUCTS -INIT-ONE
        .replace(
      queryParameters: {
        'current': current.toString(),
        'rowCount': rowCount.toString(),
        'searchPhrase': searchPhrase,
        'business_id': businessId.toString(),
      },
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token!}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      return const PaginatedResponse<
          GenericListItem<Map<String, dynamic>>>(
        current: 1,
        rowCount: 0,
        rows: [],
        total: 0,
      );
    }
    final data = jsonDecode(response.body);

    final rows = (data['rows'] as List).map((json) {
      final stock = json['stock'] ?? {};

      return GenericListItem<Map<String, dynamic>>(
        id: json['id'],
        title: json['name'] ?? '',
        subtitle: 'Stock: ${stock['quantity']} ${stock['unit']}',
        description: json['category'] ?? '',
        image: json['source'],
        data: json,
      );
    }).toList();

    return PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
      current: data['current'] ?? current,
      rowCount: data['rowCount'] ?? rowCount,
      rows: rows,
      total: data['total'] ?? 0,
    );

  }
}

class PosTicketManagementApi {
  final int total;

  final api = PaginatedApiService(baseUrl: ServerConfig.baseUrl);

  PosTicketManagementApi({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
    String? searchCode,
    DateTime? date,
  }) {
    final businessId = SessionService().businessId;

    return api.fetchPage<Map<String, dynamic>>(
      endpoint: 'pointsales/tickets-sales',
      queryParams: {
        'current': '$current',
        'rowCount': '$rowCount',
        'searchPhrase': '',
        'business_id':businessId!,
      },
      totalKey: 'total',
      rowsKey: 'rows',
      // 🔥 AQUÍ está toda tu lógica real ahora
      mapper: (json) {
        final payments=json['payments'];
        final payment=payments[0];
        final header = json['header'];
        final meta = json['meta'];
        final amount =  double.parse(payment['amount']);
        final lineTotal=amount;
        final code = '#${header['id']}';
        final hour = '22:15';

        final paymentMethod=payment['payment_method'];
        final dateInvoice=DateTime.parse(header['invoice_date']);

        final dateInvoiceString='Fecha: ${DateFormat('dd/MM/yyyy HH:mm a').format(dateInvoice)}';
        return GenericListItem<Map<String, dynamic>>(
          id: header['id'],
          title:lineTotal.toString(),
          subtitle: dateInvoiceString,
          description: paymentMethod,
          image: null,
          data: {
            'receiptNumber': '${ header['id']}',
            'employee': 'Trece',
            'tpv': 'TPV 1',
            'orderType': 'Para Servirse',
            'productName': 'Mixto ${header['id']}',
            'quantity': 1,
            'unitPrice': (amount),
            'lineTotal': (lineTotal),
            'total': (amount),
            'paymentMethod': paymentMethod,
            'paymentAmount': (amount),
            'code': code,
            'hour': hour,
            'date':dateInvoice,
            'all': json,
          },
        );
      },
    );
  }
}
