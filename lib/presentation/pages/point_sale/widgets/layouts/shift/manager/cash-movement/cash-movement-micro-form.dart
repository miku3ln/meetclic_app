import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../shared/pagination_response.dart';
import '../../../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../../../shared/utils/util_common.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';
import '../../../../../../../widgets/toogle-manager.dart';
import '../../../../molecules/inputs/ps_field_row.dart';
import '../../../../molecules/inputs/ps_input.dart';
import '../../../../sections/product/ps_section_card.dart';
import '../../../tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'cash-movement-micro-controller.dart';

class CashMovementMicroForm extends StatelessWidget {
  final CashMovementMicroController controller;

  const CashMovementMicroForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final List<Widget> listForms = [
          /*
           * ============================================================
           * TIPO DE MOVIMIENTO
           *
           * INCOME  -> Backend 0
           * OUTCOME -> Backend 1
           * ============================================================
           */
          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsSegmentToggle<String>(
                  title: controller.movementTypeLabel,
                  value: controller.movementType!,
                  titleSpacing: 20,
                  itemPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(3),
                  iconSize: 18,
                  spacing: 5,
                  borderRadius: 10,
                  height: 40,
                  itemMinWidth: 70,
                  titleStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  items: const [
                    PsSegmentItem<String>(
                      value: CashMovementMicroController.movementTypeIncome,
                      label: 'Ingreso',
                      activeIcon: Icons.add_circle,
                      inactiveIcon: Icons.add_circle_outline,
                      thumbColor: Colors.green,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                    PsSegmentItem<String>(
                      value: CashMovementMicroController.movementTypeOutcome,
                      label: 'Egreso',
                      activeIcon: Icons.remove_circle,
                      inactiveIcon: Icons.remove_circle_outline,
                      thumbColor: Colors.orange,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                  ],
                  onChanged: controller.setMovementType,
                ),
              ),
            ],
          ),

          AppSpacing.spaceBetweenInputs,

          /*
 * ============================================================
 * FORMA DE PAGO
 *
 * Backend -> types_payments_id
 * ============================================================
 */

