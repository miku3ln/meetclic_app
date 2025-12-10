// lib/domain/gamification/usecases/get_active_c2b_tasks_usecase.dart
import '../entities/c2b_gamification_task.dart';
import '../repositories/gamification_task_repository.dart';

class GetActiveC2BTasksUseCase {
  final GamificationTaskRepository _repo;

  GetActiveC2BTasksUseCase(this._repo);

  Future<List<C2BGamificationTask>> call(DateTime now) {
    return _repo.getActiveC2BTasks(now);
  }
}
