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
import 'manager/admin/shift-summary-content.dart';

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
  bool allowManager = false;
  String messageManager = "";

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await UtilServicesCash.getPointOfSaleCashCloseSummary();
      allowManager = response.success;

      if (!mounted) return;
      final controller = context.read<PosShiftManagementController>();
      controller.setCashManagerData(
        allowManager: response.success,
        messageManager: response.message,
        data: response.data,
      );
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
      } else {
        messageManager = response.message;
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

    if (!wasClosed) {
      return;
    }

    /**
     * PosMainController principal que ya está
     * registrado arriba en el árbol de Provider.
     */
    final main = context.read<PosMainController>();

    /**
     * Limpia PosShiftState.
     *
     * Internamente:
     *
     * currentSession = null;
     * notifyListeners();
     */
    await main.shift.closeShift();

    if (!mounted) return;

    /**
     * Recarga la información visual de esta pantalla.
     */
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosShiftManagementController>();
    if (controller.reloadCashSummary) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }

        controller.clearCashSummaryReload();

        await _loadData();
      });
    }
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
    return Stack(
      children: [
        /*
     * ============================================================
     * CONTENIDO CON SCROLL
     * ============================================================
     */
        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                /*
             * Dejamos espacio abajo.
             * Las acciones NO forman parte de este ListView.
             */
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),

                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1030),
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: ShiftSummaryContent(
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
          ),
        ),

        /*
     * ============================================================
     * ACCIONES FIJAS / FLOTANTES
     *
     * NO hacen scroll.
     * ============================================================
     */
        if (allowManager)
          Positioned(
            bottom: 150,
            left: 20,
            child: ShiftTopActions(
              isClosingShift: controller.isClosingShift,

              onTreasuryTap: () => controller.onTreasuryTap(context),

              onMovementManagerTap: () =>
                  controller.onManagementMovement(context),
              onCloseShiftTap: _reloadAfterCloseShift,
            ),
          ),
      ],
    );
  }
}
