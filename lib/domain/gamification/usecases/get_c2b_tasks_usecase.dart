// domain/gamification/usecases/get_c2b_tasks_usecase.dart
import '../entities/c2b_gamification_task.dart';
import '../repositories/gamification_task_repository.dart';

class GetC2BTasksUseCase {
  final GamificationTaskRepository _repository;

  GetC2BTasksUseCase(this._repository);

  Future<List<C2BGamificationTask>> call() {
    return _repository.getAllC2BTasks();
  }
}
