import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_shift_management_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../pos_main_controller.dart';
import '../tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosShiftManagementLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const PosShiftManagementLayout({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final main = context.read<PosMainController>();
    return ChangeNotifierProvider(
      create: (_) => PosShiftManagementController(main: main),
      child: const _PosShiftView(),
    );
  }
}

class _PosShiftView extends StatelessWidget {
  const _PosShiftView();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary: 'Turno',
        titleSecondary: '',
        onMenuTap: () {
          scaffoldKey.currentState?.openDrawer();
        },
        style: PosSettingsAppBarStyle(
          topBackgroundColor: colors.primary,
          bottomBackgroundColor: colors.primary,
          primaryTitleColor: colors.textInverse,
          secondaryTitleColor: colors.textInverse,
          menuIconColor: colors.textInverse,
          primaryIndicatorColor: Colors.transparent,
          secondaryIndicatorColor: Colors.transparent,
          dividerColor: colors.divider,
        ),
      ),
      body: const PosShiftRegister(),
    );
  }
}

class PosShiftRegister extends StatefulWidget {
  const PosShiftRegister({super.key});

  @override
  State<PosShiftRegister> createState() => _PosShiftRegisterState();
}

class _PosShiftRegisterState extends State<PosShiftRegister> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Map<String, dynamic>? _dataManagerCash;

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await UtilServicesCash.getPointOfSaleCashCloseSummary();

      if (!mounted) return;

      /**
       * Error enviado por el backend o por SafeExecutor.
       */
      if (!response.success) {
        setState(() {
          _dataManagerCash = null;
          _errorMessage = response.message;
          _isLoading = false;
        });

        return;
      }

      /**
       * Data retornada por el backend.
       */
      final Map<String, dynamic>? data = response.data;

      /**
       * La petición fue correcta pero no existe información.
       */
      if (data == null || data.isEmpty) {
        setState(() {
          _dataManagerCash = null;
          _errorMessage = null;
          _isLoading = false;
        });

        return;
      }

      /**
       * Guardamos directamente la estructura enviada
       * por getPointOfSaleCashCloseSummary().
       */
      setState(() {
        _dataManagerCash = data;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _dataManagerCash = null;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadAfterCloseShift() async {
    final controller = context.read<PosShiftManagementController>();
    final wasClosed = await controller.onCloseShiftTap(context);

    if (!mounted) return;

    if (wasClosed) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosShiftManagementController>();

    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: _buildBody(controller),
    );
  }

  Widget _buildBody(PosShiftManagementController controller) {
    /**
     * ============================================================
     * LOADING
     * ============================================================
     */
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    /**
     * ============================================================
     * SIN INFORMACIÓN / ERROR
     * ============================================================
     */
    if (_dataManagerCash == null) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: EmptyData(
                      icon: _errorMessage == null
                          ? Icons.point_of_sale_rounded
                          : Icons.error_outline,
                      title: _errorMessage == null
                          ? 'Todavía no hay información del turno'
                          : 'No se pudo cargar el turno',
                      descriptionText: _errorMessage == null
                          ? 'Aquí podrás revisar el resumen del turno cuando exista información disponible.'
                          : _errorMessage!,
                      linkText: 'Actualizar',
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Recargar'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      );
    }

    /**
     * ============================================================
     * RESUMEN DEL TURNO
     * ============================================================
     */
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1030),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: _ShiftSummaryContent(
                      data: _dataManagerCash!,
                      controller: controller,
                      onCloseShiftTap: _reloadAfterCloseShift,
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

class _ShiftSummaryContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final PosShiftManagementController controller;
  final Future<void> Function() onCloseShiftTap;

  const _ShiftSummaryContent({
    required this.data,
    required this.controller,
    required this.onCloseShiftTap,
  });

  @override
  Widget build(BuildContext context) {
    /**
     * ============================================================
     * DATA
     * ============================================================
     */

    final Map<String, dynamic> cash = _map(data['cash']);
    final Map<String, dynamic> session = _map(data['session']);
    final Map<String, dynamic> movements = _map(data['movements']);
    final Map<String, dynamic> payments = _map(data['payments']);
    final Map<String, dynamic> closing = _map(data['closing']);

    /**
     * Listas dinámicas.
     */
    final List<Map<String, dynamic>> inputs = _list(movements['inputs']);

    final List<Map<String, dynamic>> outputs = _list(movements['outputs']);

    final List<Map<String, dynamic>> paymentItems = _list(payments['items']);

    /**
     * ============================================================
     * VIEW
     * ============================================================
     */

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /**
         * Acciones superiores.
         */
        _ShiftTopActions(
          isClosingShift: controller.isClosingShift,
          onTreasuryTap: controller.onTreasuryTap,
          onCloseShiftTap: onCloseShiftTap,
        ),

        const SizedBox(height: 40),

        /**
         * Información de la caja / sesión.
         */
        _ShiftHeaderInfo(cash: cash, session: session),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 28),

        /**
         * ========================================================
         * CAJÓN DE EFECTIVO
         * ========================================================
         */
        _SectionBlock(
          title: 'Cajón de efectivo',
          titleColor: const Color(0xFF689F38),
          onTap: controller.onCashDrawerTap,
          children: [
            _MoneyRow(
              label: 'Efectivo de apertura',
              value: _currency(session['opening_amount']),
            ),

            _MoneyRow(
              label: 'Ingresos',
              value: _currency(movements['total_input']),
            ),

            _MoneyRow(
              label: 'Egresos',
              value: _currency(movements['total_output']),
            ),

            const Divider(height: 32),

            _MoneyRow(
              label: 'Efectivo teórico en caja',
              value: _currency(closing['expected_amount']),
              isBold: true,
              onTap: controller.onTheoreticalCashTap,
            ),
          ],
        ),

        /**
         * ========================================================
         * INGRESOS
         * ========================================================
         */
        if (inputs.isNotEmpty) ...[
          const SizedBox(height: 28),

          _SectionBlock(
            title: 'Ingresos',
            titleColor: const Color(0xFF689F38),
            onTap: controller.onCashPaymentsTap,
            children: [
              /**
               * Cada motivo de ingreso viene del backend.
               */
              ...inputs.map((item) {
                final int count = _toInt(item['count']);

                return _MoneyRow(
                  label: _movementLabel(name: item['name'], count: count),
                  value: _currency(item['amount']),
                );
              }),

              const Divider(height: 32),

              _MoneyRow(
                label:
                    'Total ingresos (${_toInt(movements['count_input'])} movimientos)',
                value: _currency(movements['total_input']),
                isBold: true,
              ),
            ],
          ),
        ],

        /**
         * ========================================================
         * EGRESOS
         * ========================================================
         */
        if (outputs.isNotEmpty) ...[
          const SizedBox(height: 28),

          _SectionBlock(
            title: 'Egresos',
            titleColor: const Color(0xFF689F38),
            onTap: controller.onPayoutsTap,
            children: [
              /**
               * Cada motivo de egreso viene del backend.
               */
              ...outputs.map((item) {
                final int count = _toInt(item['count']);

                return _MoneyRow(
                  label: _movementLabel(name: item['name'], count: count),
                  value: _currency(item['amount']),
                );
              }),

              const Divider(height: 32),

              _MoneyRow(
                label:
                    'Total egresos (${_toInt(movements['count_output'])} movimientos)',
                value: _currency(movements['total_output']),
                isBold: true,
              ),
            ],
          ),
        ],

        /**
         * ========================================================
         * FORMAS DE PAGO
         * ========================================================
         *
         * Por ahora el backend devuelve:
         *
         * payments: {
         *   total: 0,
         *   items: []
         * }
         *
         * Cuando existan items se mostrarán automáticamente.
         */
        if (paymentItems.isNotEmpty) ...[
          const SizedBox(height: 28),

          _SectionBlock(
            title: 'Formas de pago',
            titleColor: const Color(0xFF689F38),
            onTap: controller.onPaymentsSummaryTap,
            children: [
              ...paymentItems.map((item) {
                return _MoneyRow(
                  label: item['name']?.toString() ?? '',
                  value: _currency(item['amount']),
                );
              }),

              const Divider(height: 32),

              _MoneyRow(
                label: 'Total',
                value: _currency(payments['total']),
                isBold: true,
              ),
            ],
          ),
        ],
      ],
    );
  }

  /**
   * ============================================================
   * HELPERS
   * ============================================================
   */

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _currency(dynamic value) {
    final double amount = _toDouble(value);

    return '\$${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _movementLabel({required dynamic name, required int count}) {
    final String movementName = name?.toString() ?? '';

    if (count <= 1) {
      return movementName;
    }

    return '$movementName ($count)';
  }
}

