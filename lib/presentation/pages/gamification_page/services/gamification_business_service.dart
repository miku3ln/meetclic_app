import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';
import 'package:meetclic_app/domain/gamification/usecases/get_active_c2b_tasks_usecase.dart';
import 'package:meetclic_app/domain/gamification/usecases/get_c2b_tasks_by_business_usecase.dart';
import 'package:meetclic_app/domain/gamification/usecases/get_c2b_tasks_usecase.dart';

class GamificationBusinessService {
  final GetC2BTasksUseCase _getAllC2BTasks;
  final GetActiveC2BTasksUseCase _getActiveC2BTasks;
  final GetC2BTasksByBusinessUseCase _getC2BTasksByBusiness;

  const GamificationBusinessService({
    required GetC2BTasksUseCase getAllC2BTasks,
    required GetActiveC2BTasksUseCase getActiveC2BTasks,
    required GetC2BTasksByBusinessUseCase getC2BTasksByBusiness,
  }) : _getAllC2BTasks = getAllC2BTasks,
       _getActiveC2BTasks = getActiveC2BTasks,
       _getC2BTasksByBusiness = getC2BTasksByBusiness;

  Future<List<C2BGamificationTask>> fetchAllTasks() {
    return _getAllC2BTasks();
  }

  Future<List<C2BGamificationTask>> fetchActiveTasks(DateTime now) {
    return _getActiveC2BTasks(now);
  }

  Future<List<C2BGamificationTask>> fetchTasksByBusiness(int businessId) {
    return _getC2BTasksByBusiness(businessId: businessId, now: DateTime.now());
  }
}
