import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../util.dart';
import 'shift-summary-content.dart';

/**
 * ============================================================
 * RESULTADO DEL MODAL DE CIERRE
 * ============================================================
 */
class ShiftCloseModalResult {
  final bool success;
  final String message;
  final String type;
  final Map<String, dynamic>? data;

  const ShiftCloseModalResult({
    required this.success,
    required this.message,
    required this.type,
    this.data,
  });
}

/**
 * ============================================================
 * MODAL DE CIERRE DE TURNO
 * ============================================================
 */
class ShiftCloseModal {
  ShiftCloseModal._();

  /**
   * ============================================================
   * TIPOS DE RESULTADO
   * ============================================================
   */
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
  static const String dismissed = 'dismissed';
  static const String error = 'error';

  /**
   * ============================================================
   * SHOW
   * ============================================================
   */
  static Future<ShiftCloseModalResult> show({
    required BuildContext context,
    required Map<String, dynamic> dataManagerCash,
    required VoidCallback onCashDrawerTap,
    required VoidCallback onTheoreticalCashTap,

    /**
     * Callback que ejecutará realmente
     * el proceso de cierre.
     */
    required Future<ShiftCloseModalResult> Function({
    required double closingAmount,
    required String closingDetails,
    })
    onSubmit,
  }) async {
    final tokens = AppThemeTokens.of(context);

    /**
     * ============================================================
     * CONTROLLERS
     * ============================================================
     */
    final TextEditingController receivedAmountController =
    TextEditingController();

    final TextEditingController detailsController =
    TextEditingController();

    /**
     * ============================================================
     * ESTADO DEL PROCESO
     * ============================================================
     */
    bool isProcessing = false;
    String? processError;

    /**
     * ============================================================
     * DATA
     * ============================================================
     */
    final Map<String, dynamic> session =
    UtilCashCommon.map(
      dataManagerCash['session'],
    );

    final Map<String, dynamic> movements =
    UtilCashCommon.map(
      dataManagerCash['movements'],
    );

    final Map<String, dynamic> closing =
    UtilCashCommon.map(
      dataManagerCash['closing'],
    );

    /**
     * ============================================================
     * MODAL
     * ============================================================
     */
    final ShiftCloseModalResult? result =
    await showModalBottomSheet<ShiftCloseModalResult>(
      context: context,
      isScrollControlled: true,

      /**
       * El modal no se puede cerrar
       * tocando fuera.
       */
      isDismissible: false,

      /**
       * El modal no se puede arrastrar
       * hacia abajo para cerrarlo.
       */
      enableDrag: false,

      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,

      builder: (modalContext) {
        /**
         * StatefulBuilder permite actualizar solamente
         * el contenido interno del modal.
         *
         * Se utiliza para:
         *
         * - habilitar / deshabilitar CERRAR TURNO
         * - mostrar loading global
         * - bloquear TODO el modal
         * - mostrar errores
         */
        return StatefulBuilder(
          builder: (context, setModalState) {
            /**
             * ====================================================
             * VALIDACIÓN EFECTIVO RECIBIDO
             * ====================================================
             */
            final String normalizedAmount =
            receivedAmountController.text
                .trim()
                .replaceAll(',', '.');

            final double? receivedAmount =
            double.tryParse(
              normalizedAmount,
            );

            /**
             * El botón solamente se habilita
             * cuando existe un valor mayor a cero.
             */
            final bool canClose =
                receivedAmount != null &&
                    receivedAmount > 0;

            return PopScope(
              /**
               * El cierre del modal lo controlamos
               * nosotros.
               */
              canPop: false,

              /**
               * ==================================================
               * STACK PRINCIPAL
               * ==================================================
               *
               * Aquí tenemos:
               *
               * 1. Todo el contenido normal.
               * 2. El loading por encima de TODO.
               */
              child: Stack(
                children: [
                  /**
                   * ==================================================
                   * CONTENIDO NORMAL DEL MODAL
                   * ==================================================
                   */
                  SafeArea(
                    top: false,

                    child: Padding(
                      /**
                       * Permite que el modal se desplace
                       * cuando aparece el teclado.
                       */
                      padding: EdgeInsets.only(
                        bottom:
                        MediaQuery.of(
                          context,
                        ).viewInsets.bottom,
                      ),

                      child: Container(
                        width:
                        double.infinity,

                        padding:
                        const EdgeInsets
                            .fromLTRB(
                          20,
                          12,
                          20,
                          24,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          tokens.surface,

                          borderRadius:
                          const BorderRadius
                              .vertical(
                            top:
                            Radius.circular(
                              24,
                            ),
                          ),
                        ),

                        child:
                        SingleChildScrollView(
                          keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior
                              .onDrag,

                          child: Column(
                            mainAxisSize:
                            MainAxisSize.min,

                            children: [
                              /**
                               * ==================================================
                               * BARRA SUPERIOR
                               * ==================================================
                               */
                              Container(
                                width: 42,
                                height: 4,

                                decoration:
                                BoxDecoration(
                                  color:
                                  tokens.divider,

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    10,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              /**
                               * ==================================================
                               * TÍTULO
                               * ==================================================
                               */
                              Row(
                                children: [
                                  Icon(
                                    Icons
                                        .lock_clock_rounded,

                                    size: 28,

                                    color: tokens
                                        .iconPrimary,
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child:
                                    Text(
                                      'Cerrar turno',

                                      style:
                                      TextStyle(
                                        fontSize:
                                        20,

                                        fontWeight:
                                        FontWeight
                                            .w700,

                                        color: tokens
                                            .textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Align(
                                alignment:
                                Alignment
                                    .centerLeft,

                                child: Text(
                                  'Revise la información antes de cerrar el turno.',

                                  style:
                                  TextStyle(
                                    color: tokens
                                        .textSecondary,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              /**
                               * ==================================================
                               * CAJÓN
                               * ==================================================
                               */
                              SectionBlock(
                                title:
                                'Cajón de efectivo',

                                titleColor:
                                tokens.primary,

                                onTap:
                                onCashDrawerTap,

                                children: [
                                  /**
                                   * ==================================================
                                   * EFECTIVO INICIAL
                                   * ==================================================
                                   */
                                  MoneyRow(
                                    label:
                                    'Efectivo de apertura',

                                    value:
                                    UtilCashCommon
                                        .currency(
                                      session[
                                      'opening_amount'],
                                    ),

                                    icon: Icons
                                        .account_balance_wallet_outlined,

                                    iconColor:
                                    tokens
                                        .iconMuted,

                                    labelColor:
                                    tokens
                                        .textSecondary,

                                    valueColor:
                                    tokens
                                        .textPrimary,
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  /**
                                   * ==================================================
                                   * INGRESOS
                                   * ==================================================
                                   */
                                  MoneyRow(
                                    label:
                                    'Ingresos',

                                    value:
                                    UtilCashCommon
                                        .currency(
                                      movements[
                                      'total_input'],
                                    ),

                                    icon: Icons
                                        .arrow_downward_rounded,

                                    iconColor:
                                    tokens
                                        .success,

                                    labelColor:
                                    tokens
                                        .textPrimary,

                                    valueColor:
                                    tokens
                                        .success,

                                    backgroundColor:
                                    tokens
                                        .successBackground,

                                    valueFontWeight:
                                    FontWeight
                                        .w700,
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  /**
                                   * ==================================================
                                   * EGRESOS
                                   * ==================================================
                                   */
                                  MoneyRow(
                                    label:
                                    'Egresos',

                                    value:
                                    UtilCashCommon
                                        .currency(
                                      movements[
                                      'total_output'],
                                    ),

                                    icon: Icons
                                        .arrow_upward_rounded,

                                    iconColor:
                                    tokens.error,

                                    labelColor:
                                    tokens
                                        .textPrimary,

                                    valueColor:
                                    tokens.error,

                                    backgroundColor:
                                    tokens
                                        .errorBackground,

                                    valueFontWeight:
                                    FontWeight
                                        .w700,
                                  ),

                                  const SizedBox(
                                    height: 18,
                                  ),

                                  Divider(
                                    height: 1,
                                    color:
                                    tokens.divider,
                                  ),

                                  const SizedBox(
                                    height: 18,
                                  ),

                                  /**
                                   * ------------------------------------------------
                                   * DATO PRINCIPAL DEL CAJÓN
                                   * ------------------------------------------------
                                   */
                                  MoneyRow(
                                    label:
                                    'Efectivo teórico en caja',

                                    value:
                                    UtilCashCommon
                                        .currency(
                                      closing[
                                      'expected_amount'],
                                    ),

                                    isBold:
                                    true,

                                    icon: Icons
                                        .point_of_sale_rounded,

                                    iconColor:
                                    tokens.primary,

                                    labelColor:
                                    tokens
                                        .textPrimary,

                                    valueColor:
                                    tokens.primary,

                                    backgroundColor:
                                    tokens
                                        .selectedBackground,

                                    labelFontSize:
                                    17,

                                    valueFontSize:
                                    24,

                                    labelFontWeight:
                                    FontWeight
                                        .w700,

                                    valueFontWeight:
                                    FontWeight
                                        .w700,

                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal:
                                      16,
                                      vertical:
                                      16,
                                    ),

                                    onTap:
                                    onTheoreticalCashTap,
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              Divider(
                                color:
                                tokens.divider,
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              /**
                               * ==================================================
                               * DATOS DE CIERRE
                               * ==================================================
                               */
                              Align(
                                alignment:
                                Alignment
                                    .centerLeft,

                                child: Text(
                                  'Datos de cierre',

                                  style:
                                  TextStyle(
                                    fontSize:
                                    17,

                                    fontWeight:
                                    FontWeight
                                        .w700,

                                    color: tokens
                                        .textPrimary,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              /**
                               * ==================================================
                               * EFECTIVO RECIBIDO
                               * ==================================================
                               */
                              TextField(
                                controller:
                                receivedAmountController,

                                keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                                  decimal:
                                  true,
                                ),

                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .allow(
                                    RegExp(
                                      r'^\d*[.,]?\d{0,2}',
                                    ),
                                  ),
                                ],

                                onChanged:
                                    (_) {
                                  setModalState(
                                        () {
                                      /**
                                       * Si modifica el valor
                                       * limpiamos el error anterior.
                                       */
                                      processError =
                                      null;
                                    },
                                  );
                                },

                                decoration:
                                InputDecoration(
                                  labelText:
                                  'Efectivo recibido',

                                  hintText:
                                  '0.00',

                                  prefixText:
                                  '\$ ',

                                  filled:
                                  true,

                                  fillColor:
                                  tokens
                                      .inputFill,

                                  border:
                                  const OutlineInputBorder(),

                                  helperText:
                                  'Ingrese el efectivo contado al cierre del turno.',

                                  helperStyle:
                                  TextStyle(
                                    color: tokens
                                        .textSecondary,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              /**
                               * ==================================================
                               * DETALLE
                               * ==================================================
                               */
                              TextField(
                                controller:
                                detailsController,

                                keyboardType:
                                TextInputType
                                    .multiline,

                                textCapitalization:
                                TextCapitalization
                                    .sentences,

                                minLines: 2,
                                maxLines: 4,

                                onChanged:
                                    (_) {
                                  /**
                                   * Si modifica el detalle
                                   * limpiamos el error anterior.
                                   */
                                  if (processError !=
                                      null) {
                                    setModalState(
                                          () {
                                        processError =
                                        null;
                                      },
                                    );
                                  }
                                },

                                decoration:
                                InputDecoration(
                                  labelText:
                                  'Detalle',

                                  hintText:
                                  'Observaciones del cierre',

                                  alignLabelWithHint:
                                  true,

                                  filled:
                                  true,

                                  fillColor:
                                  tokens
                                      .inputFill,

                                  border:
                                  const OutlineInputBorder(),
                                ),
                              ),

                              /**
                               * ==================================================
                               * ERROR DEL PROCESO
                               * ==================================================
                               */
                              if (processError !=
                                  null) ...[
                                const SizedBox(
                                  height: 16,
                                ),

                                Container(
                                  width:
                                  double.infinity,

                                  padding:
                                  const EdgeInsets
                                      .all(
                                    12,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color: tokens
                                        .errorBackground,

                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),

                                  child:
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                    children: [
                                      Icon(
                                        Icons
                                            .error_outline_rounded,

                                        color:
                                        tokens.error,

                                        size:
                                        20,
                                      ),

                                      const SizedBox(
                                        width:
                                        10,
                                      ),

                                      Expanded(
                                        child:
                                        Text(
                                          processError!,

                                          style:
                                          TextStyle(
                                            color: tokens
                                                .error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(
                                height: 24,
                              ),

                              Divider(
                                color:
                                tokens.divider,
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              /**
                               * ==================================================
                               * ACCIONES
                               * ==================================================
                               */
                              Row(
                                children: [
                                  /**
                                   * ==================================================
                                   * CANCELAR
                                   * ==================================================
                                   */
                                  Expanded(
                                    child:
                                    OutlinedButton(
                                      onPressed:
                                          () {
                                        FocusScope.of(
                                          modalContext,
                                        ).unfocus();

                                        Navigator.of(
                                          modalContext,
                                        ).pop(
                                          const ShiftCloseModalResult(
                                            success:
                                            false,
                                            message:
                                            'Cierre de turno cancelado.',
                                            type:
                                            cancelled,
                                            data:
                                            null,
                                          ),
                                        );
                                      },

                                      child:
                                      const Text(
                                        'CANCELAR',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  /**
                                   * ==================================================
                                   * CERRAR TURNO
                                   * ==================================================
                                   */
                                  Expanded(
                                    child:
                                    FilledButton(
                                      onPressed:
                                      canClose
                                          ? () async {
                                        /**
                                         * ==================================
                                         * QUITAR TECLADO
                                         * ==================================
                                         */
                                        FocusScope.of(
                                          modalContext,
                                        ).unfocus();

                                        /**
                                         * ==================================
                                         * ACTIVAR LOADING GLOBAL
                                         * ==================================
                                         */
                                        setModalState(
                                              () {
                                            isProcessing =
                                            true;

                                            processError =
                                            null;
                                          },
                                        );

                                        try {
                                          /**
                                           * ================================
                                           * EJECUTAR CALLBACK
                                           * ================================
                                           *
                                           * Aquí se ejecuta el servicio
                                           * enviado desde:
                                           *
                                           * onCloseShiftTap()
                                           */
                                          final ShiftCloseModalResult
                                          submitResult =
                                          await onSubmit(
                                            closingAmount:
                                            receivedAmount!,
                                            closingDetails:
                                            detailsController.text.trim(),
                                          );

                                          /**
                                           * Validamos que el modal
                                           * todavía exista.
                                           */
                                          if (!modalContext
                                              .mounted) {
                                            return;
                                          }

                                          /**
                                           * ================================
                                           * ERROR DEL SERVICIO
                                           * ================================
                                           *
                                           * Quitamos el loading.
                                           *
                                           * NO cerramos el modal.
                                           *
                                           * Mostramos el mensaje.
                                           */
                                          if (!submitResult
                                              .success) {
                                            setModalState(
                                                  () {
                                                isProcessing =
                                                false;

                                                processError =
                                                    submitResult.message;
                                              },
                                            );

                                            return;
                                          }

                                          /**
                                           * ================================
                                           * SUCCESS
                                           * ================================
                                           *
                                           * Solamente aquí cerramos
                                           * el modal.
                                           */
                                          Navigator.of(
                                            modalContext,
                                          ).pop(
                                            submitResult,
                                          );
                                        } catch (e) {
                                          /**
                                           * Validamos que el modal
                                           * todavía exista.
                                           */
                                          if (!modalContext
                                              .mounted) {
                                            return;
                                          }

                                          /**
                                           * ================================
                                           * ERROR INESPERADO
                                           * ================================
                                           *
                                           * Quitamos el loading.
                                           *
                                           * El modal permanece abierto.
                                           */
                                          setModalState(
                                                () {
                                              isProcessing =
                                              false;

                                              processError =
                                              'Ocurrió un error al cerrar el turno.';
                                            },
                                          );
                                        }
                                      }
                                          : null,

                                      /**
                                       * Ya NO ponemos loading
                                       * dentro del botón.
                                       *
                                       * El loading ahora está
                                       * centrado sobre TODO
                                       * el modal.
                                       */
                                      child:
                                      const Text(
                                        'CERRAR TURNO',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  /**
                   * ==================================================
                   * LOADING GLOBAL
                   * ==================================================
                   *
                   * IMPORTANTE:
                   *
                   * Este Positioned.fill está DESPUÉS
                   * del contenido.
                   *
                   * Por eso se dibuja encima de TODO.
                   *
                   * Mientras isProcessing == true:
                   *
                   * - bloquea TextFields
                   * - bloquea CANCELAR
                   * - bloquea CERRAR TURNO
                   * - bloquea SectionBlock
                   * - bloquea MoneyRow
                   * - bloquea scroll
                   * - bloquea cualquier tap
                   */
                  if (isProcessing)
                    Positioned.fill(
                      child: Stack(
                        alignment:
                        Alignment.center,

                        children: [
                          /**
                           * ==========================================
                           * BARRERA
                           * ==========================================
                           *
                           * Bloquea toda interacción
                           * con el contenido inferior.
                           */
                          ModalBarrier(
                            dismissible:
                            false,

                            color: tokens
                                .surface
                                .withValues(
                              alpha:
                              0.82,
                            ),
                          ),

                          /**
                           * ==========================================
                           * PROGRESS CENTRAL
                           * ==========================================
                           */
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal:
                              30,
                              vertical:
                              26,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              tokens.surface,

                              borderRadius:
                              BorderRadius
                                  .circular(
                                16,
                              ),

                              border:
                              Border.all(
                                color:
                                tokens.border,
                              ),
                            ),

                            child:
                            Column(
                              mainAxisSize:
                              MainAxisSize
                                  .min,

                              children: [
                                /**
                                 * PROGRESS
                                 */
                                CircularProgressIndicator(
                                  color:
                                  tokens.primary,
                                ),

                                const SizedBox(
                                  height:
                                  18,
                                ),

                                /**
                                 * MENSAJE PRINCIPAL
                                 */
                                Text(
                                  'Cerrando turno...',

                                  style:
                                  TextStyle(
                                    fontSize:
                                    16,

                                    fontWeight:
                                    FontWeight
                                        .w700,

                                    color: tokens
                                        .textPrimary,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                  6,
                                ),

                                /**
                                 * MENSAJE SECUNDARIO
                                 */
                                Text(
                                  'Espere un momento',

                                  style:
                                  TextStyle(
                                    fontSize:
                                    13,

                                    color: tokens
                                        .textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    /**
     * ============================================================
     * LIBERAR CONTROLLERS
     * ============================================================
     */

    /**
     * ============================================================
     * RESULTADO
     * ============================================================
     *
     * CONFIRMADO:
     *
     * success = true
     * type = confirmed
     * data = {
     *   closing_amount,
     *   closing_details
     * }
     *
     * CANCELADO:
     *
     * success = false
     * type = cancelled
     *
     * DESCARTADO:
     *
     * success = false
     * type = dismissed
     *
     * ERROR DEL SERVICIO:
     *
     * El modal NO se cierra.
     *
     * El loading desaparece.
     *
     * El error se muestra dentro
     * del mismo modal.
     */
    return result ??
        const ShiftCloseModalResult(
          success: false,
          message:
          'El cierre de turno fue descartado.',
          type: dismissed,
          data: null,
        );
  }
}