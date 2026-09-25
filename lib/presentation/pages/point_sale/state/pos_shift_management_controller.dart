import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/layouts/pos_main_controller.dart';




class PosShiftManagementController extends ChangeNotifier {
  final PosMainController main;
  PosShiftManagementController({
    required this.main,
  });

  bool _isClosingShift = false;

  bool get isClosingShift => _isClosingShift;
  bool get isShiftOpen => main.shift.isShiftOpen;
  double? get initialCash => main.shift.initialCash;
  Future<bool>  onTreasuryTap() async{
    await Future.delayed(const Duration(milliseconds: 500));

    return true;
  }

  Future<bool> onCloseShiftTap(BuildContext context) async {
    /**
     * Validar turno abierto.
     */
    if (!isShiftOpen) {
      debugPrint('No existe un turno abierto');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No existe un turno abierto'),
        ),
      );

      return false;
    }

    /**
     * Evitar doble ejecución.
     */
    if (_isClosingShift) {
      return false;
    }

    /**
     * Mostrar ventana desde abajo hacia arriba.
     */
    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (modalContext) {
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /**
                 * Barra superior.
                 */
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                /**
                 * Título.
                 */
                const Row(
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cerrar turno',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Revise la información antes de cerrar el turno.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /**
                 * Estado.
                 */
                _buildShiftInfoRow(
                  label: 'Estado',
                  value: isShiftOpen
                      ? 'Turno abierto'
                      : 'Turno cerrado',
                ),

                /**
                 * Efectivo inicial.
                 */
                _buildShiftInfoRow(
                  label: 'Efectivo inicial',
                  value:
                  '\$ ${(initialCash ?? 0).toStringAsFixed(2)}',
                ),

                /**
                 * Usuario.
                 */
                _buildShiftInfoRow(
                  label: 'Usuario',
                  value:
                  '${main.shift.openedByUserId ?? '-'}',
                ),

                /**
                 * Fecha apertura.
                 */
                _buildShiftInfoRow(
                  label: 'Fecha de apertura',
                  value: main.shift.openedAt != null
                      ? _formatDateTime(
                    main.shift.openedAt!,
                  )
                      : '-',
                ),

                /**
                 * Tipo apertura.
                 */
                _buildShiftInfoRow(
                  label: 'Tipo de apertura',
                  value: main.shift.typeOpen.isNotEmpty
                      ? main.shift.typeOpen
                      : '-',
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 16),

                /**
                 * Acciones.
                 */
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(modalContext).pop(false);
                        },
                        child: const Text('CANCELAR'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(modalContext).pop(true);
                        },
                        child: const Text(
                          'CERRAR TURNO',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    /**
     * Cerró el modal o presionó cancelar.
     */
    if (confirm != true) {
      return false;
    }

    /**
     * Desde aquí realmente comienza
     * el proceso de cierre.
     */
    _isClosingShift = true;
    notifyListeners();

    try {
      debugPrint('Click: Cerrar el turno');

      /**
       * TODO:
       * Aquí irá primero el cierre en Laravel.
       */
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      /**
       * Cerrar estado local.
       */
      final result =
      await main.shift.closeShift();

      final bool success =
          result['success'] == true;

      if (!success) {
        debugPrint(
          result['message']?.toString() ??
              'No se pudo cerrar el turno',
        );

        return false;
      }

      debugPrint(
        'Turno cerrado correctamente',
      );

      return true;
    } catch (e) {
      debugPrint(
        'Error al cerrar el turno: $e',
      );

      return false;
    } finally {
      _isClosingShift = false;
      notifyListeners();
    }
  }
  Widget _buildShiftInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    String two(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${two(date.day)}/'
        '${two(date.month)}/'
        '${date.year} '
        '${two(date.hour)}:'
        '${two(date.minute)}';
  }
  void onCashDrawerTap() {
    debugPrint('Click: Cajón de efectivo');
  }

  void onSalesSummaryTap() {
    debugPrint('Click: Resumen de ventas');
  }

  void onPaymentsSummaryTap() {
    debugPrint('Click: Total licitado');
  }

  void onPreviousCashDrawerTap() {
    debugPrint('Click: Fondo de caja anterior');
  }

  void onCashPaymentsTap() {
    debugPrint('Click: Cobros en efectivo');
  }

  void onCashRefundsTap() {
    debugPrint('Click: Reembolsos en efectivo');
  }

  void onDepositedTap() {
    debugPrint('Click: Depositado');
  }

  void onPayoutsTap() {
    debugPrint('Click: Pagos/Salidas');
  }

  void onTheoreticalCashTap() {
    debugPrint('Click: Efectivo teórico en caja');
  }

  void onGrossSalesTap() {
    debugPrint('Click: Ventas brutas');
  }

  void onRefundsTap() {
    debugPrint('Click: Reembolsos');
  }

  void onDiscountsTap() {
    debugPrint('Click: Descuentos');
  }

  void onNetSalesTap() {
    debugPrint('Click: Ventas netas');
  }

  void onTaxesTap() {
    debugPrint('Click: Impuestos');
  }

  void onTenderedTotalTap() {
    debugPrint('Click: Total licitado');
  }

  void onCashTap() {
    debugPrint('Click: Efectivo');
  }

  void onCashRoundingTap() {
    debugPrint('Click: Redondeo de efectivo');
  }

  void onCardTap() {
    debugPrint('Click: Por tarjeta');
  }
}
