// lib/infrastructure/gamification/repositories/gamification_task_repository_impl.dart

import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';
import 'package:meetclic_app/domain/gamification/repositories/gamification_task_repository.dart';

import '../datasources/business_c2b_config_local_source.dart';
import '../datasources/c2b_gamification_task_local_source.dart';

class GamificationTaskRepositoryImpl implements GamificationTaskRepository {
  final C2BGamificationTaskLocalSource _c2bLocalSource;
  final BusinessC2BConfigLocalSource _businessConfigSource;

  GamificationTaskRepositoryImpl(
    this._c2bLocalSource,
    this._businessConfigSource,
  );

  @override
  Future<List<C2BGamificationTask>> getAllC2BTasks() async {
    return _c2bLocalSource.getAll();
  }

  @override
  Future<List<C2BGamificationTask>> getActiveC2BTasks(DateTime now) async {
    final all = _c2bLocalSource.getAll();
    return _filterActive(all, now);
  }

  @override
  Future<List<C2BGamificationTask>> getC2BTasksByBusiness({
    required int businessId,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();

    // 1) Catálogo completo
    final allTasks = _c2bLocalSource.getAll();

    // 2) Configuración por negocio (qué códigos aplica ese negocio)
    final activeCodes = _businessConfigSource.getActiveTaskCodesForBusiness(
      businessId,
    );

    // 3) Filtrar catálogo por códigos activos
    final tasksForBusiness = allTasks
        .where((task) => activeCodes.contains(task.code))
        .toList();

    // 4) Filtrar por fecha / expiración
    final activeForBusiness = _filterActive(tasksForBusiness, current);

    return activeForBusiness;
  }

  /// Filtra tareas activas según hasExpiration, startDate y endDate.
  List<C2BGamificationTask> _filterActive(
    List<C2BGamificationTask> tasks,
    DateTime now,
  ) {
    return tasks.where((t) {
      if (!t.hasExpiration) return true;

      final start = t.startDate;
      final end = t.endDate;
      if (start == null || end == null) return false;

      final isAfterStart = !now.isBefore(start);
      final isBeforeEnd = !now.isAfter(end);

      return isAfterStart && isBeforeEnd;
    }).toList();
  }
}
