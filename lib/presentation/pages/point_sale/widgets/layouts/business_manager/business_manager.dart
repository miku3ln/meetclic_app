import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../helpers/pos_responsive.dart';
import '../../../shared/styles.dart';
import '../../../state/business_manager_management_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '/../../../shared/providers_session.dart';

class BusinessManagerManagementService {
  final bool returnEmpty;
  final bool throwError;

  BusinessManagerManagementService({
    this.returnEmpty = false,
    this.throwError = false,
  });

  Future<BusinessManagerSummaryModel?> getBusinessSummary() async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (throwError) {
      throw Exception('No se pudo obtener el resumen del turno');
    }

    if (returnEmpty) {
      return null;
    }

    return const BusinessManagerSummaryModel();
  }
}

class BusinessManagerManagementLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const BusinessManagerManagementLayout({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessManagerManagementController(),
      child: const _BusinessManagerView(),
    );
  }
}

class _BusinessManagerView extends StatefulWidget {
  const _BusinessManagerView();

  @override
  State<_BusinessManagerView> createState() => _BusinessManagerViewState();
}

class _BusinessManagerViewState extends State<_BusinessManagerView> {
  late final BusinessManagerManagementService _service;

  bool _isLoading = false;
  bool _initialized = false;

  BusinessManagerSummaryModel? _summary;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _service = BusinessManagerManagementService(
      returnEmpty: false,
      throwError: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_initialized) return;

    _initialized = true;

    if (_hasBusinessManagerData()) {
      _loadExistingBusinessManager();
      return;
    }

    await _loadData();
  }

  bool _hasBusinessManagerData() {
    final session = context.read<SessionService>();
    final userData = session.currentSession;

    final businessManager = userData?.allData['businessManager'];

    if (businessManager == null) {
      return false;
    }

    if (businessManager is! Map) {
      return false;
    }

    return businessManager.isNotEmpty;
  }

  void _loadExistingBusinessManager() {
    final session = context.read<SessionService>();
    final userData = session.currentSession;

    final businessManager = userData?.allData['businessManager'];

    if (businessManager is Map && businessManager.isNotEmpty) {
      final model = BusinessManagerSummaryModel.fromJson(
        Map<String, dynamic>.from(businessManager),
      );

      if (!mounted) return;

      setState(() {
        _summary = model;
        _errorMessage = null;
      });
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getBusinessSummary();

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

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final titlePrimary = _summary?.business?.title ?? '';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),

      appBar: PosSettingsAppBar(
        titlePrimary: titlePrimary,
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

      body: BusinessManagerRegister(
        summary: _summary,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onReload: _loadData,
      ),
    );
  }
}

class BusinessManagerRegister extends StatelessWidget {
  final BusinessManagerSummaryModel? summary;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onReload;

  const BusinessManagerRegister({
    super.key,
    required this.summary,
    required this.isLoading,
    required this.errorMessage,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<BusinessManagerManagementController>();

    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: _buildBody(context, controller),
    );
  }

  // ============================================================
  // INFORMACIÓN DE LA EMPRESA
  // ============================================================

  Widget _buildBusinessInformation() {
    return RefreshIndicator(
      onRefresh: onReload,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1030,
                ),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary?.business?.title ?? '',
                        ),

                        const SizedBox(height: 10),

                        Text(
                          summary?.business?.email ?? '',
                        ),

                        const SizedBox(height: 10),