          /*
 * ============================================================
 * FORMA DE PAGO
 *
 * Backend -> types_payments_id
 * ============================================================
 */
          PsFieldRow(
            children: [
              PsFieldItem(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
           * TÍTULO
           */
                    Text(
                      controller.paymentTypeLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /*
           * CARRUSEL HORIZONTAL
           */
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ChoiceChip(
                            avatar: const Icon(
                              Icons.payments_outlined,
                              size: 18,
                            ),
                            label: const Text('Efectivo'),
                            selected:
                            controller.paymentTypeId ==
                                CashMovementMicroController.paymentTypeCash,
                            onSelected: (_) {
                              controller.setPaymentType(
                                CashMovementMicroController.paymentTypeCash,
                              );
                            },
                          ),

                          const SizedBox(width: 8),

                          ChoiceChip(
                            avatar: const Icon(Icons.credit_card, size: 18),
                            label: const Text('Tarjeta crédito'),
                            selected:
                            controller.paymentTypeId ==
                                CashMovementMicroController
                                    .paymentTypeCreditCard,
                            onSelected: (_) {
                              controller.setPaymentType(
                                CashMovementMicroController
                                    .paymentTypeCreditCard,
                              );
                            },
                          ),

                          const SizedBox(width: 8),

                          ChoiceChip(
                            avatar: const Icon(
                              Icons.receipt_long_outlined,
                              size: 18,
                            ),
                            label: const Text('Cheque'),
                            selected:
                            controller.paymentTypeId ==
                                CashMovementMicroController.paymentTypeCheck,
                            onSelected: (_) {
                              controller.setPaymentType(
                                CashMovementMicroController.paymentTypeCheck,
                              );
                            },
                          ),

                          const SizedBox(width: 8),

                          ChoiceChip(
                            avatar: const Icon(
                              Icons.account_balance_outlined,
                              size: 18,
                            ),
                            label: const Text('Transferencia'),
                            selected:
                            controller.paymentTypeId ==
                                CashMovementMicroController.paymentTypeTransfer,
                            onSelected: (_) {
                              controller.setPaymentType(
                                CashMovementMicroController.paymentTypeTransfer,
                              );
                            },
                          ),

                          const SizedBox(width: 8),

                          ChoiceChip(
                            avatar: const Icon(
                              Icons.phone_android_outlined,
                              size: 18,
                            ),
                            label: const Text('Dinero electrónico'),
                            selected:
                            controller.paymentTypeId ==
                                CashMovementMicroController
                                    .paymentTypeElectronicMoney,
                            onSelected: (_) {
                              controller.setPaymentType(
                                CashMovementMicroController
                                    .paymentTypeElectronicMoney,
                              );
                            },
                          ),

                          const SizedBox(width: 8),

                          ChoiceChip(
                            avatar: const Icon(
                              Icons.credit_card_outlined,
                              size: 18,
                            ),
                            label: const Text('Tarjeta débito'),
                            selected:
                            controller.paymentTypeId ==
                                CashMovementMicroController
                                    .paymentTypeDebitCard,
                            onSelected: (_) {
                              controller.setPaymentType(
                                CashMovementMicroController
                                    .paymentTypeDebitCard,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    /*
           * ERROR
           */
                    if (controller.paymentTypeTouched &&
                        controller.paymentTypeError != null) ...[
                      const SizedBox(height: 6),

                      Text(
                        controller.paymentTypeError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.spaceBetweenInputs,

          /*
           * ============================================================
           * MOTIVO DEL MOVIMIENTO
           *
           * Backend -> cash_reason_id
           * ============================================================
           */
          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsApiTypeAhead<GenericListItem<Map<String, dynamic>>>(
                  label: controller.cashReasonLabel,
                  value: controller.selectedCashReason,

                  /*
                   * ====================================================
                   * CONSULTAR RAZONES
                   * ====================================================
                   */
                  searchApi: (search) async {
                    return await UtilServicesCash.getCashReasonsSearch(
                      searchPhrase: search,
                    );
                  },

                  /*
                   * ====================================================
                   * TEXTO QUE VE EL USUARIO
                   * ====================================================
                   */
                  getLabel: (item) {
                    return item.title ?? '';
                  },

                  /*
                   * ====================================================
                   * SELECCIÓN
                   * ====================================================
                   */
                  onSelected: (item) {
                    controller.setCashReason(item);
                  },

                  /*
                   * ====================================================
                   * VALIDACIÓN
                   * ====================================================
                   */
                  requiredField: true,

                  error: controller.cashReasonError,

                  isTouched: controller.cashReasonTouched,

                  isValid:
                  controller.cashReasonError == null &&
                      controller.cashReasonId != null &&
                      controller.cashReasonId! > 0,
                ),
              ),
            ],
          ),

          AppSpacing.spaceBetweenInputs,

          /*
           * ============================================================
           * VALOR DEL MOVIMIENTO
           *
           * Backend -> rode
           * ============================================================
           */
          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsInput(
                  label: controller.amountLabel,
                  value: formatInput(controller.amount),
                  requiredField: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: controller.setAmount,
                  error: controller.amountError,
                  isTouched: controller.amountTouched,
                  isValid: controller.amountError == null,
                ),
              ),
            ],
          ),

          AppSpacing.spaceBetweenInputs,

          /*
           * ============================================================
           * TIPO DE TRANSACCIÓN
           *
           * INDIRECT -> Backend 0
           * DIRECT   -> Backend 1
           * ============================================================
           */
          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsSegmentToggle<String>(
                  title: controller.transactionTypeLabel,
                  value: controller.transactionType!,
                  titleSpacing: 20,
                  itemPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(3),
                  iconSize: 18,
                  spacing: 5,
                  borderRadius: 10,
                  height: 40,
                  itemMinWidth: 90,
                  titleStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  items: const [
                    PsSegmentItem<String>(
                      value: CashMovementMicroController.transactionTypeDirect,
                      label: 'Directo',
                      activeIcon: Icons.swap_horiz,
                      inactiveIcon: Icons.swap_horiz,
                      thumbColor: Colors.green,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                    PsSegmentItem<String>(
                      value:
                      CashMovementMicroController.transactionTypeIndirect,
                      label: 'Indirecto',
                      activeIcon: Icons.alt_route,
                      inactiveIcon: Icons.alt_route,
                      thumbColor: Colors.orange,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                  ],
                  onChanged: controller.setTransactionType,
                ),
              ),
            ],
          ),

          AppSpacing.spaceBetweenInputs,

          /*
           * ============================================================
           * DETALLE
           *
           * Backend -> details
           * ============================================================
           */
          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsInput(
                  label: controller.detailsLabel,
                  value: controller.details ?? '',
                  requiredField: false,
                  onChanged: controller.setDetails,
                  error: controller.detailsError,
                  isTouched: controller.detailsTouched,
                  isValid: controller.detailsError == null,
                ),
              ),
            ],
          ),
        ];

        return PsSectionCard(
          title: 'Movimiento de caja',
          child: Column(
            children: [AppSpacing.spaceBetweenInputs, ...listForms],
          ),
        );
      },
    );
  }
}