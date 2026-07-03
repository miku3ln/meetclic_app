import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meetclic_app/shared/providers_session.dart';
import '../../../../../infrastructure/config/server_config.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../repositories/config_repository.dart';
import '../../shared/utils.dart';
import '../../state/pos_checkout_state.dart';
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
import '../organisms/pos_ticket_row.dart';
import '../sections/pos_layouts_utils.dart';
import 'moda_managerl.dart';

/// =============================
/// USO EN MODAL
/// =============================
Widget buildPaymentModal({
  required PosMainController main,
  required PosPaymentLayoutController controller,
}) {
  return PosPaymentLayout(controller: controller, mainController: main);
}

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

  Future<Map<String, dynamic>> completePayment() async {
    try {
      final customer = main.selectedCustomer;
      final customerId = customer?.id;
      final businessId = SessionService().businessId;
      final currentSession = SessionService().currentSession;
      final userId = currentSession?.userId;
      final paymentMethod = main.payment.paymentMethodCode;
      final typeSave = main.checkout.checkoutAction == PosCheckoutAction.pay
          ? "SAVE"
          : "NOT-SAVE";
      final TypeService typeService = main.typeService;

      List<PostTicketItemSave> itemsBody = items.map((item) {
        return PostTicketItemSave(
          id: item.productItem.id,
          code: item.productItem.code,
          name: item.productItem.name,
          description: item.description ?? '',
          type: item.productItem.type,
          amount: item.amount.toDouble(),
          hasTax: item.tax > 0 ? 'SI' : 'NO',
          valuePercentageTax: item.tax,
          pvPrice: item.unitPrice,
          total: item.total,
          subtotal: item.subtotal,
          valuePercentageDiscount: item.discount + item.couponDiscount,
        );
      }).toList();

      final body = {
        "body": itemsBody
            .map(
              (e) => {
                "id": e.id,
                "code": e.code,
                "name": e.name,
                "description": e.description,
                "type": e.type,
                "amount": e.amount,
                "hasTax": e.hasTax,
                "valuePercentageTax": e.valuePercentageTax,
                "pvPrice": e.pvPrice,
                "subtotal": e.subtotal,
                "total": e.total,
                "valuePercentageDiscount": e.valuePercentageDiscount,
              },
            )
            .toList(),
        "header": {
          "paymentMethod": paymentMethod,
          "customer_id": customerId,
          "userId": userId,
          "business_id": businessId,
          "typeSave": typeSave,
          "typeService": typeService.value,
        },
      };
      final token = SessionService().apiToken;
      final uri = Uri.parse(
        '${ServerConfig.baseUrl}/pointsales/generate-ticket', //POS-PRODUCTS-SALES -INIT-TWO
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${token!}',
          'Content-Type': 'text/plain',
        },
        body: jsonEncode(body),
      );
      // 🔥 VALIDACIÓN REAL
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final success = decoded["success"] ?? false;
        final message = decoded["msj"] ?? "Sin mensaje";

        if (response.statusCode == 200 && success) {
          _isCompleted = true;
        }
        notifyListeners();

        return {
          "success": success,
          "message": message,
          "data": decoded["data"],
          "errors": decoded["errors"] ?? [],
        };
      } else {
        return {
          "success": false,
          "message": "Error Servidor.!",
          "data": [],
          "errors": [],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
        "data": null,
        "errors": [],
      };
    }
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
    final theme = Theme.of(context);

    return Stack(
      children: [
        /// 🔥 CONTENIDO PRINCIPAL
        Column(
          children: [
            _Header(controller: controller, mainController: mainController),
            Expanded(
              child: _Body(
                controller: controller,
                mainController: mainController,
              ),
            ),

            if (controller.showActions) _Actions(controller: controller),
          ],
        ),

        /// 🔥 FLOATING ACTIONS (TU COMPONENTE)
        Visibility(
          visible: !controller.isCompleted,
          child: PosFloatingActionsColumn(
            position: PosFloatingPosition.bottomRight,
            actions: [
              PosActionButton(
                width: 100,
                icon: Icons.confirmation_number,
                label: 'Cupones',
                backgroundColor: Colors.orange,

                onPressed: mainController.canUseCoupons
                    ? () {
                        _openCouponsPanel(context, mainController, controller);
                      }
                    : null, // 🔥 deshabilita
              ),
              PosActionButton(
                width: 100,
                // onPressed: controller.hasItems
                //      ? () => controller.completePayment()
                icon: Icons.check,
                label: mainController.payment.getNameButtonManagementPointSale,
                backgroundColor: Colors.blue,
                onPressed: () async {
                  //SAVE DATA
                  final result = await controller.completePayment();
                  final success = result["success"];
                  final message = result["message"];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: success ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                        bottom: 0,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
              type: PosTicketRowType.viewPayment,
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
              ? PosPaymentSuccess(controller: controller,mainController:mainController)
              : posPaymentManagement(context, controller, mainController),
        );
      },
    );
  }
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

Widget posPaymentManagement(
  BuildContext context,
  PosPaymentLayoutController controller,
  PosMainController mainController,
) {
  final theme = Theme.of(context);
  return PosThreeSectionLayout(
    mode: PosLayoutMode.screen,

    /// 🔝 TOP
    top: _buildTopSection(context, controller, mainController),

    /// 📜 BODY
    body: Column(
      children: [
        if (mainController.payment.allowInputCashPointSale)
          SizedBox(
            height: 70,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.35),
              itemCount: controller.suggestedAmounts.length,
              itemBuilder: (context, index) {
                final amount = controller.suggestedAmounts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: OutlinedButton(
                    onPressed: () async {
                      controller.setCash(amount);
                      final result = await controller.completePayment();
                      final success = result["success"];
                      final message = result["message"];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: success ? Colors.green : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                            bottom: 0,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Text('\$${amount.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        /// TOTAL / CAMBIO
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                    const Text('Importe total adeudado'),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey),
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
                    const Text('Cambio'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),

    /// 🔻 FOOTER
    footer: Row(
      children: [
        Expanded(
          child: CashInput(
            controller: controller,
            mainController: mainController,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTopSection(
  BuildContext context,
  PosPaymentLayoutController controller,
  PosMainController mainController,
) {
  final theme = Theme.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Formas de Pago.',
        style: TextStyle(
          fontSize: 18,
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      PosPaymentMethodsBar(
        controller: mainController,
        onPaymentTap: (method) {
          print("Seleccionado: $method");
        },
      ),
    ],
  );
}

class PosPaymentSuccess extends StatefulWidget {
  final PosPaymentLayoutController controller;
  final PosMainController mainController;

  const PosPaymentSuccess({super.key, required this.controller,required this.mainController});

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
                               Text(widget.mainController.labels.totalPayment),
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
                               Text(widget.mainController.labels.change),
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
                  const SizedBox(height: 180),

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
  final BuildContext? context;
  final IconData? icon;
  final int flex;
  final VoidCallback? onTap;
  final HeaderItemAlignment alignment; // 🔥 NUEVO
  final Color? colorIcon;

  const HeaderItemData({
    this.label,
    this.context,

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
    final colors = AppThemeTokens.of(context);

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
                  colorIcon: colors.white,
                  label:mainController.labels.ticket,
                  flex: 6,
                  alignment: HeaderItemAlignment.left, // 🔥
                  onTap: () {},
                ),
                HeaderItemData(
                  context: context,
                  colorIcon: isAddCustomer ? colors.secondary : colors.white,
                  icon: isAddCustomer
                      ? Icons.person_add
                      : Icons.quick_contacts_mail_outlined,
                  flex: 4,
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
                  colorIcon: colors.white,
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
    final colors = AppThemeTokens.of(context);
    final isLeft = side == HeaderSide.left;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: _buildItems(isLeft)),
    );
  }

  List<Widget> _buildItems(bool isLeft) {
    final list = isLeft ? items : items.reversed.toList();

    return list.map((item) {
      return Expanded(flex: item.flex, child: _wrapItem(item));
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
  if (item.icon != null && (item.label == null ||item.label == '')) {
    return Icon(item.icon,color: item.colorIcon);
  }

  if (item.label != null && item.icon == null) {
    return Text(item.label!,style:  TextStyle(color: item.colorIcon, fontWeight: FontWeight.w600));
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
      child: IconButton(icon: Icon(item.icon,color: item.colorIcon), onPressed: item.onTap),
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
                  prefixIcon: Icon(Icons.confirmation_number),
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

class _CouponsPanel extends StatelessWidget {
  final PosMainController mainController;
  final PosPaymentLayoutController controller;

  const _CouponsPanel({required this.mainController, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        mainController,
        mainController.ticket, // 🔥 CLAVE
      ]),
      builder: (_, __) {
        final hasCoupons = mainController.ticket.items
            .where((e) => e.coupon != null)
            .isNotEmpty;

        return Material(
          color: Colors.white,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 🔝 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cupones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// 🎟 INPUT
                CouponInput(main: mainController, controllerPos: controller),

                const SizedBox(height: 12),

                /// 📌 LISTA DE CUPONES
                if (hasCoupons)
                  Text(
                    'Cupones Aplicados',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    child: PosCouponChips(
                      items: mainController.ticket.items,
                      onRemove: (item) {
                        mainController.ticket.removeCoupon(item);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _openCouponsPanel(
  BuildContext context,
  PosMainController mainController,
  PosPaymentLayoutController controller,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Cupones",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: _CouponsPanel(
          mainController: mainController,
          controller: controller,
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(1, 0), // 👉 desde derecha
        end: Offset.zero,
      );

      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
  );
}

enum PosFloatingPosition { bottomRight, bottomLeft, topRight, topLeft }

class PosActionButton {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed; // 👈 ahora nullable
  final Color? backgroundColor;

  final double? width; // 🔥 NUEVO
  final double? height; // 🔥 opcional ahora

  const PosActionButton({
    this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.width,
    this.height,
  }) : assert(
         label != null || icon != null,
         'Debe tener al menos label o icon',
       );
}

class PosFloatingActionsColumn extends StatelessWidget {
  final List<PosActionButton> actions;
  final PosFloatingPosition position;
  final double spacing;
  final double width;
  final EdgeInsets margin;

  const PosFloatingActionsColumn({
    super.key,
    required this.actions,
    this.position = PosFloatingPosition.bottomRight,
    this.spacing = 12,
    this.width = 80,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final items = _isBottom ? actions.reversed.toList() : actions;
    return Positioned(
      top: _getTop(),
      bottom: _getBottom(context),
      left: _getLeft(),
      right: _getRight(),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _crossAxisAlignment, // 🔥 CLAVE
        children: actions.map((action) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: SizedBox(
              width: action.width ?? width, // 🔥 prioridad botón → layout
              height: action.height ?? 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: action.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: action.onPressed,
                child: _buildContent(action), // 👈 usa tu lógica nueva
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  double? _getTop() {
    return (position == PosFloatingPosition.topLeft ||
            position == PosFloatingPosition.topRight)
        ? margin.top
        : null;
  }

  double? _getBottom(BuildContext context) {
    return (position == PosFloatingPosition.bottomLeft ||
            position == PosFloatingPosition.bottomRight)
        ? margin.bottom + MediaQuery.of(context).padding.bottom
        : null;
  }

  double? _getLeft() {
    return (position == PosFloatingPosition.topLeft ||
            position == PosFloatingPosition.bottomLeft)
        ? margin.left
        : null;
  }

  double? _getRight() {
    return (position == PosFloatingPosition.topRight ||
            position == PosFloatingPosition.bottomRight)
        ? margin.right
        : null;
  }

  bool get _isRight {
    return position == PosFloatingPosition.topRight ||
        position == PosFloatingPosition.bottomRight;
  }

  bool get _isBottom {
    return position == PosFloatingPosition.bottomLeft ||
        position == PosFloatingPosition.bottomRight;
  }

  CrossAxisAlignment get _crossAxisAlignment {
    return _isRight
        ? CrossAxisAlignment
              .end // 👉 derecha
        : CrossAxisAlignment.start; // 👉 izquierda
  }
}

Widget _buildContent(PosActionButton action) {
  if (action.icon != null && action.label == null) {
    return Icon(action.icon, size: 20,color:Colors.white); // 👈 más pequeño
  }

  if (action.label != null && action.icon == null) {
    return Text(
      action.label!,
      style: const TextStyle(fontSize: 12,color: Colors.white), // 👈 más pequeño
    );
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min, // 🔥 CLAVE
    children: [
      Icon(action.icon, size: 20,color: Colors.white),
      const SizedBox(height: 2), // 👈 reduce espacio
      Text(action.label!, style: const TextStyle(fontSize: 11,color: Colors.white)),
    ],
  );
}
