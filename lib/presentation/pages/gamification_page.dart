import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';
import 'package:meetclic_app/domain/gamification/repositories/gamification_task_repository.dart';
import 'package:meetclic_app/domain/gamification/usecases/get_active_c2b_tasks_usecase.dart';
import 'package:meetclic_app/domain/gamification/usecases/get_c2b_tasks_by_business_usecase.dart';
import 'package:meetclic_app/domain/gamification/usecases/get_c2b_tasks_usecase.dart';
import 'package:meetclic_app/infrastructure/gamification/datasources/business_c2b_config_local_source.dart';
import 'package:meetclic_app/infrastructure/gamification/datasources/c2b_gamification_task_local_source.dart';
import 'package:meetclic_app/infrastructure/gamification/repositories/gamification_task_repository_impl.dart';
import 'package:meetclic_app/presentation/pages/services/presentation_services_all.dart';

import '../../infrastructure/assets/app_images.dart';
import '../widgets/template/custom_app_bar.dart';
import 'gamification_page/services/gamification_business_service.dart';
import 'gamification_page/state/gamification_business_state.dart';

class GamificationPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const GamificationPage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  late final GamificationBusinessService _service;
  GamificationBusinessState _state = GamificationBusinessState.initial();

  @override
  void initState() {
    super.initState();

    // ===== Wiring rápido de hexagonal (local) =====
    final c2bLocalSource = C2BGamificationTaskLocalSource();
    final businessConfigSource = BusinessC2BConfigLocalSource();
    final GamificationTaskRepository repo = GamificationTaskRepositoryImpl(
      c2bLocalSource,
      businessConfigSource,
    );

    final getAllUseCase = GetC2BTasksUseCase(repo);
    final getActiveUseCase = GetActiveC2BTasksUseCase(repo);
    final getByBusinessUseCase = GetC2BTasksByBusinessUseCase(repo);

    _service = GamificationBusinessService(
      getAllC2BTasks: getAllUseCase,
      getActiveC2BTasks: getActiveUseCase,
      getC2BTasksByBusiness: getByBusinessUseCase,
    );

    // Carga inicial (ej: todas las tareas activas para el negocio 1)
    _loadTasksByBusiness(1);
  }

  Future<void> _loadAllTasks() async {
    setState(() {
      _state = _state.copyWith(status: GamificationBusinessStatus.loading);
    });

    try {
      final tasks = await _service.fetchAllTasks();
      setState(() {
        _state = _state.copyWith(
          status: GamificationBusinessStatus.loaded,
          tasks: tasks,
        );
      });
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          status: GamificationBusinessStatus.error,
          errorMessage: e.toString(),
        );
      });
    }
  }

  Future<void> _loadActiveTasks() async {
    setState(() {
      _state = _state.copyWith(status: GamificationBusinessStatus.loading);
    });

    try {
      final tasks = await _service.fetchActiveTasks(DateTime.now());
      setState(() {
        _state = _state.copyWith(
          status: GamificationBusinessStatus.loaded,
          tasks: tasks,
        );
      });
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          status: GamificationBusinessStatus.error,
          errorMessage: e.toString(),
        );
      });
    }
  }

  Future<void> _loadTasksByBusiness(int businessId) async {
    setState(() {
      _state = _state.copyWith(status: GamificationBusinessStatus.loading);
    });

    try {
      final tasks = await _service.fetchTasksByBusiness(businessId);
      setState(() {
        _state = _state.copyWith(
          status: GamificationBusinessStatus.loaded,
          tasks: tasks,
        );
      });
    } catch (e) {
      setState(() {
        _state = _state.copyWith(
          status: GamificationBusinessStatus.error,
          errorMessage: e.toString(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerConfig = buildRightImageWithThreeButtons(
      imageWidget: Image.asset(
        AppImages.splashBackground, // o tu logo / avatar
        width: 50,
        height: 50,
      ),
      onFirstPressed: () {
        print("onFirstPressed");
      },
      onSecondPressed: () {
        print("onSecondPressed");
      },
      onThirdPressed: () {
        print("onThirdPressed");
      },
    );
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: widget.title,
        items: widget.itemsStatus,
        config: headerConfig,
      ),
      body: Column(
        children: [
          // ======= HEADER DE ACCIONES / FILTROS =======
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loadAllTasks,
                  child: const Text('Ver todas las tareas C2B'),
                ),
                ElevatedButton(
                  onPressed: _loadActiveTasks,
                  child: const Text('Ver tareas activas'),
                ),
                ElevatedButton(
                  onPressed: () => _loadTasksByBusiness(1),
                  child: const Text('Ver tareas por negocio (ID 1)'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ======= LISTADO / ESTADO =======
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_state.status) {
      case GamificationBusinessStatus.initial:
        return const Center(
          child: Text('Selecciona una opción para ver tareas.'),
        );
      case GamificationBusinessStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case GamificationBusinessStatus.error:
        return Center(
          child: Text('Error: ${_state.errorMessage ?? 'Ocurrió un problema'}'),
        );
      case GamificationBusinessStatus.loaded:
        if (_state.tasks.isEmpty) {
          return const Center(child: Text('No hay tareas disponibles.'));
        }
        return ListView.builder(
          itemCount: _state.tasks.length,
          itemBuilder: (context, index) {
            final task = _state.tasks[index];
            return _buildTaskTile(task);
          },
        );
    }
  }

  Widget _buildTaskTile(C2BGamificationTask task) {
    return ListTile(
      title: Text(task.name),
      subtitle: Text(
        '${task.description}\n'
        'Grupo: ${task.groupName} • Puntos: ${task.points} • Tipo: ${task.typePoints}',
      ),
      isThreeLine: true,
      trailing: Text(task.code),
    );
  }
}
