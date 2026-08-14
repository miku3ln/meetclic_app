import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../shared/pagination_response.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_receipts_controller.dart';
import '../../organisms/receipts/receipt_detail_card_buttons_manager.dart';

class PosReceiptsRegisterView extends StatelessWidget {
  const PosReceiptsRegisterView({super.key});

  void _printReceipt(GenericListItem<Map<String, dynamic>>? receipt) {
    debugPrint('Imprimir comprobante: ${receipt?.id}');
  }

  void _downloadReceiptPdf(GenericListItem<Map<String, dynamic>>? receipt) {
    debugPrint('Descargar PDF: ${receipt?.id}');
  }

  String _buildWhatsAppReceipt(GenericListItem<Map<String, dynamic>>? receipt) {
    final data = receipt?.data ?? {};

    final products = data['products'] is List
        ? List<Map<String, dynamic>>.from(
      (data['products'] as List).map(
            (item) => Map<String, dynamic>.from(item),
      ),
    )
        : <Map<String, dynamic>>[];

    final buffer = StringBuffer();

    final invoiceCode = data['invoice_code']?.toString() ?? '';
    final dataAll = data['all'] ?? {};
    final customer = dataAll['customer'] as Map<String, dynamic>?;
    final people = customer?['people'] as Map<String, dynamic>?;

    final name = people?['name']?.toString() ?? '';
    final lastName = people?['last_name']?.toString() ?? '';
    final fullName = [name, lastName]
        .where((value) => value.trim().isNotEmpty)
        .join(' ');

    final customerName = fullName;
    final subtotal = _parseDouble(data['subtotal']);
    final discount = _parseDouble(data['discount']);
    final tax = _parseDouble(data['tax']);
    final total = _parseDouble(data['total']);

    buffer.writeln('🧾 *RECIBO DE COMPRA*');

    if (invoiceCode.isNotEmpty) {
      buffer.writeln('Comprobante: $invoiceCode');
    }

    if (customerName.isNotEmpty) {
      buffer.writeln('Cliente: $customerName');
    }

    buffer.writeln();
    buffer.writeln('*PRODUCTOS*');
    buffer.writeln('────────────────────');

    for (final product in products) {
      final name = product['name']?.toString() ?? 'Producto';
      final code = product['code']?.toString() ?? '';
      final productTypeName = product['productTypeName']?.toString() ?? '';
      final quantity = _parseDouble(product['quantity']);
      final unitPrice = _parseDouble(product['unitPrice']);
      final productTotal = _parseDouble(product['total']);

      buffer.writeln('*$name*');

      if (code.isNotEmpty) {
        buffer.writeln('Código: $code');
      }

      if (productTypeName.isNotEmpty) {
        buffer.writeln('Tipo: $productTypeName');
      }

      buffer.writeln('Cantidad: ${_formatNumber(quantity)}');
      buffer.writeln('Precio: \$${unitPrice.toStringAsFixed(2)}');
      buffer.writeln('Total: \$${productTotal.toStringAsFixed(2)}');
      buffer.writeln();
    }

    buffer.writeln('────────────────────');

    if (subtotal > 0) {
      buffer.writeln('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    }

    if (discount > 0) {
      buffer.writeln('Descuento: -\$${discount.toStringAsFixed(2)}');
    }

    if (tax > 0) {
      buffer.writeln('Impuestos: \$${tax.toStringAsFixed(2)}');
    }

    buffer.writeln('*TOTAL: \$${total.toStringAsFixed(2)}*');

    buffer.writeln();
    buffer.writeln('Gracias por su compra. 🙌');

    return buffer.toString();
  }

  void _sendReceiptToWhatsApp(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) async {
    final message = _buildWhatsAppReceipt(receipt);
    if (message.trim().isEmpty) return;

    await Share.share(message, subject: 'Recibo de compra');
  }

  void _generateElectronicInvoice(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    debugPrint('Facturar electrónicamente: ${receipt?.id}');
  }

  @override
  Widget build(BuildContext context) {
    final receipt = context.select<PosReceiptsController,
        GenericListItem<Map<String, dynamic>>?>(
          (controller) => controller.selectedReceipt,
    );

    if (receipt == null) {
      return Container(
        decoration: PosSettingsMenuStyles.containerDecoration(context),
        child: const Center(
          child: Text(
            'Selecciona un recibo',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  45,
                  100, // Espacio para la barra de botones
                  45,
                  45,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 780,
                      ),
                      child: _ReceiptDetailCard(
                        receipt: receipt,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ReceiptManagementActions(
                    onPrint: () => _printReceipt(receipt),
                    onDownload: () => _downloadReceiptPdf(receipt),
                    onWhatsApp: () => _sendReceiptToWhatsApp(receipt),
                    onElectronicInvoice: () => _generateElectronicInvoice(receipt),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDetailCard extends StatelessWidget {
  final GenericListItem<Map<String, dynamic>> receipt;

  const _ReceiptDetailCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final data = receipt.data ?? {};
    final dataAll = data['all'] as Map<String, dynamic>? ?? {};
    final customer = dataAll['customer'] as Map<String, dynamic>?;
    final employeeManager = dataAll['employee'] as Map<String, dynamic>?;
    final employeeCustomer = employeeManager?['customer'] as Map<String, dynamic>?;

    final String receiptNumber = data['receiptNumber']?.toString() ?? '';
    final String invoiceCode = data['invoiceCode']?.toString() ?? '';
    final String ticketCode = data['ticketCode']?.toString() ?? '';
    final products = (data['products'] as List?) ?? [];

    final String total = _currency(data['total']);
    final String paymentMethod = data['paymentMethod']?.toString() ?? 'Sin información';
    final String orderType = data['orderType']?.toString() ?? '';
    final orderIcon = data['orderIcon'] as IconData? ?? Icons.receipt;
    final String date = data['dateString']?.toString() ?? '';
    final String hour = data['hour']?.toString() ?? '';
    final String status = data['statusName']?.toString() ?? 'Sin estado';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiptNumber.isNotEmpty
                            ? 'Comprobante #$receiptNumber'
                            : 'Comprobante',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildDocumentCode(invoiceCode, ticketCode),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 16),

            // INFORMACIÓN RÁPIDA
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (orderType.isNotEmpty)
                  _InfoChip(icon: orderIcon, label: orderType),
                if (paymentMethod.isNotEmpty)
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: paymentMethod,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // CLIENTE Y EMPLEADO
            Row(
              children: [
                Expanded(
                  child: _buildCustomerSection(
                    context,
                    customer,
                    Icons.person_outline,
                    'Cliente',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomerSection(
                    context,
                    employeeCustomer,
                    Icons.badge_outlined,
                    'Empleado',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // TOTAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: .8,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          total,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hour.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          hour,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PRODUCTOS
            _buildProductsSection(context, products),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES Y FUNCIONES DE SOPORTE
// ============================================================================

Widget _buildCustomerSection(
    BuildContext context,
    Map<String, dynamic>? customer,
    IconData icon,
    String title,
    ) {
  final people = customer?['people'] as Map<String, dynamic>?;
  final name = people?['name']?.toString() ?? '';
  final lastName = people?['last_name']?.toString() ?? '';
  final fullName = [name, lastName].where((v) => v.trim().isNotEmpty).join(' ');

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                fullName.isNotEmpty ? fullName : 'Consumidor Final',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductsSection(BuildContext context, List products) {
  if (products.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 20),
          const SizedBox(width: 8),
          Text(
            'Productos',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${products.length}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = products[index] as Map<String, dynamic>;
            final name = item['name']?.toString() ?? 'Producto';
            final qty = item['quantity']?.toString() ?? '1';
            final price = _currency(item['total']);

            return ListTile(
              dense: true,
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Cantidad: $qty'),
              trailing: Text(
                price,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}

String _formatNumber(double number) {
  if (number == number.roundToDouble()) {
    return number.toInt().toString();
  }
  return number.toStringAsFixed(2);
}

String _currency(dynamic value) {
  final number = _parseDouble(value);
  return NumberFormat.currency(
    locale: 'es_EC',
    symbol: r'$',
    decimalDigits: 2,
  ).format(number);
}

String _buildDocumentCode(String invoiceCode, String ticketCode) {
  if (invoiceCode.isNotEmpty && ticketCode.isNotEmpty) {
    return '$invoiceCode · Ticket $ticketCode';
  }
  if (invoiceCode.isNotEmpty) return invoiceCode;
  if (ticketCode.isNotEmpty) return 'Ticket $ticketCode';
  return 'Sin número de documento';
}

Color _getStatusColor(String status) {
  final value = status.toUpperCase();

  if (value.contains('PAG') ||
      value.contains('ISSUED') ||
      value.contains('COLECT')) {
    return Colors.green;
  }
  if (value.contains('PEND')) {
    return Colors.orange;
  }
  if (value.contains('CANCEL') || value.contains('REJECT')) {
    return Colors.red;
  }

  return Colors.blueGrey;
}