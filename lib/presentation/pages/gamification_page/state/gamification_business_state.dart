import 'package:meetclic_app/domain/gamification/entities/c2b_gamification_task.dart';

enum GamificationBusinessStatus { initial, loading, loaded, error }

class GamificationBusinessState {
  final GamificationBusinessStatus status;
  final List<C2BGamificationTask> tasks;
  final String? errorMessage;

  const GamificationBusinessState({
    required this.status,
    required this.tasks,
    this.errorMessage,
  });

  factory GamificationBusinessState.initial() =>
      const GamificationBusinessState(
        status: GamificationBusinessStatus.initial,
        tasks: [],
      );

  GamificationBusinessState copyWith({
    GamificationBusinessStatus? status,
    List<C2BGamificationTask>? tasks,
    String? errorMessage,
  }) {
    return GamificationBusinessState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
