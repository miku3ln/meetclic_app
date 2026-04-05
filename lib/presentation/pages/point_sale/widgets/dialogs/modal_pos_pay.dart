import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';

import '../../../../../shared/controllers/app_controller.dart';
import '../../shared/utils.dart';
import '../../state/product_modal_controller.dart';
import '../../theme/pos_ticket_styles.dart';
import '../alert_information.dart';
import '../chips.dart';
import '../layouts/pos_main_controller.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../models/pos_product_item.dart';
import '../molecules/pos_payment_methods_bar.dart';
import '../molecules/pos_ticket_header.dart';
import '../molecules/pos_totals_card.dart';
import '../organisms/pos_ticket_list.dart';
import 'moda_managerl.dart';

class PosPaymentLayoutController extends ChangeNotifier {
  final PosMainController main;

  bool get showActions => false;

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

  bool get isValidCash => _cashReceived != null && _cashReceived! >= total;

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

  void onConfirm() {}

  void onCancel() {}

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

  bool _isCompleted = false;

  bool get isCompleted => _isCompleted;

  void completePayment() {
    _isCompleted = true;
    notifyListeners();
  }

  void reset() {
    _isCompleted = false;
    _cashReceived = null;
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
        return Column(
          children: [
            /// HEADER
            _Header(controller: controller, mainController: mainController),

            /// BODY
            Expanded(
              child: _Body(
                controller: controller,
                mainController: mainController,
              ),
            ),

            /// ACTIONS (opcional)
            if (controller.showActions) _Actions(controller: controller),
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
    final app = context.watch<AppController>();
    final double totalsCardWidth = 190;
    final t = Theme.of(context);
    final bool isLoginMode = app.isLoginRequired;

    final double heightPostTicket = isLoginMode ? 170 : 200;

    final styles = const PosTicketStyles().copyWith(
      leftThumbSize: 30,
      rightColumnWidth: 100,
      iconButtonSize: 25,
    );

    final TextStyle totalLabelStyle =
        t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800) ??
        const TextStyle(fontWeight: FontWeight.w800, fontSize: 16);

    final List<TypeService> tipos = mainController.typeServicesData;
    final TypeService selected = mainController.typeService;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          /// =========================
          /// 🔽 SELECTOR
          /// =========================
          Row(
            children: [
              Expanded(
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

          /// =========================
          /// 📋 LISTA (OCUPA ESPACIO PRINCIPAL)
          /// =========================
          Expanded(
            child: PosTicketBody(
              isEdit: false,
              items: mainController.ticket.items,
              styles: styles,
              onMinus: (it) => mainController.ticket.decreaseItem(it),
              onPlus: (it) => mainController.ticket.increaseItem(it),
              onEdit: (it) => mainController.ticket.editTicketItem(it),
              onDelete: (it) => mainController.ticket.removeItem(it),
            ),
          ),

          const SizedBox(height: 12),

          /// =========================
          /// 💰 TOTALES (FLEXIBLE, NO ROMPE)
          /// =========================
          Flexible(
            fit: FlexFit.loose, // 🔥 clave para evitar overflow
            child: SizedBox(
              height: heightPostTicket,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),

                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        width: totalsCardWidth,
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

  const PosPaymentPanel({
    super.key,
    required this.controller,
    required this.mainController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.all(16),

          /// 🔥 SWITCH ENTRE FORM Y SUCCESS
          child: controller.isCompleted
              ? PosPaymentSuccess(controller: controller)
              : _buildPaymentForm(context, controller, mainController),
        );
      },
    );
  }
}

/// =============================
/// USO EN MODAL
/// =============================
Widget buildPaymentModal({
  required PosMainController main,
  required PosPaymentLayoutController controller,
}) {
  return PosPaymentLayout(controller: controller, mainController: main);
}

class CashInput extends StatefulWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const CashInput({
    super.key,
    required this.controller,
    required this.mainController,
  });

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
    _textController.text = widget.controller.cashReceived.toStringAsFixed(2);
  }

  @override
  void didUpdateWidget(covariant CashInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 🔥 sincronizar si cambia desde botones
    final newValue = widget.controller.cashReceived.toStringAsFixed(2);

    if (_textController.text != newValue && !_focusNode.hasFocus) {
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
      enabled: widget.mainController.payment.allowInputCashPointSale,
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

Widget _buildPaymentForm(
  BuildContext context,
  PosPaymentLayoutController controller,
  PosMainController mainController,
) {
  final theme = Theme.of(context);
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// =========================
                /// TOTAL
                /// =========================
                ///
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      /// =========================
                      /// TOTAL
                      /// =========================
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${controller.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
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
                      ),

                      /// DIVISOR
                      Container(
                        width: 1,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.grey.shade300,
                      ),

                      /// =========================
                      /// CAMBIO
                      /// =========================
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${controller.change.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Cambio',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                CouponInput(main: mainController, controllerPos: controller),

                /// 🔥 BADGES DE CUPONES
                ///
                if (mainController.ticket.items
                    .where((e) => e.coupon != null)
                    .toList()
                    .isNotEmpty)
                //SET CUPONS ADD
                  Text(
                    'Cupones Aplicados.',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PosCouponChips(
                    items: mainController.ticket.items,
                    onRemove: (item) {
                      mainController.ticket.removeCoupon(item);
                    },
                  ),

                const SizedBox(height: 8),
                const SizedBox(height: 16),

                /// =========================
                /// INPUT + COBRAR
                /// =========================
                Row(
                  children: [
                    Expanded(
                      child: CashInput(
                        controller: controller,
                        mainController: mainController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.hasItems
                            ? () {
                                controller.completePayment();
                              }
                            : null,
                        child: Text(
                          mainController
                              .payment
                              .getNameButtonManagementPointSale,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// =========================
                /// BOTONES RÁPIDOS
                /// =========================
                if (mainController.payment.allowInputCashPointSale)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.suggestedAmounts.map((amount) {
                      return SizedBox(
                        width: 120,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            controller.setCash(amount);
                            controller.completePayment();
                          },
                          child: Text('\$${amount.toStringAsFixed(2)}'),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),

                /// =========================
                /// MÉTODOS DE PAGO
                /// =========================
                Text(
                  'Formas de Pago.',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: PosPaymentMethodsBar(
                      controller: mainController,
                      onPaymentTap: (method) {
                        print("Seleccionado: $method");

                        // aquí puedes:
                        // - cerrar modal
                        // - cambiar UI
                        // - validar
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class PosPaymentSuccess extends StatefulWidget {
  final PosPaymentLayoutController controller;

  const PosPaymentSuccess({super.key, required this.controller});

  @override
  State<PosPaymentSuccess> createState() => _PosPaymentSuccessState();
}

class _PosPaymentSuccessState extends State<PosPaymentSuccess> {
  final TextEditingController _emailController = TextEditingController();

  bool get isValidEmail {
    final text = _emailController.text.trim();
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  /// =========================
                  /// TOTAL / CAMBIO
                  /// =========================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '\$${controller.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('Total pagado'),
                            ],
                          ),
                        ),

                        /// DIVISOR
                        Container(
                          width: 1,
                          height: 60,
                          color: Colors.grey.shade300,
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '\$${controller.change.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('Cambio'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// =========================
                  /// EMAIL + BOTÓN
                  /// =========================
                  Row(
                    children: [
                      const Icon(Icons.email_outlined),
                      const SizedBox(width: 8),

                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'cliente@email.com',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton(
                        onPressed: isValidEmail
                            ? () {
                                final email = _emailController.text.trim();
                                debugPrint('Enviar recibo a: $email');
                              }
                            : null,
                        child: const Text('ENVIAR RECIBO'),
                      ),
                    ],
                  ),

                  /// 🔥 EMPUJA EL BOTÓN ABAJO SOLO SI HAY ESPACIO
                  const Expanded(child: SizedBox()),

                  /// =========================
                  /// NUEVA VENTA
                  /// =========================
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.reset();
                        controller.main.ticket.saveTicket();
                        Navigator.pop(context);
                      },
                      child: const Text('NUEVA VENTA'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum HeaderItemAlignment { left, right, center }

enum HeaderSide { left, right }

class HeaderItemData {
  final String? label;
  final IconData? icon;
  final int flex;
  final VoidCallback? onTap;
  final HeaderItemAlignment alignment; // 🔥 NUEVO
  final Color? colorIcon;

  const HeaderItemData({
    this.label,
    this.icon,
    this.flex = 1,
    this.colorIcon = Colors.green,

    this.onTap,
    this.alignment = HeaderItemAlignment.center, // default
  }) : assert(label != null || icon != null, 'Debe tener label o icon');
}

class _Header extends StatelessWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const _Header({required this.controller, required this.mainController});

  @override
  Widget build(BuildContext context) {
    bool isAddCustomer = mainController.selectedCustomer == null ? true : false;
    String fullName = !isAddCustomer
        ? mainController.selectedCustomer!.name
        : "";

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        children: [
          /// =========================
          /// LEFT 40%
          /// =========================
          Expanded(
            flex: 4,
            child: HeaderItem(
              side: HeaderSide.left,
              items: [
                HeaderItemData(
                  label: "Ticket",
                  flex: 7,
                  alignment: HeaderItemAlignment.left, // 🔥
                  onTap: () {},
                ),
                HeaderItemData(
                  colorIcon: isAddCustomer ? Colors.green : Colors.orange,
                  icon: isAddCustomer
                      ? Icons.person_add
                      : Icons.quick_contacts_mail_outlined,
                  flex: 3,
                  label: fullName,
                  alignment: HeaderItemAlignment.right,
                  // 🔥
                  onTap: () async {
                    final service = CustomerServiceModal();
                    final controller = CustomerModalController(service);

                    /// 🔥 DECIDES TODO AQUÍ (no en UI)
                    if (mainController.hasCustomerSelected) {
                      controller.initWithCustomer(
                        mainController.selectedCustomer!,
                      );
                    } else {
                      controller.initLoadData(); // sin await → loading
                    }

                    await showCustomerModal(
                      controllerMain: mainController,
                      context: context,
                      controller: controller,
                    );
                  },
                ),
              ],
            ),
          ),

          /// =========================
          /// RIGHT 60%
          /// =========================
          Expanded(
            flex: 6,
            child: HeaderItem(
              side: HeaderSide.right,
              items: [
                HeaderItemData(
                  label: "",
                  flex: 7,
                  alignment: HeaderItemAlignment.right, // 🔥
                  onTap: () {},
                ),
                HeaderItemData(
                  icon: Icons.arrow_back,
                  flex: 3,
                  alignment: HeaderItemAlignment.left, // 🔥
                  onTap: () {
                    if (controller.isCompleted) {
                      controller.reset();
                      controller.main.ticket.saveTicket();
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderItem extends StatelessWidget {
  final List<HeaderItemData> items;
  final HeaderSide side;
  final Color color;

  const HeaderItem({
    super.key,
    required this.items,
    required this.side,
    this.color = Colors.green,
  }) : assert(
         items.length > 0 && items.length <= 2,
         'Máximo 2 items y mínimo 1',
       );

  @override
  Widget build(BuildContext context) {
    final isLeft = side == HeaderSide.left;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: _buildItems(isLeft)),
    );
  }

  List<Widget> _buildItems(bool isLeft) {
    final list = isLeft ? items : items.reversed.toList();

    return list.map((item) {
      return Expanded(flex: item.flex, child: _wrapItem(item));

      return Expanded(
        flex: item.flex,
        child: InkWell(
          onTap: item.onTap,
          child: Align(
            alignment: _mapAlignment(item.alignment),
            child: _buildContentItems(item),
          ),
        ),
      );
    }).toList();
  }
}

Alignment _mapAlignment(HeaderItemAlignment alignment) {
  switch (alignment) {
    case HeaderItemAlignment.left:
      return Alignment.centerLeft;
    case HeaderItemAlignment.right:
      return Alignment.centerRight;
    case HeaderItemAlignment.center:
      return Alignment.center;
  }
}

Widget _buildContentItems(HeaderItemData item) {
  if (item.icon != null && item.label == null) {
    return Icon(item.icon);
  }

  if (item.label != null && item.icon == null) {
    return Text(item.label!);
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (item.label != null)
        Text(
          item.label!,
          style: TextStyle(color: item.colorIcon, fontWeight: FontWeight.w600),
        ),
      if (item.icon != null) ...[
        Icon(item.icon, color: item.colorIcon),
        const SizedBox(width: 6),
      ],
    ],
  );
}

Widget _wrapItem(HeaderItemData item) {
  final isIconOnly = item.icon != null && item.label == null;

  /// 🔥 ICON SOLO → usa IconButton
  if (isIconOnly) {
    return Align(
      alignment: _mapAlignment(item.alignment),
      child: IconButton(icon: Icon(item.icon), onPressed: item.onTap),
    );
  }

  /// 🔥 RESTO → InkWell normal
  return InkWell(
    onTap: item.onTap,
    child: Align(
      alignment: _mapAlignment(item.alignment),
      child: _buildContentItems(item),
    ),
  );
}

enum HeaderItemType {
  labelIcon, // 70 label / 30 icon
  iconLabel, // 70 icon / 30 label
  iconOnly, // 100 icon
}

class HeaderItem2 extends StatelessWidget {
  final HeaderItemType type;
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool? allowButtons;

  const HeaderItem2({
    super.key,
    required this.type,
    this.label,
    this.icon,
    this.onTap,
    this.allowButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // 🔥 importante
        height: double.infinity,
        // 🔥 importante
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _buildContentItem(type, allowButtons!, label!, icon!),
      ),
    );
  }
}

Widget _buildContentItem(
  HeaderItemType type,
  bool allowButtons,
  String label,
  IconData icon,
) {
  switch (type) {
    /// 🟩 LEFT → label izquierda / icon derecha
    case HeaderItemType.labelIcon:
      if (allowButtons!) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label ?? ""), Icon(icon)],
        );
      } else {
        return Row();
      }

    /// 🟦 RIGHT → icon izquierda / label derecha
    case HeaderItemType.iconLabel:
      if (allowButtons!) {
        return Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            const Spacer(), // 🔥 empuja todo
            Text(label ?? ""),
          ],
        );
      } else {
        return Row();
      }

    /// 🔳 SOLO ICONO CENTRADO
    case HeaderItemType.iconOnly:
      return Center(child: Icon(icon));
  }
}

class _Body extends StatelessWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const _Body({required this.controller, required this.mainController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// LEFT
        Expanded(
          flex: 4,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.black12,
                  width: 1,
                ), // 🔥 divisor
              ),
            ),
            child: PosDetails(
              controller: controller,
              mainController: mainController,
            ),
          ),
        ),

        /// RIGHT
        Expanded(
          flex: 6,
          child: PosPaymentPanel(
            controller: controller,
            mainController: mainController,
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final PosPaymentLayoutController controller;

  const _Actions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.onCancel,
              child: const Text("Cancelar"),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.onConfirm,
              child: const Text("Confirmar"),
            ),
          ),
        ],
      ),
    );
  }
}

class CouponInput extends StatefulWidget {
  final PosMainController main;
  final PosPaymentLayoutController controllerPos;

  const CouponInput({
    super.key,
    required this.main,
    required this.controllerPos,
  });

  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final controller = TextEditingController();
  AlertType? _type;
  String? _message;
  String? _subtitle;

  void _showAlert(AlertType type, String message, {String? subtitle}) {
    setState(() {
      _type = type;
      _message = message;
      _subtitle = subtitle;
    });
  }

  void _clearAlert() {
    setState(() {
      _type = null;
      _message = null;
      _subtitle = null;
    });
  }

  void _apply() {
    final code = controller.text.trim();
    final coupon = fakeFindCoupon(code);
    if (coupon == null) {
      _showAlert(AlertType.error, 'Cupón no válido');
      controller.clear();
      FocusScope.of(context).unfocus();
      return;
    }

    if (coupon.isExpired) {
      _showAlert(AlertType.warning, 'Cupón expirado');
      controller.clear();
      FocusScope.of(context).unfocus();
      return;
    }

    final success = widget.main.ticket.applyCoupon(coupon);

    if (!success) {
      _showAlert(AlertType.warning, 'Producto no está en el ticket');
      controller.clear();
      FocusScope.of(context).unfocus();
      return;
    }

    _showAlert(AlertType.success, 'Cupón aplicado', subtitle: coupon.name);
    controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// 🔥 ALERTA ARRIBA
        if (_type != null && _message != null)
          PosAlertMessage(
            message: _message!,
            subtitle: _subtitle,
            type: _type!,
            onClose: _clearAlert,
          ),

        /// INPUT + BOTÓN
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Código de cupón',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 56, // 🔥 iguala altura con TextField
              child: ElevatedButton(
                onPressed: _apply,
                child: const Text('Aplicar'),
              ),
            ),
          ],
        ),

      ],
    );
  }
}

PosCoupon? fakeFindCoupon(String code) {
  final coupons = PosTabletLandscapeFixtures.getCouponsData();

  try {
    return coupons.firstWhere(
      (c) => c.code.toLowerCase() == code.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}
