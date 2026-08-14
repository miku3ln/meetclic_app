import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_discounts_management_section.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_modifiers_management_section.dart';
import '../../../../../../domain/services/session_service.dart';
import '../../../../../../infrastructure/config/server_config.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/utils/util_common.dart';
import '../../../state/pos_items_controller.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../sections/items/pos_items_management_section.dart';

class PosItemsContent extends StatelessWidget {
  final PosItemsSection section;
  const PosItemsContent({super.key,required this.section});

  @override
  Widget build(BuildContext context) {

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
      case PosItemsSection.subcategories:
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
    required String searchPhrase,
    required int rowCount,
  }) async {
    final token = SessionService().apiToken;
    final businessId = SessionService().businessId;
    final uriManagement =
        '${ServerConfig.baseUrl}/pointsales/category-by-business';
    final uri =
        Uri.parse(uriManagement) //POS-PRODUCTS -INIT-ONE
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
      return const PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
        current: 1,
        rowCount: 0,
        rows: [],
        total: 0,
      );
    }
    final data = jsonDecode(response.body);

    final rows = (data['rows'] as List).map((json) {
      return GenericListItem<Map<String, dynamic>>(
        id: json['id'],
        title: json['value'],
        subtitle: json['subtitle'],
        description: json['description'] ?? '',
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

class PosItemsManagementRepository {
  final int total;

  final api = PaginatedApiService(baseUrl: ServerConfig.baseUrl);

  PosItemsManagementRepository({required this.total});

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required String searchPhrase,
    required int rowCount,
  }) async {
    final token = SessionService().apiToken;
    final businessId = SessionService().businessId;
    final uriManagement =
        '${ServerConfig.baseUrl}/pointsales/products-management';
    final uri =
        Uri.parse(uriManagement) //POS-PRODUCTS -INIT-ONE
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
      return const PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
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
    return SafeExecutor.run(
      () async {
        final token = SessionService().apiToken;
        final businessId = SessionService().businessId;

        final uri =
            Uri.parse(
              '${ServerConfig.baseUrl}/pointsales/tickets-sales',
            ).replace(
              queryParameters: {
                'current': '$current',
                'rowCount': '$rowCount',
                'searchPhrase': searchCode ?? '',
                'business_id': businessId,
                if (date != null) 'date': date.toIso8601String(),
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
          return PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
            current: current,
            rowCount: rowCount,
            rows: [],
            total: 0,
          );
        }

        final data = jsonDecode(response.body);

        final List rows = data['rows'] ?? [];

        final result = rows.map<GenericListItem<Map<String, dynamic>>>((json) {
          final header = json['header'] ?? {};
          final meta = json['meta'] ?? {};

          final List payments = json['payments'] ?? [];
          final List details = json['details'] ?? [];

          // ------------------------------------------------------------
          // PAGO
          // ------------------------------------------------------------

          final payment = payments.isNotEmpty
              ? payments.first
              : <String, dynamic>{};

          final amount =
              double.tryParse(payment['amount']?.toString() ?? '0') ?? 0;

          final paymentMethod =
              payment['payment_method']?.toString() ?? 'No especificado';

          // ------------------------------------------------------------
          // FECHA
          // ------------------------------------------------------------

          final dateInvoice =
              DateTime.tryParse(header['invoice_date']?.toString() ?? '') ??
              DateTime.now();

          final dateInvoiceString = DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(dateInvoice);

          final hour = DateFormat('HH:mm').format(dateInvoice);

          // ------------------------------------------------------------
          // TIPO DE SERVICIO
          // API:
          // DINE_IN
          // TAKEAWAY
          // ------------------------------------------------------------

          final serviceType = meta['service_type']?.toString() ?? 'TAKEAWAY';

          final String orderType;
          IconData orderIcon = Icons.shopping_bag;

          switch (serviceType) {
            case 'DINE_IN':
              orderType = 'Para Servirse';
              orderIcon = Icons.restaurant;
              break;

            case 'TAKEAWAY':
              orderType = 'Para Llevar';
              orderIcon = Icons.shopping_bag;
              break;

            default:
              orderType = 'Para Servirse';
              orderIcon = Icons.delivery_dining;
          }

          // ------------------------------------------------------------
          // PRODUCTOS
          // ------------------------------------------------------------

          final products = details.map<Map<String, dynamic>>((detail) {
            final quantity =
                double.tryParse(detail['quantity']?.toString() ?? '0') ?? 0;

            final unitPrice =
                double.tryParse(detail['unit_price']?.toString() ?? '0') ?? 0;

            final total =
                double.tryParse(detail['total']?.toString() ?? '0') ??
                (quantity * unitPrice);

            final productType = detail['product_type']?.toString() ?? 'UNIT';

            return {
              'id': detail['id'],
              'productId': detail['product_id'],

              // Datos para mostrar
              'name': detail['name']?.toString() ?? 'Producto',
              'code': detail['code']?.toString() ?? '',
              'quantity': quantity,
              'unitPrice': unitPrice,
              'total': total,

              // API
              'productType': productType,

              // Datos traducidos
              'productTypeName': productType == 'UNIT' ? 'Unidad' : productType,

              // Mantener información original
              'all': detail,
            };
          }).toList();

          // ------------------------------------------------------------
          // PRODUCTO PRINCIPAL PARA LA TARJETA
          // ------------------------------------------------------------

          final firstProduct = products.isNotEmpty
              ? products.first
              : <String, dynamic>{
                  'name': 'Sin productos',
                  'quantity': 0,
                  'unitPrice': 0.0,
                  'total': 0.0,
                };

          final productName =
              firstProduct['name']?.toString() ?? 'Sin productos';

          final quantity = (firstProduct['quantity'] as num?)?.toDouble() ?? 0;

          final unitPrice =
              (firstProduct['unitPrice'] as num?)?.toDouble() ?? 0;

          // ------------------------------------------------------------
          // TOTAL
          // ------------------------------------------------------------

          final total =
              double.tryParse(header['subtotal']?.toString() ?? '') ??
              products.fold<double>(
                0,
                (sum, product) =>
                    sum + ((product['total'] as num?)?.toDouble() ?? 0),
              );

          // ------------------------------------------------------------
          // DATOS DE FACTURA
          // ------------------------------------------------------------

          final receiptNumber = header['id']?.toString() ?? '0';

          final invoiceCode =
              header['invoice_code']?.toString() ?? receiptNumber;

          final ticketCode =
              meta['ticket_code']?.toString() ?? 'TICKET-$receiptNumber';

          // ------------------------------------------------------------
          // DATOS QUE NO VIENEN DEL API
          // ------------------------------------------------------------

          const employee = 'Trece';
          const tpv = 'TPV 1';

          // ------------------------------------------------------------
          // ITEM FINAL
          // ------------------------------------------------------------
          final code = '#${header['id']}';
          return GenericListItem<Map<String, dynamic>>(
            id: header['id'] ?? 0,

            // Ejemplo:
            // $0,25
            title: NumberFormat.currency(
              locale: 'es_EC',
              symbol: r'$',
              decimalDigits: 2,
            ).format(total),

            subtitle: dateInvoiceString,

            // Ejemplo:
            // DEPOSITO EN CUENTA (CORRIENTE/AHORROS)
            description: paymentMethod,

            image: null,

            data: {
              // ========================================================
              // INFORMACIÓN DEL COMPROBANTE
              // ========================================================
              'receiptNumber': receiptNumber,
              'invoiceCode': invoiceCode,
              'ticketCode': ticketCode,

              // ========================================================
              // INFORMACIÓN DEL EMPLEADO / TPV
              // ========================================================
              'employee': employee,
              'tpv': tpv,

              // ========================================================
              // TIPO DE PEDIDO
              // ========================================================
              'serviceType': serviceType,
              'orderType': orderType,
              'orderIcon': orderIcon,

              // ========================================================
              // PRODUCTO PRINCIPAL
              // ========================================================
              'productName': productName,
              'quantity': quantity,
              'unitPrice': unitPrice,
              'lineTotal': total,

              // ========================================================
              // TODOS LOS PRODUCTOS
              // ========================================================
              'products': products,

              // ========================================================
              // TOTALES
              // ========================================================
              'subtotal':
                  double.tryParse(header['subtotal']?.toString() ?? '0') ?? 0,

              'discount':
                  double.tryParse(
                    header['discount_value']?.toString() ?? '0',
                  ) ??
                  0,

              'taxes':
                  double.tryParse(header['value_taxes']?.toString() ?? '0') ??
                  0,

              'total': total,

              // ========================================================
              // PAGO
              // ========================================================
              'paymentMethod': paymentMethod,
              'paymentAmount': amount,
              'paymentProvider': payment['provider']?.toString() ?? '',
              'paymentReference': payment['reference']?.toString() ?? '',

              // ========================================================
              // FECHA
              // ========================================================
              'date': dateInvoice,
              'dateString': dateInvoiceString,
              'hour': hour,

              // ========================================================
              // ESTADO
              // ========================================================
              'status': _mapInvoiceStatus(header['status']?.toString()),

              'statusName': _mapInvoiceStatus(header['status']?.toString()),

              // ========================================================
              // INFORMACIÓN ORIGINAL
              // ========================================================
              'all': json,
            },
          );
        }).toList();

        return PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
          current: current,
          rowCount: rowCount,
          rows: result,
          total: data['total'] ?? result.length,
        );
      },
      PaginatedResponse<GenericListItem<Map<String, dynamic>>>(
        current: current,
        rowCount: rowCount,
        rows: [],
        total: 0,
      ),
    );
  }

  String _mapInvoiceStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Pendiente';

      case 'ISSUED':
        return 'Emitida';

      case 'COLLECTED':
        return 'Cobrado';

      case 'CANCELED':
        return 'Anulada';

      case 'ELECTRONIC_REJECTED':
        return 'Rechazada electrónicamente';

      case 'ELECTRONIC_ISSUED':
        return 'Emitida electrónicamente';

      default:
        return 'Desconocido';
    }
  }
}
