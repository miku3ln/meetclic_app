import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';

import '../../../../../shared/controllers/app_controller.dart';
import '../../shared/utils.dart';
import '../../theme/pos_ticket_styles.dart';
import '../layouts/pos_main_controller.dart';
import '../models/pos_product_item.dart';
import '../molecules/pos_payment_methods_bar.dart';
import '../molecules/pos_ticket_header.dart';
import '../molecules/pos_totals_card.dart';
import '../organisms/pos_ticket_checkout.dart';
import '../organisms/pos_ticket_list.dart';
class PosPaymentLayoutController extends ChangeNotifier {
  final PosMainController main;

  PosPaymentLayoutController({required this.main});

  /// =============================
  /// ITEMS
  /// =============================
  List<PostTicketItem> get items => main.ticket.items;
  bool get hasItems => items.isNotEmpty;

  /// =============================
  /// TOTALS
  /// =============================
  double get total => main.ticket.total;
  double get subtotal => main.ticket.subtotal;
  double get tax => main.ticket.subtotalTax;

  /// =============================
  /// CASH
  /// =============================
  double? _cashReceived;

  double get cashReceived => _cashReceived ?? total;

  double get change {
    final cash = _cashReceived;
    if (cash == null) return 0;
    return (cash - total).clamp(0, double.infinity);
  }

  bool get isValidCash =>
      _cashReceived != null && _cashReceived! >= total;

  /// 🔥 SET DIRECTO (input manual)
  void setCash(double? value) {
    if (value == null) {
      _cashReceived = null;
    } else if (value <= 0) {
      _cashReceived = total;
    } else if (value < total) {
      _cashReceived = total;
    } else {
      _cashReceived = value;
    }

    notifyListeners();
  }

  /// 🔥 SUMAR (botones rápidos)
  void addCash(double value) {
    final current = _cashReceived ?? total;
    _cashReceived = current + value;
    notifyListeners();
  }

  /// 🔥 SET DIRECTO DESDE BOTÓN
  void setExactCash(double value) {
    _cashReceived = value;
    notifyListeners();
  }

  /// =============================
  /// 💵 SUGERENCIAS (ESTILO POS REAL)
  /// =============================
  List<double> get suggestedAmounts {
    const bills = [1, 5, 10, 20, 50, 100];

    final int base = total.ceil();

    final Set<int> result = {};

    /// 1. total redondeado
    result.add(base);

    /// 2. siguiente billete directo
    result.addAll(bills.where((b) => b >= base));

    /// 3. combinaciones simples (billete + otro)
    for (final b1 in bills) {
      for (final b2 in bills) {
        final sum = b1 + b2;
        if (sum >= base) {
          result.add(sum);
        }
      }
    }

    /// 4. limitar cantidad (UI limpia)
    final sorted = result.toList()..sort();

    return sorted.take(4).map((e) => e.toDouble()).toList();
  }

  /// =============================
  /// ITEMS ACTIONS
  /// =============================
  void removeItem(PostTicketItem item) {
    main.ticket.removeItem(item);
    notifyListeners();
  }

  void increase(PostTicketItem item) {
    main.ticket.increaseItem(item);
    notifyListeners();
  }

  void decrease(PostTicketItem item) {
    main.ticket.decreaseItem(item);
    notifyListeners();
  }
}

/// =============================
/// MAIN SPLIT VIEW
/// =============================
class PosPaymentLayout extends StatelessWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const PosPaymentLayout({
    super.key,
    required this.controller,
    required this.mainController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          children: [
            /// LEFT 30%
            Expanded(flex: 4, child: PosDetails(controller: controller,mainController:mainController)),

            /// RIGHT 70%
            Expanded(flex: 6, child: PosPaymentPanel(controller: controller,mainController:mainController)),
          ],
        );
      },
    );
  }
}

