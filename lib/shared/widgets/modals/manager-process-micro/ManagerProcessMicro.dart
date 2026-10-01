import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/configuration/app_theme_tokens.dart';
import 'ManagerProcessMicroConfig.dart';
import 'ManagerProcessMicroResult.dart';

class ManagerProcessMicro<T> extends StatefulWidget {
  final ManagerProcessMicroConfig config;

  final Widget form;
  final Listenable? listenable;
  final Future<ManagerProcessMicroResult<T>> Function() onSubmit;
  final bool Function()? canSubmit;
  final VoidCallback? onCancel;

  const ManagerProcessMicro({
    super.key,
    required this.config,
    required this.form,
    required this.onSubmit,
    this.onCancel,
    this.listenable,
    this.canSubmit,
  });

  @override
  State<ManagerProcessMicro<T>> createState() =>
      _ManagerProcessMicroState<T>();
}

class _ManagerProcessMicroState<T>
    extends State<ManagerProcessMicro<T>> {
  bool _isLoading = false;

  // ================================================================
  // SUBMIT
  // ================================================================

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    final submitEnabled =
        widget.canSubmit?.call() ?? true;

    if (!submitEnabled) return;

    /*
     * Cerrar teclado antes de procesar.
     */
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
      await widget.onSubmit();

      if (!mounted) return;

      // ============================================================
      // ÉXITO
      // ============================================================

      if (result.success) {
        Navigator.of(context).pop(result);
        return;
      }

      // ============================================================
      // ERROR
      // El formulario permanece abierto.
      // ============================================================

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final mediaQuery = MediaQuery.of(context);

    final size = mediaQuery.size;

    final keyboardHeight = mediaQuery.viewInsets.bottom;

    /*
   * Saber si el teclado está visible.
   */
    final bool keyboardVisible = keyboardHeight > 0;

    final drawerWidth = size.width > 500
        ? widget.config.maxWidth
        : size.width * .92;

    return PopScope(
      /*
     * No permite regresar mientras está guardando.
     */
      canPop: !_isLoading,

      child: SafeArea(
        child: Align(
          /*
         * Cuando aparece el teclado alineamos el modal
         * arriba para aprovechar todo el espacio visible.
         */
          alignment: keyboardVisible
              ? Alignment.topRight
              : Alignment.centerRight,

          child: Material(
            color: Colors.transparent,

            // ======================================================
            // STACK
            // ======================================================

            child: Stack(
              children: [
                // ==================================================
                // CONTENIDO NORMAL
                // ==================================================

                AbsorbPointer(
                  absorbing: _isLoading,

                  child: AnimatedContainer(
                    /*
                   * Animación cuando aparece/desaparece
                   * el teclado.
                   */
                    duration: const Duration(
                      milliseconds: 220,
                    ),

                    curve: Curves.easeOutCubic,

                    width: drawerWidth,

                    /*
                   * IMPORTANTE:
                   *
                   * NO usamos:
                   *
                   * height: size.height
                   *
                   * porque eso obliga al modal a mantener
                   * la altura física completa de la pantalla.
                   *
                   * double.infinity hace que utilice la altura
                   * realmente disponible para el Dialog.
                   */
                    height: double.infinity,

                    decoration: BoxDecoration(
                      color: tokens.surface,

                      borderRadius:
                      const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        bottomLeft: Radius.circular(28),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: tokens.shadow,
                          blurRadius: 30,
                          offset: const Offset(-8, 0),
                        ),
                      ],
                    ),

                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        bottomLeft: Radius.circular(28),
                      ),

                      child: Column(
                        children: [
                          // =========================================
                          // HEADER
                          // =========================================

                          _buildHeader(context),

                          Divider(
                            height: 1,
                            color: tokens.border,
                          ),

                          // =========================================
                          // FORMULARIO
                          // =========================================

                          Expanded(
                            child: Container(
                              color: tokens.background,

                              child: SingleChildScrollView(
                                /*
                               * Si el usuario arrastra el formulario
                               * hacia abajo/arriba puede cerrar
                               * el teclado.
                               */
                                keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior
                                    .onDrag,

                                /*
                               * El teclado NO se agrega como padding.
                               *
                               * El Dialog ya recibe el espacio
                               * disponible cuando aparece el teclado.
                               */
                                padding:
                                const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  30,
                                ),

                                child: widget.form,
                              ),
                            ),
                          ),

                          // =========================================
                          // FOOTER
                          //
                          // Mientras el teclado está abierto
                          // ocultamos Cancelar / Guardar para
                          // darle más espacio al formulario.
                          // =========================================

                          if (!keyboardVisible) ...[
                            Divider(
                              height: 1,
                              color: tokens.border,
                            ),

                            _buildFooter(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // LOADING OVERLAY
                // ==================================================

                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      width: drawerWidth,

                      color: Colors.black.withValues(
                        alpha: 0.30,
                      ),

                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            CircularProgressIndicator(),

                            SizedBox(
                              height: 16,
                            ),

                            Text(
                              'Procesando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(
      BuildContext context,
      ) {
    final tokens =
    AppThemeTokens.of(context);

    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        24,
        20,
        20,
      ),

      child: Row(
        children: [
          Icon(
            widget.config.icon,
            color: tokens.primary,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  widget.config.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    tokens.textPrimary,
                  ),
                ),

                if (widget.config.description !=
                    null) ...[
                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    widget
                        .config.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                      tokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed:
            _isLoading
                ? null
                : () {
              FocusScope.of(context)
                  .unfocus();

              Navigator.of(context).pop(
                ManagerProcessMicroResult<T>(
                  success: true,
                  data: null,
                  message:
                  'Proceso cerrado',
                  type: 'close',
                ),
              );
            },

            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FOOTER
  // ================================================================

  Widget _buildFooter(
      BuildContext context,
      ) {
    if (widget.listenable == null) {
      return _buildFooterContent(
        context,
      );
    }

    return ListenableBuilder(
      listenable:
      widget.listenable!,

      builder: (
          context,
          _,
          ) {
        return _buildFooterContent(
          context,
        );
      },
    );
  }

  // ================================================================
  // FOOTER CONTENT
  // ================================================================

  Widget _buildFooterContent(
      BuildContext context,
      ) {
    final tokens =
    AppThemeTokens.of(context);

    final submitEnabled =
        widget.canSubmit?.call() ??
            true;

    return SafeArea(
      top: false,

      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24,
        ),

        child: Row(
          children: [
            // ======================================================
            // CANCELAR
            // ======================================================

            Expanded(
              child: TextButton(
                onPressed:
                _isLoading
                    ? null
                    : () {
                  FocusScope.of(context)
                      .unfocus();

                  widget.onCancel
                      ?.call();

                  Navigator.of(context)
                      .pop(
                    ManagerProcessMicroResult<T>(
                      success: true,
                      data: null,
                      message:
                      'Proceso cancelado',
                      type:
                      'cancel',
                    ),
                  );
                },

                child: Text(
                  widget
                      .config.cancelText,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            // ======================================================
            // GUARDAR
            // ======================================================

            Expanded(
              child: FilledButton(
                style:
                FilledButton.styleFrom(
                  backgroundColor:
                  tokens
                      .buttonPrimaryBackground,
                  foregroundColor:
                  tokens
                      .buttonPrimaryForeground,
                ),

                onPressed:
                !submitEnabled ||
                    _isLoading
                    ? null
                    : _handleSubmit,

                child: Text(
                  _isLoading
                      ? 'Procesando...'
                      : widget
                      .config.submitText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}