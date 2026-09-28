import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/shift/manager/util.dart';

import '../../../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../state/pos_shift_management_controller.dart';


class InfoRow extends StatelessWidget {
  final String left;
  final String right;

  const InfoRow({required this.left, required this.right});

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

class SectionBlock extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;
  final List<Widget> children;

  const SectionBlock({
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
class MoneyRow extends StatelessWidget {
  final String label;
  final String value;

  final bool isBold;
  final VoidCallback? onTap;

  /*
   * Personalización visual.
   */
  final Color? labelColor;
  final Color? valueColor;

  final double labelFontSize;
  final double valueFontSize;

  final FontWeight? labelFontWeight;
  final FontWeight? valueFontWeight;

  final IconData? icon;
  final Color? iconColor;

  final Color? backgroundColor;

  final EdgeInsetsGeometry padding;
  final double bottomSpacing;

  const MoneyRow({
    super.key,
    required this.label,
    required this.value,

    this.isBold = false,
    this.onTap,

    this.labelColor,
    this.valueColor,

    this.labelFontSize = 16,
    this.valueFontSize = 17,

    this.labelFontWeight,
    this.valueFontWeight,

    this.icon,
    this.iconColor,

    this.backgroundColor,

    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),

    this.bottomSpacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final effectiveLabelWeight =
        labelFontWeight ??
            (isBold
                ? FontWeight.w700
                : FontWeight.w400);

    final effectiveValueWeight =
        valueFontWeight ??
            (isBold
                ? FontWeight.w700
                : FontWeight.w600);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          /*
           * ICONO OPCIONAL
           */
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color:
              iconColor ??
                  tokens.iconMuted,
            ),

            const SizedBox(width: 10),
          ],

          /*
           * LABEL
           */
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight:
                effectiveLabelWeight,
                color:
                labelColor ??
                    tokens.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 16),

          /*
           * VALOR
           */
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight:
              effectiveValueWeight,
              color:
              valueColor ??
                  tokens.textPrimary,
            ),
          ),
        ],
      ),
    );

    final child = Padding(
      padding: EdgeInsets.only(
        bottom: bottomSpacing,
      ),
      child: content,
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }
}
class ShiftHeaderInfo extends StatelessWidget {
  final Map<String, dynamic> cash;
  final Map<String, dynamic> session;

  const ShiftHeaderInfo({required this.cash, required this.session});