                        Text(
                          summary?.business?.phoneValue ?? '',
                        ),
                      ],
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

  Widget _buildScheduleStatus({
    required bool isOpenNow,
    required bool isActive,
    required BuildContext context
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'NO DISPONIBLE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isOpenNow
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isOpenNow
                  ? Colors.green
                  : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpenNow
                ? 'ABIERTO AHORA'
                : 'FUERA DE HORARIO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOpenNow
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // HORARIOS
  // ============================================================
  Widget _buildScheduleItem(
      BusinessScheduleModel schedule,
      BuildContext context,
      ) {
    final now = DateTime.now();

    // Tu weight_day:
    // 0 = Lunes
    // 1 = Martes
    // ...
    // 6 = Domingo
    final currentDay = now.weekday - 1;

    final isToday = schedule.weightDay == currentDay;

    final isActive =
        schedule.status?.toUpperCase() == 'ACTIVE';

    final isOpenNow = isToday && isActive;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 6,
          ),

          childrenPadding: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            16,
          ),

          // ======================================================
          // ICONO
          // ======================================================
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isToday
                  ? colorScheme.primary.withOpacity(0.12)
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToday
                  ? Icons.today_outlined
                  : Icons.calendar_today_outlined,
              color: isToday
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),

          // ======================================================
          // DÍA + ESTADO
          // ======================================================
          title: Row(
            children: [
              Expanded(
                child: Text(
                  schedule.text ?? schedule.name ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),

              _buildScheduleStatus(
                isOpenNow: isOpenNow,
                isActive: isActive,
                context: context,
              ),
            ],
          ),

          // ======================================================
          // INTERVALOS
          // ======================================================
          children: [
            _buildScheduleIntervals(
              schedule,
              context,
            ),
          ],
        ),
      ),
    );
  }
  bool _hasIntervals(BusinessScheduleModel schedule) {
    return schedule.type == 1 &&
        schedule.configTypeSchedule?.type == true &&
        (schedule.configTypeSchedule?.data.isNotEmpty ?? false);
  }
  bool _is24Hours(BusinessScheduleModel schedule) {
    return schedule.type == 0 &&
        schedule.configTypeSchedule?.type == false;
  }
  bool _isOpenNow(
      BusinessScheduleModel schedule,
      ) {
    final now = DateTime.now();

    final currentDay = now.weekday - 1;

    final isToday = schedule.weightDay == currentDay;

    final isActive =
        schedule.status?.toUpperCase() == 'ACTIVE';

    if (!isToday || !isActive) {
      return false;
    }

    // ============================================================
    // 24 HORAS
    // ============================================================
    if (_is24Hours(schedule)) {
      return true;
    }

    // ============================================================
    // HORARIO POR INTERVALOS
    // ============================================================
    if (_hasIntervals(schedule)) {
      final currentMinutes =
          now.hour * 60 + now.minute;

      for (final interval
      in schedule.configTypeSchedule!.data) {

        final start =
        _timeToMinutes(
          interval.startTime?.modelBreakdown,
        );

        final end =
        _timeToMinutes(
          interval.endTime?.modelBreakdown,
        );

        if (start == null || end == null) {
          continue;
        }

        if (currentMinutes >= start &&
            currentMinutes <= end) {
          return true;
        }
      }
    }

    return false;
  }
  int? _timeToMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    return hour * 60 + minute;
  }
  Widget _buildScheduleIntervals(
      BusinessScheduleModel schedule,
      BuildContext context,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    // ============================================================
    // 24 HORAS
    // ============================================================
    if (_is24Hours(schedule)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(
              Icons.all_inclusive,
              size: 19,
              color: colorScheme.primary,
            ),

            const SizedBox(width: 10),

            Text(
              '24 horas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // INTERVALOS
    // ============================================================
    final intervals =
        schedule.configTypeSchedule?.data ?? [];

    if (intervals.isEmpty) {
      return Text(
        'Sin intervalos configurados',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intervalos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        ...intervals.map(
              (interval) {
            final start =
            _formatTime(
              interval.startTime?.modelBreakdown,
            );

            final end =
            _formatTime(
              interval.endTime?.modelBreakdown,
            );

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.55),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    '$start - $end',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  Widget _buildScheduleIntervals2(
      BusinessScheduleModel schedule,
      BuildContext context,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    final intervals =
        schedule.configTypeSchedule?.data ?? [];

    // ============================================================
    // SIN INTERVALOS
    // ============================================================
    if (intervals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Sin intervalos configurados',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // ============================================================
    // INTERVALOS
    // ============================================================
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intervalos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        ...intervals.asMap().entries.map(
              (entry) {
            final index = entry.key;
            final interval = entry.value;

            final start =
                interval.startTime?.modelBreakdown;

            final end =
                interval.endTime?.modelBreakdown;

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: index == intervals.length - 1
                    ? 0
                    : 8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.55),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    '${_formatTime(start)} - ${_formatTime(end)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  String _formatTime(String? value) {
    if (value == null || value.isEmpty) {
      return '--:--';
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    return '${parts[0]}:${parts[1]}';
  }
  Widget _buildSchedules(BuildContext context) {
    final schedules = summary?.schedules ?? [];
    return RefreshIndicator(
      onRefresh: onReload,
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1030,
                ),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Horarios',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        ...schedules.map(
                              (schedule) {
                            return _buildScheduleItem(schedule,context);
                          },
                        ),
                      ],
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

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      BuildContext context,
      BusinessManagerManagementController controller,
      ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (summary == null) {
      return RefreshIndicator(
        onRefresh: onReload,
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
                      icon: errorMessage == null
                          ? Icons.business_outlined
                          : Icons.error_outline,
                      title: errorMessage == null
                          ? 'Todavía no hay información disponible'
                          : 'No se pudo cargar la información',
                      descriptionText: errorMessage == null
                          ? 'Aquí podrás consultar la información y configuración de la empresa cuando esté disponible.'
                          : 'Ocurrió un problema al obtener la información de la empresa.',
                      linkText: 'Actualizar',
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: onReload,
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

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.business_outlined,
                  ),
                  text: 'Información de la empresa',
                ),
                Tab(
                  icon: Icon(
                    Icons.schedule_outlined,
                  ),
                  text: 'Horarios',
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              children: [
                _buildBusinessInformation(),
                _buildSchedules(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
