import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/module_model.dart';

import 'home_main_menu.dart';

class HomeScreen extends StatefulWidget {
  final List<ModuleModel> modules;

  const HomeScreen({super.key, required this.modules});

  @override
  State<HomeScreen> createState() => HomeMainMenu();
}
