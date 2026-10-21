
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/dialogs/draft-manager/pos_draft_tickets_modal.dart';

import '../../layouts/pos_main_controller.dart';
import '../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
class TicketPaymentResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String type;

  const TicketPaymentResult({
    required this.success,
    required this.message,
    required this.type,
    this.data,
  });
}
typedef ConfirmTicketPayment = Future<bool> Function(TicketPaymentRequest request);

class PosTicketPaymentModal extends StatefulWidget {
  final TicketMap ticket;
  final PosMainController main;
  const PosTicketPaymentModal({
    super.key,
    required this.ticket,
    required this.main,

  });

  static Future<TicketPaymentResult?> show(
      BuildContext context, {
        required TicketMap ticket,
        required  PosMainController main
      }) {
    return showDialog<TicketPaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PosTicketPaymentModal(
        ticket: ticket,
          main: main
      ),
    );
  }

  @override
  State<PosTicketPaymentModal> createState() =>
      _PosTicketPaymentModalState();
}

class _PosTicketPaymentModalState extends State<PosTicketPaymentModal> {
  final TextEditingController _receivedController = TextEditingController();

  TicketPaymentMethod _method = TicketPaymentMethod.cash;

  bool _saving = false;
  String? _error;

  late final double _total;
  late final int _invoiceSaleId;

  static double _asMoney(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map
          ? Map<String, dynamic>.from(value)
          : <String, dynamic>{};

  @override
  void initState() {
    super.initState();

    final header = _asMap(widget.ticket['header']);

    _invoiceSaleId =
        int.tryParse(header['id']?.toString() ?? '') ?? 0;

    final invoiceValue = _asMoney(header['invoice_value']);

    _total = invoiceValue > 0
        ? invoiceValue
        : (_asMoney(header['subtotal']) +
        _asMoney(header['value_taxes']) -
        _asMoney(header['discount_value']))
        .clamp(0, double.infinity)
        .toDouble();

    _receivedController.text = _total.toStringAsFixed(2);
    _receivedController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _receivedController.removeListener(_refresh);
    _receivedController.dispose();
    super.dispose();
  }

  // ============================================
  // VALORES DEL PAGO
  // ============================================

  bool get _isCash => _method == TicketPaymentMethod.cash;

  double get _received => _asMoney(
    _receivedController.text.replaceAll(',', '.'),
  );

  double get _change => _isCash
      ? (_received - _total).clamp(0, double.infinity).toDouble()
      : 0;

  bool get _canPay =>
      !_saving &&
          _invoiceSaleId > 0 &&
          _total > 0 &&
          (!_isCash || _received >= _total);

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  // ============================================
  // RESULTADO DEL MODAL
  // ============================================

  void _finish({
    required bool success,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) {
    if (!mounted) return;

    Navigator.of(context).pop(
      TicketPaymentResult(
        success: success,
        message: message,
        type: type,
        data: data,
      ),
    );
  }

  // ============================================
  // CERRAR
  // ============================================

  void _close() {
    if (_saving) return;

    _finish(
      success: false,
      message: 'Ventana de cobro cerrada',
      type: 'closed',
    );
  }

  // ============================================
  // CANCELAR
  // ============================================

  void _cancel() {
    if (_saving) return;

    _finish(
      success: false,
      message: 'Operación cancelada',
      type: 'cancelled',
    );
  }

  // ============================================
  // SELECCIONAR MÉTODO DE PAGO
  // ============================================

  void _setMethod(TicketPaymentMethod method) {
    setState(() {
      _method = method;
      _error = null;

      if (!_isCash) {
        _receivedController.text = _total.toStringAsFixed(2);
      }
    });
  }

  // ============================================
  // GENERAR DATOS DEL PAGO
  // ============================================

  Map<String, dynamic> _buildPaymentData() {
    return  widget.main.getTicketDraftData(_total, TicketPaymentRequest.getPaymentMethodCode( _method), _invoiceSaleId);

  }

  // ============================================
  // GUARDAR PAGO
  // ============================================

  Future<void> _confirm() async {
    if (_saving || !_canPay) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final paymentData = _buildPaymentData();

      debugPrint('Datos para registrar pago: $paymentData');

      final result =
      await PosTicketService.transformDraftInvoiceRegister(
        paymentData,
      );

      if (!mounted) return;

      final success = result['success'] == true;

      final message = result['message']?.toString() ??
          'No se recibió una respuesta del servidor.';

      if (!success) {
        setState(() {
          _error = message;
          _saving = false;
        });
        return;
      }

      final responseData = result['data'];

      final Map<String, dynamic>? data = responseData is Map
          ? Map<String, dynamic>.from(responseData)
          : null;

      _finish(
        success: true,
        message: message,
        type: 'saved',
        data: data,
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo registrar el pago: $e';
        _saving = false;
      });
    }
  }

