import 'package:provider/provider.dart';

import '../../shared/controllers/app_controller.dart';
import '../../shared/controllers/app_drawer_controller.dart';
import '../../shared/models/app_config.dart';
import '../../domain/services/session_service.dart';
import 'package:provider/single_child_widget.dart';
enum AppMode {
  guestHome,        // allowGuest + home
  requireLoginPos,  // requireLogin + pointSale
}
List<SingleChildWidget> buildAppProviders(AppMode mode) {
  return [
    ChangeNotifierProvider(create: (_) => AppConfig()),
    ChangeNotifierProvider(create: (_) => SessionService()),

    ChangeNotifierProxyProvider2<AppConfig, SessionService, AppController>(
      create: (context) {
        final controller = AppController(
          config: context.read<AppConfig>(),
          session: context.read<SessionService>(),
        );

        // ✅ Config centralizada (sin comentar/descomentar)
        switch (mode) {
          case AppMode.guestHome:
            controller.startPolicy = AppStartPolicy.allowGuest;
            controller.afterLoginDestination = AppAfterLoginDestination.home;
            break;

          case AppMode.requireLoginPos:
            controller.startPolicy = AppStartPolicy.requireLogin;
            controller.afterLoginDestination = AppAfterLoginDestination.pointSale;
            break;
        }

        return controller;
      },
      update: (context, appConfig, session, controller) =>
      controller ?? AppController(config: appConfig, session: session),
    ),
    // ✅ PUNTO 6: DrawerController (no afecta nada)
    ChangeNotifierProxyProvider<AppController, AppDrawerController>(
      create: (context) => AppDrawerController(app: context.read<AppController>()),
      update: (context, app, drawer) => drawer ?? AppDrawerController(app: app),
    ),
  ];
}