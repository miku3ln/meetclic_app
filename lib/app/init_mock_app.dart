import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/app_providers.dart';
import 'meetclic_material_app.dart';
class InitMockApp extends StatelessWidget {
  const InitMockApp({super.key});
  @override
  Widget build(BuildContext context) {
    const mode = AppMode.requireLoginPos;
    return MultiProvider(
      providers: buildAppProviders(mode),
      child: const MeetclicMaterialApp(),
    );
  }
}