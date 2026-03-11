import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../shared/controllers/app_controller.dart';
import '../shared/models/app_config.dart';
import '../shared/themes/app_theme.dart';
import '../shared/localization/app_localizations.dart';

import 'app_gate.dart';
import 'router/app_router.dart';
import 'locale/locale_resolution.dart';

class MeetclicMaterialApp extends StatelessWidget {
  const MeetclicMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final app = context.watch<AppController>();

    return MaterialApp(
      title: 'Meetclic',
      theme: AppTheme.lightTheme,
      locale: config.locale,
      supportedLocales: const [Locale('es'), Locale('en'), Locale('it')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: resolveLocale,
      debugShowCheckedModeBanner: false,
      navigatorKey: app.navigatorKey,
     // routes: AppRouter.routes(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AppGate(),
    );
  }
}