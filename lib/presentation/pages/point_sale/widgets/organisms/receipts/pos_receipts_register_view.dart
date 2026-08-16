import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/organisms/receipts/receipt_detail_card_buttons_manager.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../helpers/pos_responsive.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_receipts_controller.dart';
import 'package:share_plus/share_plus.dart';

import '../pos_settings_app_bar.dart';

class PosReceiptsRegisterView extends StatelessWidget {
  final bool isMobile;

  const PosReceiptsRegisterView({super.key, required this.isMobile});

  void _printReceipt(GenericListItem<Map<String, dynamic>>? receipt) {
    debugPrint('Imprimir comprobante: ');
  }

  void _downloadReceiptPdf(GenericListItem<Map<String, dynamic>>? receipt) {
    debugPrint('Descargar PDF: ');
  }
  String _buildWhatsAppReceipt(
      GenericListItem<Map<String, dynamic>>? receipt,
      ) {
    final buffer = StringBuffer();

    // ============================================================
    // INFORMACIÓN DEL COMPROBANTE
    // ============================================================

    final invoiceCode = ReceiptUtils.invoiceCode(receipt);
    final ticketCode = ReceiptUtils.ticketCode(receipt);
    final date = ReceiptUtils.date(receipt);
    final hour = ReceiptUtils.hour(receipt);
    final status = ReceiptUtils.status(receipt);

    // ============================================================
    // CLIENTE
    // ============================================================

    final customerName = ReceiptUtils.customerName(receipt);
    final customerDocument = ReceiptUtils.customerDocument(receipt);
    final identificationType =
    ReceiptUtils.customerIdentificationType(receipt);

    // ============================================================
    // PAGO
    // ============================================================

    final paymentMethod = ReceiptUtils.paymentMethod(receipt);
    final paymentAmount = ReceiptUtils.paymentAmount(receipt);

    // ============================================================
    // TOTALES
    // ============================================================

    final subtotal = ReceiptUtils.subtotal(receipt);
    final discount = ReceiptUtils.discount(receipt);
    final taxes = ReceiptUtils.taxes(receipt);
    final total = ReceiptUtils.total(receipt);

    // ============================================================
    // PRODUCTOS
    // ============================================================

    final products = ReceiptUtils.products(receipt);

    // ============================================================
    // ENCABEZADO
    // ============================================================

    buffer.writeln('🧾 *COMPROBANTE DE COMPRA*');
    buffer.writeln('────────────────────');

    if (invoiceCode.isNotEmpty) {
      buffer.writeln('📄 *Factura:* $invoiceCode');
    }

    if (ticketCode.isNotEmpty) {
      buffer.writeln('🎫 *Ticket:* $ticketCode');
    }

    if (date.isNotEmpty) {
      buffer.writeln('📅 *Fecha:* $date');
    }

    if (hour.isNotEmpty) {
      buffer.writeln('🕐 *Hora:* $hour');
    }

    if (status.isNotEmpty) {
      buffer.writeln('📌 *Estado:* $status');
    }

    // ============================================================
    // CLIENTE
    // ============================================================

    if (customerName.isNotEmpty ||
        customerDocument.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('*CLIENTE*');

      if (customerName.isNotEmpty) {
        buffer.writeln('👤 $customerName');
      }

      if (customerDocument.isNotEmpty) {
        final documentLabel = identificationType.isNotEmpty
            ? identificationType
            : 'Identificación';

        buffer.writeln(
          '🪪 $documentLabel: $customerDocument',
        );
      }
    }

    // ============================================================
    // PRODUCTOS
    // ============================================================

    buffer.writeln();
    buffer.writeln('*PRODUCTOS*');
    buffer.writeln('────────────────────');

    for (final product in products) {
      final name = ReceiptUtils.productName(product);
      final code = ReceiptUtils.productCode(product);
      final productType = ReceiptUtils.productType(product);

      final quantity = ReceiptUtils.productQuantity(product);
      final unitPrice = ReceiptUtils.productUnitPrice(product);
      final productTotal = ReceiptUtils.productTotal(product);

      buffer.writeln('*$name*');

      if (code.isNotEmpty) {
        buffer.writeln('Código: $code');
      }

      if (productType.isNotEmpty) {
        buffer.writeln('Tipo: $productType');
      }

      buffer.writeln(
        'Cantidad: ${_formatNumber(quantity)}',
      );

      buffer.writeln(
        'Precio unitario: ${ReceiptUtils.currency(unitPrice)}',
      );

      buffer.writeln(
        'Total: ${ReceiptUtils.currency(productTotal)}',
      );

      buffer.writeln();
    }

    // ============================================================
    // TOTALES
    // ============================================================

    buffer.writeln('────────────────────');

    buffer.writeln(
      'Subtotal: ${ReceiptUtils.currency(subtotal)}',
    );

    if (discount > 0) {
      buffer.writeln(
        'Descuento: -${ReceiptUtils.currency(discount)}',
      );
    }

    if (taxes > 0) {
      buffer.writeln(
        'Impuestos: ${ReceiptUtils.currency(taxes)}',
      );
    }

    buffer.writeln(
      '*TOTAL: ${ReceiptUtils.currency(total)}*',
    );

    // ============================================================
    // FORMA DE PAGO
    // ============================================================

    if (paymentMethod.isNotEmpty || paymentAmount > 0) {
      buffer.writeln();
      buffer.writeln('*FORMA DE PAGO*');

      if (paymentMethod.isNotEmpty) {
        buffer.writeln('💳 Método: $paymentMethod');
      }

      if (paymentAmount > 0) {
        buffer.writeln(
          '💰 Pagado: ${ReceiptUtils.currency(paymentAmount)}',
        );
      }
    }

    // ============================================================
    // PIE
    // ============================================================

    buffer.writeln();
    buffer.writeln('Gracias por su compra. 🙌');

    return buffer.toString();
  }

