import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_shift_management_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/pos_settings_app_bar.dart';

class PosShiftSummaryModel {
  final int closeNumber;
  final String openedBy;
  final String openedAt;

  final double previousCashDrawer;
  final double cashPayments;
  final double cashRefunds;
  final double deposited;
  final double payouts;
  final double theoreticalCash;

  final double grossSales;
  final double refunds;
  final double discounts;
  final double netSales;
  final double taxes;

  final double tenderedTotal;
  final double cash;
  final double cashRounding;
  final double card;

  const PosShiftSummaryModel({
    required this.closeNumber,
    required this.openedBy,
    required this.openedAt,
    required this.previousCashDrawer,
    required this.cashPayments,
    required this.cashRefunds,
    required this.deposited,
    required this.payouts,
    required this.theoreticalCash,
    required this.grossSales,
    required this.refunds,
    required this.discounts,
    required this.netSales,
    required this.taxes,
    required this.tenderedTotal,
    required this.cash,
    required this.cashRounding,
    required this.card,
  });
}

class PosShiftManagementService {
  final bool returnEmpty;
  final bool throwError;

  PosShiftManagementService({
    this.returnEmpty = false,
    this.throwError = false,
  });

  Future<PosShiftSummaryModel?> getShiftSummary() async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (throwError) {
      throw Exception('No se pudo obtener el resumen del turno');
    }

    if (returnEmpty) {
      return null;
    }

    return const PosShiftSummaryModel(
      closeNumber: 1,
      openedBy: 'Trece',
      openedAt: '17/2/26 20:35',
      previousCashDrawer: 0.20,
      cashPayments: 14.10,
      cashRefunds: 0.00,
      deposited: 15.00,
      payouts: 15.00,
      theoreticalCash: 14.30,
      grossSales: 16.85,
      refunds: 0.00,
      discounts: 0.00,
      netSales: 16.85,
      taxes: 0.00,
      tenderedTotal: 16.85,
      cash: 14.10,
      cashRounding: 0.00,
      card: 2.75,
    );
  }
}
class PosShiftManagementLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const PosShiftManagementLayout({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosShiftManagementController(),
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
  late final PosShiftManagementService _service;

  bool _isLoading = false;
  PosShiftSummaryModel? _summary;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = PosShiftManagementService(
      returnEmpty: false,
      throwError: false,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getShiftSummary();

      if (!mounted) return;

      setState(() {
        _summary = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _summary = null;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadAfterCloseShift() async {
    final controller = context.read<PosShiftManagementController>();
    final wasClosed = await controller.onCloseShiftTap();

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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_summary == null) {
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
                          : 'Ocurrió un problema al obtener los datos del turno.',
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1030),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: _ShiftSummaryContent(
                      summary: _summary!,
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
  final PosShiftSummaryModel summary;
  final PosShiftManagementController controller;
  final Future<void> Function() onCloseShiftTap;

  const _ShiftSummaryContent({
    required this.summary,
    required this.controller,
    required this.onCloseShiftTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShiftTopActions(
          isClosingShift: controller.isClosingShift,
          onTreasuryTap: controller.onTreasuryTap,
          onCloseShiftTap: onCloseShiftTap,
        ),
        const SizedBox(height: 40),
        _ShiftHeaderInfo(summary: summary),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 28),
        _SectionBlock(
          title: 'Cajón de efectivo',
          titleColor: const Color(0xFF689F38),
          onTap: controller.onCashDrawerTap,
          children: [
            _MoneyRow(
              label: 'Fondo de caja anterior',
              value: _currency(summary.previousCashDrawer),
              onTap: controller.onPreviousCashDrawerTap,
            ),
            _MoneyRow(
              label: 'Cobros en efectivo',
              value: _currency(summary.cashPayments),
              onTap: controller.onCashPaymentsTap,
            ),
            _MoneyRow(
              label: 'Reembolsos en efectivo',
              value: _currency(summary.cashRefunds),
              onTap: controller.onCashRefundsTap,
            ),
            _MoneyRow(
              label: 'Depositado',
              value: _currency(summary.deposited),
              onTap: controller.onDepositedTap,
            ),
            _MoneyRow(
              label: 'Pagos/Salidas',
              value: _currency(summary.payouts),
              onTap: controller.onPayoutsTap,
            ),
            const Divider(height: 32),
            _MoneyRow(
              label: 'Efectivo teórico en caja',
              value: _currency(summary.theoreticalCash),
              isBold: true,
              onTap: controller.onTheoreticalCashTap,
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionBlock(
          title: 'Resumen de ventas',
          titleColor: const Color(0xFF689F38),
          onTap: controller.onSalesSummaryTap,
          children: [
            _MoneyRow(
              label: 'Ventas brutas',
              value: _currency(summary.grossSales),
              isBold: true,
              onTap: controller.onGrossSalesTap,
            ),
            _MoneyRow(
              label: 'Reembolsos',
              value: _currency(summary.refunds),
              onTap: controller.onRefundsTap,
            ),
            _MoneyRow(
              label: 'Descuentos',
              value: _currency(summary.discounts),
              onTap: controller.onDiscountsTap,
            ),
            const Divider(height: 32),
            _MoneyRow(
              label: 'Ventas netas',
              value: _currency(summary.netSales),
              isBold: true,
              onTap: controller.onNetSalesTap,
            ),
            _MoneyRow(
              label: 'Impuestos',
              value: _currency(summary.taxes),
              onTap: controller.onTaxesTap,
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionBlock(
          title: '',
          onTap: controller.onPaymentsSummaryTap,
          children: [
            _MoneyRow(
              label: 'Total licitado',
              value: _currency(summary.tenderedTotal),
              isBold: true,
              onTap: controller.onTenderedTotalTap,
            ),
            _MoneyRow(
              label: 'Efectivo',
              value: _currency(summary.cash),
              onTap: controller.onCashTap,
            ),
            _MoneyRow(
              label: 'Redondeo de efectivo',
              value: _currency(summary.cashRounding),
              onTap: controller.onCashRoundingTap,
            ),
            _MoneyRow(
              label: 'Por tarjeta',
              value: _currency(summary.card),
              onTap: controller.onCardTap,
            ),
          ],
        ),
      ],
    );
  }

  static String _currency(double value) {
    return '\$${value.toStringAsFixed(2).replaceAll('.', ',')}';
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
  final PosShiftSummaryModel summary;

  const _ShiftHeaderInfo({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          left: 'Número de cierre de caja: ${summary.closeNumber}',
          right: '',
        ),
        const SizedBox(height: 24),
        _InfoRow(
          left: 'Abierto: ${summary.openedBy}',
          right: summary.openedAt,
        ),
      ],
    );
  }
}


class _InfoRow extends StatelessWidget {
  final String left;
  final String right;

  const _InfoRow({
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF2E2E2E),
            ),
          ),
        ),
        if (right.isNotEmpty)
          Text(
            right,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF2E2E2E),
            ),
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
          Expanded(
            child: Text(label, style: style),
          ),
          Text(value, style: style),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      child: child,
    );
  }
}