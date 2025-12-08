import 'package:meetclic_app/shared/utils/deep_link_type.dart';

import '../models/home_tab_id.dart';

class HomeShellState {
  /// Tab actual del home (nunca null).
  final HomeTabId currentTab;

  /// Deep link pendiente (puede ser null si no hay nada por procesar).
  final DeepLinkInfo? pendingDeepLink;

  const HomeShellState({
    required this.currentTab,
    required this.pendingDeepLink,
  });

  /// Estado inicial → comienza en el tab HOME y sin deep link pendiente.
  factory HomeShellState.initial() =>
      const HomeShellState(currentTab: HomeTabId.home, pendingDeepLink: null);

  /// copyWith para actualizar el estado de forma inmutable.
  HomeShellState copyWith({
    HomeTabId? currentTab,
    DeepLinkInfo? pendingDeepLink,
  }) {
    return HomeShellState(
      currentTab: currentTab ?? this.currentTab,
      pendingDeepLink: pendingDeepLink ?? this.pendingDeepLink,
    );
  }
}
