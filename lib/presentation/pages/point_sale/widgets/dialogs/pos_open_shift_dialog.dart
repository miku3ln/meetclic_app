import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../layouts/pos_main_controller.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosOpenShiftDialog extends StatefulWidget {
  final PosMainController controller;

  const PosOpenShiftDialog({super.key, required this.controller});

  @override
  State<PosOpenShiftDialog> createState() => _PosOpenShiftDialogState();
}

class _PosOpenShiftDialogState extends State<PosOpenShiftDialog> {
  // ============================================================
  // CASH MANAGEMENT
  // ============================================================

  bool _isLoadingCash = true;
  bool _allowManagerCash = false;
  String _messageManagerCash = '';
  Map<String, dynamic>? _dataManagerCash;

  // ============================================================
  // SHIFT
  // ============================================================

  final TextEditingController _controller = TextEditingController(text: '0.00');

  bool _isSaving = false;
  final FocusNode _amountFocusNode = FocusNode();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(_onAmountFocusChanged);
    _loadAllowManagerCash();
  }

  void _onAmountFocusChanged() {
    if (_amountFocusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  // ============================================================
  // CASH VALIDATION
  // ============================================================

  Future<void> _loadAllowManagerCash() async {
    final response = await UtilServicesCash.allowManagerCash();

    if (!mounted) return;

    setState(() {
      _allowManagerCash = response.success;
      _messageManagerCash = response.message;
      _isLoadingCash = false;

      _dataManagerCash = response.success ? response.data : null;
    });
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  double _parseAmount() {
    final raw = _controller.text.trim().replaceAll(',', '.');

    final value = double.tryParse(raw) ?? 0.0;

    return value < 0 ? 0.0 : value;
  }

  // ============================================================
  // OPEN SHIFT
  // ============================================================
  Future<void> setValueCashInitPreload(double amount, String openedAt) async {
    final DateTime? openedAtCurrent = DateTime.tryParse(openedAt);

    if (openedAtCurrent == null) {
      return;
    }

    await widget.controller.shift.openShiftPreload(
      initialCash: amount,
      openedAt: openedAtCurrent,
      messageNotSave: 'No se guardó',
      messageSave: 'Guardado en el dispositivo.!',
    );
  }

  Future<void> _openShift() async {
    final amount = _parseAmount();

    if (amount < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // =========================================================
      // 1. GUARDAR EN SERVIDOR
      // =========================================================

      final responseSave = await UtilServicesCash.openCash(
        openingAmount: amount,
      );

      if (!mounted) return;

      // Si falla servidor, NO guardar en caché
      if (!responseSave.success) {
        _showMessage(
          responseSave.message.isNotEmpty
              ? responseSave.message
              : 'No se pudo abrir la caja.',
        );
        return;
      }

      // =========================================================
      // 2. SERVIDOR OK -> GUARDAR EN CACHÉ / DISPOSITIVO
      // =========================================================

      final responseLocal = await widget.controller.shift.openShift(
        initialCash: amount,
      );

      if (!mounted) return;

      // =========================================================
      // 3. VALIDAR GUARDADO LOCAL
      // =========================================================

      if (responseLocal['success'] != true) {
        _showMessage(
          responseLocal['message']?.toString() ??
              'La caja se abrió en el servidor, pero no se pudo '
                  'guardar la información en el dispositivo.',
        );

        return;
      } else {
        _showMessage(responseSave.message);
      }

      // =========================================================
      // 4. TODO CORRECTO
      // =========================================================

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      _showMessage('No se pudo abrir el turno: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _amountFocusNode.removeListener(_onAmountFocusChanged);

    _amountFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            _buildHeader(context),

            const Divider(height: 1),

            // ==================================================
            // CONTENT
            // ==================================================
            _buildContent(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 8),
          Text(
            'Abrir el turno',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    // ----------------------------------------------------------
    // 1. LOADING
    // ----------------------------------------------------------

    if (_isLoadingCash) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ----------------------------------------------------------
    // 2. CASH MANAGEMENT NOT ALLOWED
    // ----------------------------------------------------------

    if (!_allowManagerCash) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(_messageManagerCash, textAlign: TextAlign.center),
        ),
      );
    }

    // ----------------------------------------------------------
    // 3. CASH MANAGEMENT ALLOWED
    // ----------------------------------------------------------
    final cash = _dataManagerCash?['cash'];
    final session = _dataManagerCash?['session'];
    final movementSummary = _dataManagerCash?['movement_summary'];
    if (session["is_open"]) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            "Existe una Caja ya Abierta,cierre la caja para poder Abrir otra.!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return _buildOpenShiftForm();
    }
  }

  // ============================================================
  // OPEN SHIFT FORM
  // ============================================================
  bool get _isAmountValid {
    final value = _controller.text.trim().replaceAll(',', '.');

    if (value.isEmpty) {
      return false;
    }

    final amount = double.tryParse(value);

    if (amount == null) {
      return false;
    }

    return amount >= 0;
  }

  Widget _buildOpenShiftForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Especifique la cantidad de efectivo de la caja '
            'con el que empezará su turno',
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _controller,
            focusNode: _amountFocusNode,
            enabled: !_isSaving,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
            ],

            onChanged: (_) {
              setState(() {});
            },

            decoration: const InputDecoration(
              labelText: 'Cantidad',
              prefixText: '\$ ',
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: !_isSaving && _isAmountValid ? _openShift : null,

              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ABRIR EL TURNO'),
            ),
          ),
        ],
      ),
    );
  }
}
