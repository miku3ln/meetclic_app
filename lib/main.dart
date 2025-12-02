import 'package:flutter/material.dart';

import 'app/init_mock_app.dart';
import 'domain/services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  await SessionService().loadSession();
  runApp(const InitMockApp());
}