  @override
  Widget build(BuildContext context) {
    final String cashName = cash['name']?.toString() ?? '';
    final int sessionId = _toInt(session['id']);
    final String sessionState = session['state']?.toString() ?? '';
    final String openingDate = _formatDate(session['opening_date']);

    return Column(
      children: [
        InfoRow(left: cashName, right: sessionState),

        const SizedBox(height: 24),

        InfoRow(left: 'Sesión de caja: #$sessionId', right: openingDate),
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
class ShiftSummaryContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final PosShiftManagementController controller;
  final Future<void> Function() onCloseShiftTap;

  const ShiftSummaryContent({
    required this.data,
    required this.controller,
    required this.onCloseShiftTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    /**
     * ============================================================
     * DATA
     * ============================================================
     */

    final Map<String, dynamic> cash =
    UtilCashCommon.map(data['cash']);

    final Map<String, dynamic> session =
    UtilCashCommon.map(data['session']);

    final Map<String, dynamic> movements =
    UtilCashCommon.map(data['movements']);

    final Map<String, dynamic> payments =
    UtilCashCommon.map(data['payments']);

    final Map<String, dynamic> closing =
    UtilCashCommon.map(data['closing']);

    /**
     * Listas dinámicas.
     */
    final List<Map<String, dynamic>> inputs =
    UtilCashCommon.list(
      movements['inputs'],
    );

    final List<Map<String, dynamic>> outputs =
    UtilCashCommon.list(
      movements['outputs'],
    );

    final List<Map<String, dynamic>> paymentItems =
    UtilCashCommon.list(
      payments['items'],
    );

    /**
     * ============================================================
     * VIEW
     * ============================================================
     */

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        /**
         * ========================================================
         * INFORMACIÓN DE CAJA / SESIÓN
         * ========================================================
         */
        ShiftHeaderInfo(
          cash: cash,
          session: session,
        ),

        const SizedBox(height: 24),

        Divider(
          height: 1,
          color: tokens.divider,
        ),

        const SizedBox(height: 28),

        /**
         * ========================================================
         * CAJÓN DE EFECTIVO
         * ========================================================
         */
        SectionBlock(
          title: 'Cajón de efectivo',
          titleColor: tokens.primary,
          onTap: controller.onCashDrawerTap,
          children: [
            /**
             * Efectivo inicial.
             */
            MoneyRow(
              label: 'Efectivo de apertura',
              value: UtilCashCommon.currency(
                session['opening_amount'],
              ),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: tokens.iconMuted,
              labelColor: tokens.textSecondary,
              valueColor: tokens.textPrimary,
            ),

            const SizedBox(height: 6),

            /**
             * Ingresos.
             */
            MoneyRow(
              label: 'Ingresos',
              value: UtilCashCommon.currency(
                movements['total_input'],
              ),
              icon: Icons.arrow_downward_rounded,
              iconColor: tokens.success,
              labelColor: tokens.textPrimary,
              valueColor: tokens.success,
              backgroundColor: tokens.successBackground,
              valueFontWeight: FontWeight.w700,
            ),

            const SizedBox(height: 8),

            /**
             * Egresos.
             */
            MoneyRow(
              label: 'Egresos',
              value: UtilCashCommon.currency(
                movements['total_output'],
              ),
              icon: Icons.arrow_upward_rounded,
              iconColor: tokens.error,
              labelColor: tokens.textPrimary,
              valueColor: tokens.error,
              backgroundColor: tokens.errorBackground,
              valueFontWeight: FontWeight.w700,
            ),

            const SizedBox(height: 18),

            Divider(
              height: 1,
              color: tokens.divider,
            ),

            const SizedBox(height: 18),

            /**
             * ----------------------------------------------------
             * DATO PRINCIPAL DEL CAJÓN
             * ----------------------------------------------------
             */
            MoneyRow(
              label: 'Efectivo teórico en caja',
              value: UtilCashCommon.currency(
                closing['expected_amount'],
              ),
              isBold: true,
              icon: Icons.point_of_sale_rounded,
              iconColor: tokens.primary,
              labelColor: tokens.textPrimary,
              valueColor: tokens.primary,
              backgroundColor: tokens.selectedBackground,
              labelFontSize: 17,
              valueFontSize: 24,
              labelFontWeight: FontWeight.w700,
              valueFontWeight: FontWeight.w700,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
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
          const SizedBox(height: 36),

          SectionBlock(
            title: 'Ingresos',
            titleColor: tokens.success,
            onTap: controller.onCashPaymentsTap,
            children: [
              /**
               * Cada motivo de ingreso.
               */
              ...inputs.map((item) {
                final int count =
                UtilCashCommon.toInt(
                  item['count'],
                );

                return MoneyRow(
                  label:
                  UtilCashCommon.movementLabel(
                    name: item['name'],
                    count: count,
                  ),
                  value:
                  UtilCashCommon.currency(
                    item['amount'],
                  ),
                  labelFontSize: 15,
                  valueFontSize: 16,
                  labelColor:
                  tokens.textSecondary,
                  valueColor:
                  tokens.textPrimary,
                  bottomSpacing: 2,
                );
              }),

              const SizedBox(height: 12),

              Divider(
                height: 1,
                color: tokens.divider,
              ),

              const SizedBox(height: 10),

              /**
               * Total ingresos.
               */
              MoneyRow(
                label:
                'Total ingresos (${UtilCashCommon.toInt(movements['count_input'])} movimientos)',
                value:
                UtilCashCommon.currency(
                  movements['total_input'],
                ),
                isBold: true,
                icon:
                Icons.arrow_downward_rounded,
                iconColor:
                tokens.success,
                labelColor:
                tokens.textPrimary,
                valueColor:
                tokens.success,
                labelFontSize: 16,
                valueFontSize: 18,
                labelFontWeight:
                FontWeight.w700,
                valueFontWeight:
                FontWeight.w700,
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
          const SizedBox(height: 36),

          SectionBlock(
            title: 'Egresos',
            titleColor: tokens.error,
            onTap: controller.onPayoutsTap,
            children: [
              /**
               * Cada motivo de egreso.
               */
              ...outputs.map((item) {
                final int count =
                UtilCashCommon.toInt(
                  item['count'],
                );

                return MoneyRow(
                  label:
                  UtilCashCommon.movementLabel(
                    name: item['name'],
                    count: count,
                  ),
                  value:
                  UtilCashCommon.currency(
                    item['amount'],
                  ),
                  labelFontSize: 15,
                  valueFontSize: 16,
                  labelColor:
                  tokens.textSecondary,
                  valueColor:
                  tokens.textPrimary,
                  bottomSpacing: 2,
                );
              }),

              const SizedBox(height: 12),

              Divider(
                height: 1,
                color: tokens.divider,
              ),

              const SizedBox(height: 10),

              /**
               * Total egresos.
               */
              MoneyRow(
                label:
                'Total egresos (${UtilCashCommon.toInt(movements['count_output'])} movimientos)',
                value:
                UtilCashCommon.currency(
                  movements['total_output'],
                ),
                isBold: true,
                icon:
                Icons.arrow_upward_rounded,
                iconColor:
                tokens.error,
                labelColor:
                tokens.textPrimary,
                valueColor:
                tokens.error,
                labelFontSize: 16,
                valueFontSize: 18,
                labelFontWeight:
                FontWeight.w700,
                valueFontWeight:
                FontWeight.w700,
              ),
            ],
          ),
        ],

        /**
         * ========================================================
         * FORMAS DE PAGO
         * ========================================================
         */
        if (paymentItems.isNotEmpty) ...[
          const SizedBox(height: 36),

          SectionBlock(
            title: 'Formas de pago',
            titleColor: tokens.primary,
            onTap:
            controller.onPaymentsSummaryTap,
            children: [
              /**
               * Cada forma de pago.
               */
              ...paymentItems.map((item) {
                return MoneyRow(
                  label:
                  item['name']?.toString() ??
                      '',
                  value:
                  UtilCashCommon.currency(
                    item['amount'],
                  ),
                  icon:
                  Icons.payments_outlined,
                  iconColor:
                  tokens.iconMuted,
                  labelFontSize: 15,
                  valueFontSize: 16,
                  labelColor:
                  tokens.textSecondary,
                  valueColor:
                  tokens.textPrimary,
                  bottomSpacing: 2,
                );
              }),

              const SizedBox(height: 12),

              Divider(
                height: 1,
                color: tokens.divider,
              ),

              const SizedBox(height: 10),

              /**
               * Total formas de pago.
               */
              MoneyRow(
                label: 'Total',
                value:
                UtilCashCommon.currency(
                  payments['total'],
                ),
                isBold: true,
                icon:
                Icons.account_balance_wallet_outlined,
                iconColor:
                tokens.primary,
                labelColor:
                tokens.textPrimary,
                valueColor:
                tokens.primary,
                labelFontSize: 16,
                valueFontSize: 18,
                labelFontWeight:
                FontWeight.w700,
                valueFontWeight:
                FontWeight.w700,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/**
 * ============================================================
 * HELPERS
 * ============================================================
 */



class ShiftTopActions extends StatelessWidget {
  final bool isClosingShift;
  final VoidCallback onTreasuryTap;
  final VoidCallback onMovementManagerTap;
  final Future<void> Function() onCloseShiftTap;

  const ShiftTopActions({
    required this.isClosingShift,
    required this.onTreasuryTap,
    required this.onMovementManagerTap,
    required this.onCloseShiftTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Material(
      color: tokens.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*
             * ======================================================
             * REGISTRAR MOVIMIENTO
             * ======================================================
             */
            ShiftManagementAction(
              icon: Icons.add_circle_outline_rounded,
              label: 'Registrar movimiento',
              enabled: !isClosingShift,
              onTap: onMovementManagerTap,
            ),

            Divider(height: 1, color: tokens.divider),

            /*
             * ======================================================
             * CERRAR TURNO
             * ======================================================
             */
            ShiftManagementAction(
              icon: Icons.lock_clock_outlined,
              label: 'Cerrar turno',
              enabled: !isClosingShift,
              loading: isClosingShift,
              onTap: () {
                onCloseShiftTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/*
 * ================================================================
 * ITEM DE GESTIÓN
 * ================================================================
 */

class ShiftManagementAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  final bool enabled;
  final bool loading;

  const ShiftManagementAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return InkWell(
      onTap: enabled && !loading ? onTap : null,

      borderRadius: BorderRadius.circular(8),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

        child: Row(
          children: [
            /*
             * ======================================================
             * ICONO / LOADING
             * ======================================================
             */
            if (loading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.primary,
                ),
              )
            else
              Icon(
                icon,
                size: 21,
                color: enabled ? tokens.primary : tokens.disabled,
              ),

            const SizedBox(width: 12),

            /*
             * ======================================================
             * TEXTO
             * ======================================================
             */
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? tokens.textPrimary : tokens.textDisabled,
                ),
              ),
            ),

            /*
             * ======================================================
             * INDICADOR
             * ======================================================
             */
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: enabled ? tokens.iconMuted : tokens.disabled,
            ),
          ],
        ),
      ),
    );
  }
}