  void _sendReceiptToWhatsApp(
    GenericListItem<Map<String, dynamic>>? receipt,
  ) async {
    debugPrint('Enviar comprobante por WhatsApp: ');
    String message = _buildWhatsAppReceipt(receipt);
    if (message.trim().isEmpty) {
      return;
    }

    await Share.share(message, subject: 'Recibo de compra');
  }

  void _generateElectronicInvoice(
    GenericListItem<Map<String, dynamic>>? receipt,
  ) {
    debugPrint('Facturar electrónicamente:');
  }

  @override
  Widget build(BuildContext context) {
    final receipt = context
        .select<PosReceiptsController, GenericListItem<Map<String, dynamic>>?>(
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
    EdgeInsets paddingCard = EdgeInsets.fromLTRB(
      45,
      150, // espacio para los botones superiores
      45,
      150, // espacio adicional para poder llegar al final
    );
    Positioned menuOptions =   Positioned(
      top: 20,
      right: 20,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ReceiptManagementActions(
            isVertical: true,
            onPrint: () {
              _printReceipt(receipt);
            },
            onDownload: () {
              _downloadReceiptPdf(receipt);
            },
            onWhatsApp: () {
              _sendReceiptToWhatsApp(receipt);
            },
            onElectronicInvoice: () {
              _generateElectronicInvoice(receipt);
            },
          ),
        ),
      ),
    );
    double maxWidth = 780;
    if (isMobile) {
      maxWidth = MediaQuery.sizeOf(context).width;
      menuOptions = Positioned(
        top: 20,
        right: 20,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ReceiptManagementActions(
              isVertical: true,
              onPrint: () {
                _printReceipt(receipt);
              },
              onDownload: () {
                _downloadReceiptPdf(receipt);
              },
              onWhatsApp: () {
                _sendReceiptToWhatsApp(receipt);
              },
              onElectronicInvoice: () {
                _generateElectronicInvoice(receipt);
              },
            ),
          ),
        ),
      );
    } else {}
    Widget content = Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: paddingCard,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _ReceiptDetailCard(receipt: receipt),
                    ),
                  ),
                ],
              ),
            ),
          ),
          menuOptions,
        ],
      ),
    );
    if (isMobile) {
      final colors = AppThemeTokens.of(context);

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: PosSettingsAppBar(
            titlePrimary: 'Tickets',
            titleSecondary: '',
            leadingIcon: Icons.arrow_back,
            leadingTitle: 'Tickets',
            onLeadingTap: () {
              Navigator.pop(context);
            },
            style: PosSettingsAppBarStyle(
              topBackgroundColor: colors.primary,
              bottomBackgroundColor: colors.primary,
              primaryTitleColor: colors.textInverse,
              secondaryTitleColor: colors.textInverse,
              menuIconColor: colors.textInverse,
              primaryIndicatorColor: Colors.transparent,
              secondaryIndicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
            ),
          ),
        ),
        body: content,
      );
    }
    return content;
  }
}

class _ReceiptDetailCard extends StatelessWidget {
  final GenericListItem<Map<String, dynamic>> receipt;

  const _ReceiptDetailCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final receiptNumber = ReceiptUtils.receiptNumber(receipt);
    final invoiceCode = ReceiptUtils.invoiceCode(receipt);
    final ticketCode = ReceiptUtils.ticketCode(receipt);

    final products = ReceiptUtils.products(receipt);

    final total = ReceiptUtils.currency(
      ReceiptUtils.total(receipt),
    );

    final paymentMethod = ReceiptUtils.paymentMethod(receipt);

    final orderType = ReceiptUtils.orderType(receipt);
    final orderIcon = ReceiptUtils.orderIcon(receipt);

    final date = ReceiptUtils.date(receipt);
    final hour = ReceiptUtils.hour(receipt);

