// ============================================================================
// BODY
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../infrastructure/config/server_config.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../state/pos_loyalty_controller.dart';
import '../../../utils/pos_socket_service.dart';
import 'body_point_sales.dart';

class PosLoyaltyBody extends StatefulWidget {
  final PosLoyaltySection section;

  const PosLoyaltyBody({required this.section});

  @override
  State<PosLoyaltyBody> createState() => PosLoyaltyBodyState();
}

// ============================================================================
// BODY STATE
// ============================================================================

class PosLoyaltyBodyState extends State<PosLoyaltyBody> {
  // ==========================================================================
  // PORTRAIT
  // ==========================================================================

  static const double _portraitMinSize = 0.22;
  static const double _portraitNormalSize = 0.40;
  static const double _portraitMediumSize = 0.65;
  static const double _portraitMaxSize = 0.96;

  // ==========================================================================
  // LANDSCAPE
  // ==========================================================================

  static const double _landscapeNormalSize = 0.62;
  static const double _landscapeMediumSize = 0.80;
  static const double _landscapeMaxSize = 0.96;

  static const double _landscapeMinHeight = 220.0;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool _isAnimating = false;

  Orientation? _lastOrientation;

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _sheetController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // CALCULATE MIN SIZE
  // ==========================================================================

  double _calculateMinSize({
    required bool isLandscape,
    required double availableHeight,
  }) {
    if (!isLandscape) {
      return _portraitMinSize;
    }

    if (availableHeight <= 0) {
      return 0.65;
    }

    final calculated = _landscapeMinHeight / availableHeight;

    return calculated.clamp(0.55, 0.82).toDouble();
  }

  // ==========================================================================
  // CALCULATE NORMAL SIZE
  // ==========================================================================

  double _calculateNormalSize({
    required bool isLandscape,
    required double minSize,
  }) {
    if (!isLandscape) {
      return _portraitNormalSize;
    }

    var normalSize = _landscapeNormalSize;

    if (normalSize <= minSize) {
      normalSize = minSize + 0.08;
    }

    return normalSize.clamp(minSize, 0.84).toDouble();
  }

  // ==========================================================================
  // CALCULATE MEDIUM SIZE
  // ==========================================================================

  double _calculateMediumSize({
    required bool isLandscape,
    required double normalSize,
  }) {
    if (!isLandscape) {
      return _portraitMediumSize;
    }

    var mediumSize = _landscapeMediumSize;

    if (mediumSize <= normalSize) {
      mediumSize = normalSize + 0.08;
    }

    return mediumSize.clamp(normalSize, 0.90).toDouble();
  }

  // ==========================================================================
  // MOVE SHEET TO
  // ==========================================================================

  Future<void> _moveSheetTo(double size) async {
    if (!_sheetController.isAttached) {
      return;
    }

    if (_isAnimating) {
      return;
    }

    _isAnimating = true;

    try {
      await _sheetController.animateTo(
        size,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isAnimating = false;
    }
  }

  // ==========================================================================
  // MOVE SHEET UP
  //
  // MIN -> NORMAL -> MEDIUM -> MAX
  // ==========================================================================

  Future<void> _moveSheetUp({
    required double minSize,
    required double normalSize,
    required double mediumSize,
    required double maxSize,
  }) async {
    if (!_sheetController.isAttached) {
      return;
    }

    if (_isAnimating) {
      return;
    }

    final currentSize = _sheetController.size;

    // MIN -> NORMAL

    if (currentSize < ((minSize + normalSize) / 2)) {
      await _moveSheetTo(normalSize);

      return;
    }

    // NORMAL -> MEDIUM

    if (currentSize < ((normalSize + mediumSize) / 2)) {
      await _moveSheetTo(mediumSize);

      return;
    }

    // MEDIUM -> MAX

    if (currentSize < ((mediumSize + maxSize) / 2)) {
      await _moveSheetTo(maxSize);

      return;
    }
  }

  // ==========================================================================
  // ORIENTATION CHANGE
  // ==========================================================================

  void _handleOrientationChange({
    required Orientation orientation,
    required double normalSize,
  }) {
    if (_lastOrientation == null) {
      _lastOrientation = orientation;

      return;
    }

    if (_lastOrientation == orientation) {
      return;
    }

    _lastOrientation = orientation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_sheetController.isAttached) {
        return;
      }

      _moveSheetTo(normalSize);
    });
  }
// ===========================================================================
// INIT
// ===========================================================================

  @override
  void initState() {
    super.initState();

    _initializeSocket();
  }

