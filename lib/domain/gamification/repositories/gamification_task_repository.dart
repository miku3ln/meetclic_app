// lib/domain/gamification/repositories/gamification_task_repository.dart
import '../entities/c2b_gamification_task.dart';

abstract class GamificationTaskRepository {
  Future<List<C2BGamificationTask>> getAllC2BTasks();
  Future<List<C2BGamificationTask>> getActiveC2BTasks(DateTime now);

  /// Tareas C2B activas para un negocio específico
  Future<List<C2BGamificationTask>> getC2BTasksByBusiness({
    required int businessId,
    DateTime? now,
  });
}
