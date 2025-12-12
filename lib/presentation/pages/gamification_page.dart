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
import '../../shared/language/language_modal_mixin.dart';
import '../../shared/models/app_config.dart';
import '../../shared/providers_session.dart';
import '../../shared/themes/app_colors.dart';
import '../widgets/template/custom_app_bar.dart';
import 'gamification_page/models/gamification_page_all_model.dart';
import 'gamification_page/services/gamification_business_service.dart';
import 'gamification_page/state/gamification_business_state.dart';
import 'gamification_page/utils/gamification_task_card_resolver.dart';

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

class _GamificationPageState extends State<GamificationPage>
    with LanguageModalMixin {
  late final GamificationBusinessService _service;
  GamificationBusinessState _state = GamificationBusinessState.initial();
  late final AppConfig config = Provider.of<AppConfig>(context, listen: false);

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

  void onLanguage() {
    showLanguageModal(config: config, menuTabUpItems: []);
  }

  getDataResult(List<C2BGamificationTask> tasks) {
    final Map<GamificationCardLayout, List<C2BGamificationTask>> map = {
      GamificationCardLayout.imageLeft: [],
      GamificationCardLayout.full: [],
      GamificationCardLayout.compact: [],
      GamificationCardLayout.others: [],
    };
    tasks.forEach((task) {
      final variant = GamificationCardTypeResolver.resolve(task);

      switch (variant.layout) {
        case GamificationCardLayout.imageLeft:
          map[GamificationCardLayout.imageLeft]!.add(task);
          break;

        case GamificationCardLayout.full:
          map[GamificationCardLayout.full]!.add(task);
          break;

        case GamificationCardLayout.compact:
          map[GamificationCardLayout.compact]!.add(task);
          break;

        case GamificationCardLayout.others:
          map[GamificationCardLayout.others]!.add(task);
          break;
      }
    });

    return map;
  }

  searchAppBarNormal(appConfig) {
    return SearchableHeaderAppBar(
      layoutBuilder: (ctx) {
        final String urlFlag = appConfig.getUrlFlag();
        final actions = <HeaderActionItem>[
          HeaderActionItem(
            icon: const Icon(Icons.search, size: 22),
            onTap: ctx.startSearch,
          ),
          HeaderActionItem(
            icon: const Icon(Icons.tune, size: 22),
            onTap: () => print('filters'),
          ),
          HeaderActionItem(
            icon: Image.asset(urlFlag, width: 22, height: 22),
            onTap: onLanguage,
          ),
          HeaderActionItem(
            icon: Image.asset(
              AppImages.rewardTypeTrophy,
              width: 22,
              height: 22,
            ),
            onTap: () => print('gamificación'),
          ),
          HeaderActionItem(
            icon: Image.asset(AppImages.basketEcommerce, width: 24, height: 24),
            onTap: () => print('ventas'),
          ),
        ];

        return buildSearchHeaderLayout(
          ctx: ctx,
          config: appConfig,
          rightActions: actions,
          onChangedSearch: (value) => {print('onChangedSearch $value')},
          onSubmittedSearch: (value) => {print('onSubmittedSearch $value')},
          searchStyle: const HeaderSearchVisualConfig(
            hintText: 'Buscar tareas',
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            textStyle: TextStyle(fontSize: 16, color: AppColors.azulClic),
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
            cursorColor: AppColors.azulClic,
            backIcon: Icons.arrow_back,
            backIconSize: 20,
            backIconColor: AppColors.azulClic,
            backIconPadding: EdgeInsets.only(right: 4),
          ),
        );
      },
    );
  }

  searchAppButtons(appConfig) {
    return SearchableHeaderAppBar(
      layoutBuilder: (ctx) {
        final String urlFlag = appConfig.getUrlFlag();
        // BOTONES NORMALES (modo normal)
        final normalActions = <HeaderActionItem>[
          HeaderActionItem(
            icon: const Icon(Icons.search, size: 22),
            onTap: ctx.startSearch,
          ),
          HeaderActionItem(
            icon: Image.asset(urlFlag, width: 22, height: 22),
            onTap: onLanguage,
          ),
          HeaderActionItem(
            icon: Image.asset(
              AppImages.rewardTypeTrophy,
              width: 22,
              height: 22,
            ),
            onTap: () => print('gamificación'),
          ),
          HeaderActionItem(
            icon: Image.asset(AppImages.basketEcommerce, width: 24, height: 28),
            onTap: () => print('ventas'),
          ),
        ];

        // BOTONES ESPECIALES SOLO PARA SEARCH (los del 30%)
        final searchActions = <HeaderActionItem>[
          HeaderActionItem(
            icon: const Icon(Icons.tune, size: 22),
            onTap: () => print('filters en search'),
          ),
          // puedes agregar más si quieres
        ];

        const searchStyle = HeaderSearchVisualConfig(
          hintText: 'Buscar tareas',
          fieldHeight: 44,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          textStyle: TextStyle(fontSize: 16, color: AppColors.azulClic),
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          cursorColor: AppColors.azulClic,
          backIcon: Icons.arrow_back,
          backIconSize: 20,
          backIconColor: AppColors.azulClic,
          backIconPadding: EdgeInsets.only(right: 4),
        );

        if (ctx.isSearching) {
          // 👉 AQUÍ entra el layout 20/50/30 para búsqueda
          return buildSearchHeaderLayout20_50_302(
            ctx: ctx,
            searchActions: searchActions,
            searchStyle: searchStyle,
            onChangedSearch: (v) => print('onChangedSearch $v'),
            onSubmittedSearch: (v) => print('onSubmittedSearch $v'),
          );
        }

        // 👉 modo normal: título + botones (20/50/30 clásico)
        return buildNormalHeaderLayout20_50_30(
          ctx: ctx,
          config: appConfig,
          rightActions: normalActions,
        );
      },
    );
  }

  searchApp2080(appConfig) {
    return SearchableHeaderAppBar(
      layoutBuilder: (ctx) {
        final String urlFlag = appConfig.getUrlFlag();
        // BOTONES GENERALES (modo normal)
        final actions = <HeaderActionItem>[
          HeaderActionItem(
            icon: const Icon(Icons.search, size: 22),
            onTap: ctx.startSearch,
          ),
          HeaderActionItem(
            icon: const Icon(Icons.tune, size: 22),
            onTap: () => print('filters'),
          ),
          HeaderActionItem(
            icon: Image.asset(urlFlag, width: 22, height: 22),
            onTap: onLanguage,
          ),
          HeaderActionItem(
            icon: Image.asset(
              AppImages.rewardTypeTrophy,
              width: 22,
              height: 22,
            ),
            onTap: () => print('gamificación'),
          ),
          HeaderActionItem(
            icon: Image.asset(AppImages.basketEcommerce, width: 22, height: 22),
            onTap: () => print('ventas'),
          ),
        ];

        const searchStyle = HeaderSearchVisualConfig(
          hintText: 'Buscar tareas',
          fieldHeight: 40, // 👈 aquí decides el alto del pill
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          textStyle: TextStyle(fontSize: 16, color: AppColors.azulClic),
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          cursorColor: AppColors.azulClic,
          backIcon: Icons.arrow_back,
          backIconSize: 20,
          backIconColor: AppColors.azulClic,
          backIconPadding: EdgeInsets.only(right: 4),
        );

        if (ctx.isSearching) {
          // 🔎 MODO BÚSQUEDA → 20 / 80 (back + input)
          return buildSearchHeaderLayout20_80(
            ctx: ctx,
            searchStyle: searchStyle,
            onChangedSearch: (value) {
              print('onChangedSearch $value');
            },
            onSubmittedSearch: (value) {
              print('onSubmittedSearch $value');
            },
          );
        }

        // 🟦 MODO NORMAL → título + botones (20 / 50 / 30)
        return buildNormalHeaderLayout20_50_30(
          ctx: ctx,
          config: appConfig,
          rightActions: actions,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appConfig = Provider.of<AppConfig>(context);
    final data = _state.tasks;
    final group = getDataResult(data);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: searchAppButtons(appConfig),
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