// ===========================================================================
// SOCKET
// ===========================================================================

  Future<void> _initializeSocket() async {
    final socketService =
        PosSocketService.instance;

    if (socketService.isConnected) {
      debugPrint(
        'POS Socket already connected',
      );

      return;
    }

    final connected =
    await socketService.connect(
      url: ServerConfig.socketUrl,
    );

    debugPrint(
      'POS Socket initialized: $connected',
    );

    debugPrint(
      'POS Socket URL: ${ServerConfig.socketUrl}',
    );
  }
  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);

    final bool isLandscape = orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        // ====================================================================
        // AVAILABLE HEIGHT
        //
        // IMPORTANTE:
        // No usamos constraints.maxHeight porque puede cambiar cuando
        // aparece/desaparece el teclado.
        //
        // Queremos que los tamaños del ticket se calculen usando la
        // altura de la pantalla.
        // ====================================================================

        final double availableHeight = MediaQuery.sizeOf(context).height;

        // ====================================================================
        // SIZES
        // ====================================================================

        final double minSize = _calculateMinSize(
          isLandscape: isLandscape,
          availableHeight: availableHeight,
        );

        final double normalSize = _calculateNormalSize(
          isLandscape: isLandscape,
          minSize: minSize,
        );

        final double mediumSize = _calculateMediumSize(
          isLandscape: isLandscape,
          normalSize: normalSize,
        );

        final double maxSize = isLandscape
            ? _landscapeMaxSize
            : _portraitMaxSize;

        // ====================================================================
        // ORIENTATION
        // ====================================================================

        _handleOrientationChange(
          orientation: orientation,
          normalSize: normalSize,
        );

        // ====================================================================
        // CONTENT
        // ====================================================================

        return Stack(
          fit: StackFit.expand,
          children: [
            // ================================================================
            // PRODUCT CATALOG
            // ================================================================
            const Positioned.fill(child: PosProductCatalogContent()),

            // ================================================================
            // DRAGGABLE TICKET
            // ================================================================
            DraggableScrollableSheet(
              controller: _sheetController,

              initialChildSize: normalSize,

              minChildSize: minSize,

              maxChildSize: maxSize,

              snap: true,

              snapSizes: [minSize, normalSize, mediumSize, maxSize],

              builder: (context, scrollController) {
                return _PosTicketSheet(
                  scrollController: scrollController,

                  isLandscape: isLandscape,

                  onActivate: () {
                    _moveSheetUp(
                      minSize: minSize,
                      normalSize: normalSize,
                      mediumSize: mediumSize,
                      maxSize: maxSize,
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// TICKET SHEET
// ============================================================================

class _PosTicketSheet extends StatelessWidget {
  final ScrollController scrollController;

  final VoidCallback onActivate;

  final bool isLandscape;

  const _PosTicketSheet({
    required this.scrollController,
    required this.onActivate,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    final List<_PosTicketItemData> items = [
      const _PosTicketItemData(name: 'Ensalada', quantity: 1, unitPrice: 1.00),

      const _PosTicketItemData(
        name: 'Pollo entero',
        quantity: 1,
        unitPrice: 7.00,
      ),

      const _PosTicketItemData(name: 'Aliño', quantity: 1, unitPrice: 0.50),
    ];

    final subtotal = items.fold<double>(0, (value, item) => value + item.total);

    const taxes = 0.00;

    const discount = 0.00;

    final total = subtotal + taxes - discount;

    final totalProducts = items.fold<int>(
      0,
      (value, item) => value + item.quantity,
    );

    return Material(
      color: Colors.transparent,

      child: Container(
        width: double.infinity,

        height: double.infinity,

        decoration: BoxDecoration(
          color: colors.background,

          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),

          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),

        clipBehavior: Clip.antiAlias,

        child: Column(
          children: [
            // ================================================================
            // HEADER
            // ================================================================
            GestureDetector(
              behavior: HitTestBehavior.opaque,

              onTap: onActivate,

              onLongPress: onActivate,

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  _PosTicketDragHandle(compact: isLandscape),

                  _PosTicketHeader(
                    totalProducts: totalProducts,

                    compact: isLandscape,
                  ),

                  Divider(height: 1, thickness: 1, color: colors.divider),
                ],
              ),
            ),

            // ================================================================
            // PRODUCTS + TOTALS
            // ================================================================
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,

                onTap: onActivate,

                onLongPress: onActivate,

                child: ListView(
                  controller: scrollController,

                  padding: EdgeInsets.fromLTRB(
                    isLandscape ? 12 : 16,
                    isLandscape ? 4 : 8,
                    isLandscape ? 12 : 16,
                    isLandscape ? 8 : 16,
                  ),

                  children: [
                    ...items.map(
                      (item) => _PosTicketProductRow(
                        item: item,
                        compact: isLandscape,
                      ),
                    ),

                    SizedBox(height: isLandscape ? 4 : 8),

                    Divider(height: 1, color: colors.divider),

                    SizedBox(height: isLandscape ? 6 : 12),

                    _PosTicketValueRow(
                      label: 'Subtotal',
                      value: subtotal,
                      compact: isLandscape,
                    ),

                    SizedBox(height: isLandscape ? 4 : 8),

                    _PosTicketValueRow(
                      label: 'Impuestos',
                      value: taxes,
                      compact: isLandscape,
                    ),

                    SizedBox(height: isLandscape ? 4 : 8),

                    _PosTicketValueRow(
                      label: 'Descuento',
                      value: discount,
                      compact: isLandscape,
                    ),

                    SizedBox(height: isLandscape ? 6 : 12),

                    Divider(height: 1, color: colors.divider),

                    SizedBox(height: isLandscape ? 6 : 12),

                    _PosTicketTotalRow(total: total, compact: isLandscape),

                    SizedBox(height: isLandscape ? 8 : 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DRAG HANDLE
// ============================================================================

class _PosTicketDragHandle extends StatelessWidget {
  final bool compact;

  const _PosTicketDragHandle({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 16 : 26,

      width: double.infinity,

      child: Center(
        child: Container(
          width: compact ? 40 : 46,

          height: 4,

          decoration: BoxDecoration(
            color: Colors.grey.shade400,

            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TICKET HEADER
// ============================================================================

class _PosTicketHeader extends StatelessWidget {
  final int totalProducts;

  final bool compact;

  const _PosTicketHeader({required this.totalProducts, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 16,
        0,
        compact ? 8 : 12,
        compact ? 4 : 10,
      ),

      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, size: compact ? 18 : 22),

          SizedBox(width: compact ? 6 : 9),

          Expanded(
            child: Text(
              'Ticket',

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: compact ? 14 : 18,

                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,

              vertical: compact ? 3 : 5,
            ),

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              '$totalProducts productos',

              style: TextStyle(
                fontSize: compact ? 10 : 12,

                fontWeight: FontWeight.w600,

                color: colors.primary,
              ),
            ),
          ),

          SizedBox(width: compact ? 2 : 4),

          IconButton(
            tooltip: 'Limpiar ticket',

            visualDensity: VisualDensity.compact,

            constraints: BoxConstraints(
              minWidth: compact ? 32 : 40,

              minHeight: compact ? 32 : 40,
            ),

            padding: EdgeInsets.zero,

            onPressed: () {
              // TODO:
              // Limpiar ticket.
            },

            icon: Icon(
              Icons.delete_outline_rounded,

              size: compact ? 18 : 21,

              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TEMP MODEL
// ============================================================================

class _PosTicketItemData {
  final String name;

  final int quantity;

  final double unitPrice;

  const _PosTicketItemData({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;
}

// ============================================================================
// PRODUCT ROW
// ============================================================================

class _PosTicketProductRow extends StatelessWidget {
  final _PosTicketItemData item;

  final bool compact;

  const _PosTicketProductRow({required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 4 : 7),

      child: Row(
        children: [
          Container(
            width: compact ? 30 : 38,

            height: compact ? 30 : 38,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(compact ? 8 : 10),
            ),

            child: Text(
              '${item.quantity}x',

              style: TextStyle(
                fontSize: compact ? 11 : 13,

                fontWeight: FontWeight.w700,

                color: colors.primary,
              ),
            ),
          ),

          SizedBox(width: compact ? 8 : 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: compact ? 12 : 14,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: compact ? 1 : 2),

                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} c/u',

                  style: TextStyle(
                    fontSize: compact ? 10 : 12,

                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: compact ? 6 : 8),

          Text(
            '\$${item.total.toStringAsFixed(2)}',

            style: TextStyle(
              fontSize: compact ? 12 : 14,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VALUE ROW
// ============================================================================

class _PosTicketValueRow extends StatelessWidget {
  final String label;

  final double value;

  final bool compact;

  const _PosTicketValueRow({
    required this.label,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,

            style: TextStyle(
              fontSize: compact ? 12 : 14,

              color: Colors.grey.shade700,
            ),
          ),
        ),

        Text(
          '\$${value.toStringAsFixed(2)}',

          style: TextStyle(
            fontSize: compact ? 12 : 14,

            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TOTAL
// ============================================================================

class _PosTicketTotalRow extends StatelessWidget {
  final double total;

  final bool compact;

  const _PosTicketTotalRow({required this.total, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        Expanded(
          child: Text(
            'Total',

            style: TextStyle(
              fontSize: compact ? 15 : 19,

              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Text(
          '\$${total.toStringAsFixed(2)}',

          style: TextStyle(
            fontSize: compact ? 20 : 26,

            height: 1,

            fontWeight: FontWeight.w800,

            color: colors.primary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FIXED ACTIONS
// ============================================================================

class PosTicketActions extends StatelessWidget {
  final double total;

  final bool compact;

  const PosTicketActions({required this.total, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    return Material(
      color: colors.background,

      elevation: 12,

      child: SafeArea(
        top: false,

        left: false,

        right: false,

        // IMPORTANTE:
        // protege los botones de la barra del sistema.
        bottom: true,

        child: Container(
          width: double.infinity,

          padding: EdgeInsets.fromLTRB(
            compact ? 8 : 12,
            compact ? 5 : 10,
            compact ? 8 : 12,
            compact ? 5 : 10,
          ),

          decoration: BoxDecoration(
            color: colors.background,

            border: Border(top: BorderSide(color: colors.divider)),
          ),

          child: Row(
            children: [
              // ==============================================================
              // PAYMENT METHOD
              // ==============================================================
              Expanded(
                flex: 4,

                child: SizedBox(
                  height: compact ? 40 : 52,

                  child: OutlinedButton(
                    onPressed: () {
                      _showPaymentMethods(context);
                    },

                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,

                      side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.35),
                      ),

                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 10,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(compact ? 10 : 14),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(Icons.payments_outlined, size: compact ? 17 : 21),

                        SizedBox(width: compact ? 4 : 6),

                        Flexible(
                          child: Text(
                            'Efectivo',

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: compact ? 12 : 14,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(width: 2),

                        Icon(
                          Icons.keyboard_arrow_down_rounded,

                          size: compact ? 17 : 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: compact ? 6 : 10),

              // ==============================================================
              // CHARGE
              // ==============================================================
              Expanded(
                flex: 6,

                child: SizedBox(
                  height: compact ? 40 : 52,

                  child: FilledButton(
                    onPressed: total <= 0
                        ? null
                        : () {
                            // TODO:
                            // Cobrar.
                          },

                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF31B64B),

                      foregroundColor: Colors.white,

                      disabledBackgroundColor: const Color(0xFFB9DDBF),

                      disabledForegroundColor: Colors.white,

                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(compact ? 10 : 14),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.point_of_sale_rounded,

                          size: compact ? 17 : 21,
                        ),

                        SizedBox(width: compact ? 5 : 7),
                        Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: compact ? 40 : 52,
                            child: FilledButton(
                              onPressed: total <= 0
                                  ? null
                                  : () {
                                PosSocketService.instance.send(
                                  event: 'invoice.created',
                                  data: {
                                    'user_id': 41,
                                    'date': DateTime.now().toIso8601String(),
                                    'invoice_id': 1001,
                                    'total': total,
                                  },
                                );
                              },

                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF31B64B),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFB9DDBF),
                                disabledForegroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 8 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    compact ? 10 : 14,
                                  ),
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.point_of_sale_rounded,
                                    size: compact ? 17 : 21,
                                  ),

                                  SizedBox(
                                    width: compact ? 5 : 7,
                                  ),

                                  Flexible(
                                    child: Text(
                                      'Cobrar \$${total.toStringAsFixed(2)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: compact ? 12 : 15,
                                        fontWeight: FontWeight.w800,
                                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PAYMENT METHODS
  // ==========================================================================

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,

      showDragHandle: true,

      useSafeArea: true,

      builder: (modalContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Forma de pago',

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.payments_outlined),

              title: const Text('Efectivo'),

              trailing: const Icon(Icons.check_circle),

              onTap: () {
                Navigator.pop(modalContext);
              },
            ),

            ListTile(
              leading: const Icon(Icons.credit_card_rounded),

              title: const Text('Tarjeta'),

              onTap: () {
                Navigator.pop(modalContext);
              },
            ),

            ListTile(
              leading: const Icon(Icons.account_balance_rounded),

              title: const Text('Transferencia'),

              onTap: () {
                Navigator.pop(modalContext);
              },
            ),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
