// domain/gamification/usecases/get_c2b_tasks_by_business_usecase.dart
import '../entities/c2b_gamification_task.dart';
import '../repositories/gamification_task_repository.dart';

class GetC2BTasksByBusinessUseCase {
  final GamificationTaskRepository _repository;

  GetC2BTasksByBusinessUseCase(this._repository);

  Future<List<C2BGamificationTask>> call({
    required int businessId,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    return _repository.getC2BTasksByBusiness(
      businessId: businessId,
      now: current,
    );
  }
}