    final status = ReceiptUtils.statusName(receipt);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () {
          // Abrir detalle
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _buildDocumentCode(
                            invoiceCode,
                            ticketCode,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =====================================================
              // INFORMACIÓN RÁPIDA
              // =====================================================

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (orderType.isNotEmpty)
                    _InfoChip(
                      icon: orderIcon,
                      label: orderType,
                    ),

                  if (paymentMethod.isNotEmpty)
                    _InfoChip(
                      icon: Icons.payments_outlined,
                      label: paymentMethod,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // =====================================================
              // CLIENTE / EMPLEADO
              // =====================================================

              Row(
                children: [
                  Expanded(
                    child: _buildCustomerSection(
                      context,
                      ReceiptUtils.customer(receipt),
                      Icons.person_outline,
                      'Cliente',
                    ),
                  ),

                  Expanded(
                    child: _buildCustomerSection(
                      context,
                      ReceiptUtils.employeeCustomer(receipt),
                      Icons.badge_outlined,
                      'Empleado',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =====================================================
              // TOTAL
              // =====================================================

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
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: .8,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            total,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (hour.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            hour,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
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

              // =====================================================
              // PRODUCTOS
              // =====================================================

              _buildProductsSection(
                context,
                products,
              ),
            ],
          ),
        ),
      ),
    );
  }
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

String _currency(dynamic value) {
  final number = double.tryParse(value?.toString() ?? '0') ?? 0;

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

  if (invoiceCode.isNotEmpty) {
    return invoiceCode;
  }

  if (ticketCode.isNotEmpty) {
    return 'Ticket $ticketCode';
  }

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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: List.generate(products.length, (index) {
            final product = Map<String, dynamic>.from(products[index] as Map);

            return _ProductItem(
              product: product,
              isLast: index == products.length - 1,
            );
          }),
        ),
      ),
    ],
  );
}

class _ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isLast;

  const _ProductItem({required this.product, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Producto';
    final code = product['code']?.toString() ?? '';
    final productTypeName = product['productTypeName']?.toString() ?? '';
    final quantity = _parseDouble(product['quantity']);
    final unitPrice = _parseDouble(product['unitPrice']);
    final total = _parseDouble(product['total']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // ICONO
          // =====================================================
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.orange,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          // =====================================================
          // INFORMACIÓN
          // =====================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (code.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Row(
                  children: [
                    _ProductMeta(
                      label: _formatQuantity(quantity),
                      value: productTypeName,
                    ),

                    const SizedBox(width: 14),

                    _ProductMeta(
                      label: _formatCurrency(unitPrice),
                      value: 'precio',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // =====================================================
          // TOTAL PRODUCTO
          // =====================================================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Total',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

double _parseDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '0') ?? 0;
}

String _formatCurrency(double value) {
  return NumberFormat.currency(
    locale: 'es_EC',
    symbol: r'$',
    decimalDigits: 2,
  ).format(value);
}

String _formatQuantity(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(3);
}

class _ProductMeta extends StatelessWidget {
  final String label;
  final String value;

  const _ProductMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

Widget _buildCustomerSection(
  BuildContext context,
  Map<String, dynamic>? customer,
  IconData iconCurrent,
  String title,
) {
  final people = customer?['people'] as Map<String, dynamic>?;

  final identificationType =
      customer?['identification_type'] as Map<String, dynamic>?;

  final rucType = customer?['ruc_type'] as Map<String, dynamic>?;

  final name = people?['name']?.toString() ?? '';
  final lastName = people?['last_name']?.toString() ?? '';

  final fullName = [
    name,
    lastName,
  ].where((value) => value.trim().isNotEmpty).join(' ');

  final document = customer?['identification_document']?.toString() ?? '';

  final identificationName = identificationType?['name']?.toString() ?? '';

  final rucTypeName = rucType?['name']?.toString() ?? '';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // =====================================================
      // HEADER
      // =====================================================
      Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconCurrent, size: 20, color: const Color(0xFF3B82F6)),
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF30364D),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // =====================================================
      // NOMBRE
      // =====================================================
      Text(
        fullName.isNotEmpty ? fullName : 'Sin nombre',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF30364D),
        ),
      ),

      const SizedBox(height: 10),

      // =====================================================
      // DOCUMENTO
      // =====================================================
      if (document.isNotEmpty)
        _CustomerInfo(
          icon: Icons.badge_outlined,
          value: identificationName.isNotEmpty
              ? '$identificationName: $document'
              : document,
        ),

      // =====================================================
      // RUC TYPE
      // =====================================================
      if (rucTypeName.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _CustomerInfo(
            icon: Icons.business_outlined,
            value: rucTypeName,
          ),
        ),
    ],
  );
}

class _CustomerInfo extends StatelessWidget {
  final IconData icon;
  final String value;

  const _CustomerInfo({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),

        const SizedBox(width: 6),

        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }

  return value.toString();
}