class _ShiftTopActions extends StatelessWidget {
  final bool isClosingShift;
  final VoidCallback onTreasuryTap;
  final Future<void> Function() onCloseShiftTap;

  const _ShiftTopActions({
    required this.isClosingShift,
    required this.onTreasuryTap,
    required this.onCloseShiftTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isClosingShift ? null : onTreasuryTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(72),
              side: const BorderSide(color: Color(0xFF7CB342), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: const Text(
              'GESTIÓN DE TESORERÍA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF689F38),
              ),
            ),
          ),
        ),
        const SizedBox(width: 36),
        Expanded(
          child: OutlinedButton(
            onPressed: isClosingShift ? null : onCloseShiftTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(72),
              side: const BorderSide(color: Color(0xFF7CB342), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: isClosingShift
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'CERRAR EL TURNO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF689F38),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ShiftHeaderInfo extends StatelessWidget {
  final Map<String, dynamic> cash;
  final Map<String, dynamic> session;

  const _ShiftHeaderInfo({required this.cash, required this.session});

  @override
  Widget build(BuildContext context) {
    final String cashName = cash['name']?.toString() ?? '';
    final int sessionId = _toInt(session['id']);
    final String sessionState = session['state']?.toString() ?? '';
    final String openingDate = _formatDate(session['opening_date']);

    return Column(
      children: [
        _InfoRow(left: cashName, right: sessionState),

        const SizedBox(height: 24),

        _InfoRow(left: 'Sesión de caja: #$sessionId', right: openingDate),
      ],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final String raw = value.toString().trim();

    if (raw.isEmpty) {
      return '';
    }

    final DateTime? date = DateTime.tryParse(raw);

    if (date == null) {
      return raw;
    }

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.day)}/'
        '${twoDigits(date.month)}/'
        '${date.year} '
        '${twoDigits(date.hour)}:'
        '${twoDigits(date.minute)}';
  }
}

class _InfoRow extends StatelessWidget {
  final String left;
  final String right;

  const _InfoRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(fontSize: 22, color: Color(0xFF2E2E2E)),
          ),
        ),
        if (right.isNotEmpty)
          Text(
            right,
            style: const TextStyle(fontSize: 22, color: Color(0xFF2E2E2E)),
          ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;
  final List<Widget> children;

  const _SectionBlock({
    required this.title,
    this.titleColor,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor ?? const Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 26),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final VoidCallback? onTap;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 22,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: const Color(0xFF2E2E2E),
    );

    final child = Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(onTap: onTap, child: child);
  }
}
