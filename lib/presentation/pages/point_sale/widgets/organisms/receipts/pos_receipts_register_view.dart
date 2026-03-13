import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';

import '../../../../../../shared/pagination_response.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_receipts_controller.dart';
class PosReceiptsRegisterView extends StatelessWidget {
  const PosReceiptsRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosReceiptsController>();
    final receipt = controller.selectedReceipt;

    if (receipt == null) {
      return Container(
        decoration: PosSettingsMenuStyles.containerDecoration(context),
        child: const Center(
          child: Text(
            'Selecciona un recibo',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(45),

          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: _ReceiptDetailCard(receipt: receipt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptDetailCard extends StatelessWidget {
  final GenericListItem<Map<String, dynamic>> receipt;

  const _ReceiptDetailCard({
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final data = receipt.data ?? {};

    final total = data['total'] as double? ?? 0;
    final receiptNumber = data['receiptNumber']?.toString() ?? '';
    final employee = data['employee']?.toString() ?? '';
    final tpv = data['tpv']?.toString() ?? '';
    final orderType = data['orderType']?.toString() ?? '';
    final productName = data['productName']?.toString() ?? '';
    final quantity = data['quantity'] as int? ?? 1;
    final unitPrice = data['unitPrice'] as double? ?? 0;
    final lineTotal = data['lineTotal'] as double? ?? 0;
    final paymentMethod = data['paymentMethod']?.toString() ?? '';
    final paymentAmount = data['paymentAmount'] as double? ?? 0;
    final date = data['date'] as DateTime?;
    final hour = data['hour']?.toString() ?? '';
    final code = data['code']?.toString() ?? '';

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    _currency(total),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),

            Text(
              'Pedido: $receiptNumber',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Empleado: $employee',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'TPV: $tpv',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),

            Text(
              orderType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$quantity x ${_currency(unitPrice)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currency(lineTotal),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _currency(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Text(
                    paymentMethod,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Text(
                  _currency(paymentAmount),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_shortDate(date)} $hour',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double value) {
    return '\$${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _shortDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }
}