  // ============================================
  // BOTÓN DE MÉTODO DE PAGO
  // ============================================

  Widget _paymentChip(
      TicketPaymentMethod method,
      String label,
      IconData icon,
      ) {
    final selected = _method == method;

    return OutlinedButton.icon(
      onPressed: _saving ? null : () => _setMethod(method),
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor:
        selected ? Colors.green.shade700 : null,
        backgroundColor: selected
            ? Colors.green.withValues(alpha: 0.10)
            : null,
        side: BorderSide(
          color: selected
              ? Colors.green.shade400
              : Colors.grey.shade400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }

  // ============================================
  // RESUMEN TOTAL Y CAMBIO
  // ============================================

  Widget _amountSummary() {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  _money(_total),
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            height: 54,
            width: 1,
            color: Colors.grey.shade400,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _money(_change),
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cambio',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // INTERFAZ DEL MODAL
  // ============================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final meta = _asMap(widget.ticket['meta']);

    final ticketCode =
        meta['ticket_code']?.toString() ??
            'TICKET-$_invoiceSaleId';

    final compact = size.width < 600;

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: _saving,
              child: SizedBox(
                width: size.width < 850 ? size.width * 0.96 : 760,
                height: size.height * 0.88,
                child: Padding(
                  padding: EdgeInsets.all(compact ? 14 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // =====================================
                      // HEADER
                      // =====================================
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Cobrar $ticketCode',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cerrar',
                            onPressed: _saving ? null : _close,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const Divider(),

                      // =====================================
                      // FORMAS DE PAGO
                      // =====================================
                      Text(
                        'Formas de Pago.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4D4AFF),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _paymentChip(
                              TicketPaymentMethod.cash,
                              'Efectivo',
                              Icons.payments_outlined,
                            ),
                            const SizedBox(width: 9),
                            _paymentChip(
                              TicketPaymentMethod.deposit,
                              'Depósito',
                              Icons.account_balance,
                            ),
                            const SizedBox(width: 9),
                            _paymentChip(
                              TicketPaymentMethod.card,
                              'Tarjetas',
                              Icons.credit_card_outlined,
                            ),
                            const SizedBox(width: 9),
                            _paymentChip(
                              TicketPaymentMethod.qr,
                              'QR Code',
                              Icons.qr_code_2_outlined,
                            ),
                          ],
                        ),
                      ),

                      // =====================================
                      // VALORES SUGERIDOS
                      // =====================================
                      if (_isCash) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 58,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              2.0,
                              5.0,
                              10.0,
                              20.0,
                              50.0,
                            ].map((amount) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () {
                                    _receivedController.text =
                                        amount.toStringAsFixed(2);
                                  },
                                  child: Text(_money(amount)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // =====================================
                      // TOTAL / CAMBIO
                      // =====================================
                      _amountSummary(),

                      const Spacer(),

                      // =====================================
                      // ERROR
                      // =====================================
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),

                      // =====================================
                      // FOOTER
                      // =====================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _receivedController,
                              enabled: !_saving && _isCash,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: _isCash
                                    ? 'Efectivo recibido'
                                    : 'Importe a cobrar',
                                prefixText: '\$  ',
                                border: const OutlineInputBorder(),
                                helperText:
                                _isCash && _received < _total
                                    ? 'Faltan ${_money(_total - _received)}'
                                    : null,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _canPay ? _confirm : null,
                              icon: _saving
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.check),
                              label: Text(
                                _saving ? 'Procesando' : 'Cobrar',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // =====================================
                      // CANCELAR
                      // =====================================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _saving ? null : _cancel,
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // OVERLAY DE PROCESAMIENTO
            // ==========================================
            if (_saving)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    alignment: Alignment.center,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                      ),
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'Registrando pago',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Estamos procesando el cobro.\n'
                                'Por favor, espere...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
