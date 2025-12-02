import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../presentation/pages/splash_screen.dart';
import '../shared/models/app_config.dart';
import '../shared/themes/app_theme.dart';
import '../shared/localization/app_localizations.dart';
import '../domain/services/session_service.dart';

class InitMockApp extends StatelessWidget {
  const InitMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfig()),
        ChangeNotifierProvider(create: (_) => SessionService()),
      ],
      child: Consumer<AppConfig>(
        builder: (context, config, _) {
          return MaterialApp(
            title: 'Meetclic',
            theme: AppTheme.lightTheme,
            locale: config.locale,
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
              Locale('it'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale != null) {
                if (locale.languageCode == 'qu') {
                  return const Locale('qu');
                }
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
              }
              return supportedLocales.first;
            },
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );

  }
}
