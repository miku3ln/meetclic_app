import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/module_model.dart';

import 'home_main_menu/widgets/organisms/home_main_menu_organism.dart';

class HomeScreenAllMenu extends StatelessWidget {
  final List<ModuleModel> modules;

  const HomeScreenAllMenu({super.key, required this.modules});
  @override
  Widget build(BuildContext context) {
    return const HomeMainMenuOrganism();
  }
}