/// =============================
/// LEFT - ITEMS
/// =============================
class PosDetails extends StatelessWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const PosDetails({
    super.key,
    required this.controller,
    required this.mainController,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>(); // ✅ lee modo global
late double totalsCardWidth=190;
    final t = Theme.of(context);
    final bool isLoginMode = app.isLoginRequired;

    final double heightPostTicket=isLoginMode?170:200;

    final styles = const PosTicketStyles().copyWith(
      leftThumbSize: 30,
      rightColumnWidth: 100,
      iconButtonSize: 25,
    );
   final TextStyle totalLabelStyle= t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800) ??
        const TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
    late List<TypeService> tipos = mainController.typeServicesData;
    late TypeService selected = mainController.typeService;
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                // 👈 🔥 CLAVE
                child: TypeServiceDropdown(
                  items: tipos,
                  selected: selected,
                  onSelected: (value) {
                    debugPrint('Seleccionado: ${value.value}');
                  },
                ),
              ),
            ],
          ),

          Expanded(
            child: PosTicketBody(
              isEdit: false,
              items: mainController.ticket.items,
              styles: styles,
              onMinus: (it) => mainController.ticket. decreaseItem(it),
              onPlus: (it) => mainController.ticket.increaseItem(it),
              onEdit: (it) => mainController.ticket.editTicketItem(it),
              onDelete: (it) => mainController.ticket.removeItem(it),
            ),
          ),
          SizedBox(height: 25), // ✅ antes 50
          SizedBox(
            height: heightPostTicket,
            child:Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                // ✅ Columna derecha 40%
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: totalsCardWidth, // tu ancho fijo
                      child: PosTotalsCardBox(
                        widthFactor: 1,
                        subtotal: mainController.ticket.subtotal,
                        tax: mainController.ticket.subtotalTax,
                        total: mainController.ticket.total,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =============================
/// RIGHT - PAYMENT
/// =============================
class PosPaymentPanel extends StatelessWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const PosPaymentPanel({super.key, required this.controller,required this.mainController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// =========================
              /// FILA 1 → TOTAL CENTRADO
              /// =========================
              Column(
                children: [
                  Text(
                    '\$${controller.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Importe total adeudado',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// =========================
              /// FILA 2 → INPUT + COBRAR
              /// =========================
              Row(
                children: [
                  /// INPUT EFECTIVO
                  Expanded(
                    child: CashInput(controller: controller),
                  ),

                  const SizedBox(width: 16),

                  /// BOTÓN COBRAR
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.hasItems
                          ? () {
                        controller.main.ticket.saveTicket();
                        Navigator.pop(context);
                      }
                          : null,
                      child: const Text('COBRAR'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// =========================
              /// FILA 3 → BOTONES RÁPIDOS
              /// =========================
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.suggestedAmounts.map((amount) {
                  return SizedBox(
                    width: 120,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => controller.setCash(amount),
                      child: Text('\$${amount.toStringAsFixed(2)}'),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// =========================
              /// FILA 4 → MÉTODOS DE PAGO
              /// =========================
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: PosPaymentMethodsBar(
                    controller: mainController,
                  ),
                ),
              ),
              const Spacer(),

              /// CAMBIO
              if (controller.cashReceived > 0)
                Text(
                  'Cambio: \$${controller.change.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// =============================
/// USO EN MODAL
/// =============================
Widget buildPaymentModal({required PosMainController main}) {
  final controller = PosPaymentLayoutController(main: main);

  return PosPaymentLayout(controller: controller, mainController: main);
}
class CashInput extends StatefulWidget {
  final PosPaymentLayoutController controller;

  const CashInput({super.key, required this.controller});

  @override
  State<CashInput> createState() => _CashInputState();
}

class _CashInputState extends State<CashInput> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.controller.cashReceived.toStringAsFixed(2),
    );

    _focusNode = FocusNode();

    /// 🔥 seleccionar todo al enfocar
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textController.text.length,
        );
      } else {
        /// 🔥 cuando pierde foco → validar
        _applyValue();
      }
    });
  }

  void _applyValue() {
    final value = double.tryParse(_textController.text);

    widget.controller.setCash(value);

    /// 🔥 refrescar texto con valor corregido
    _textController.text =
        widget.controller.cashReceived.toStringAsFixed(2);
  }

  @override
  void didUpdateWidget(covariant CashInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 🔥 sincronizar si cambia desde botones
    final newValue =
    widget.controller.cashReceived.toStringAsFixed(2);

    if (_textController.text != newValue &&
        !_focusNode.hasFocus) {
      _textController.text = newValue;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),

      decoration: const InputDecoration(
        labelText: 'Efectivo recibido',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),

      /// ❌ NO validar aquí
      onChanged: (v) {},

      /// ✅ validar cuando termina
      onEditingComplete: () {
        _applyValue();
        FocusScope.of(context).unfocus();
      },
    );
  }
}