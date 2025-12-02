// presentation/widgets/module_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/module_model.dart';

class ModuleSelectorWidget extends StatelessWidget {
  final List<ModuleModel> modules;
  final ModuleModel? selectedModule;
  final ValueChanged<ModuleModel?> onModuleChanged;

  const ModuleSelectorWidget({
    super.key,
    required this.modules,
    required this.selectedModule,
    required this.onModuleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<ModuleModel>(
        value: selectedModule,
        hint: const Text('Selecciona un módulo'),
        isExpanded: true,
        items: modules.map((module) {
          return DropdownMenuItem<ModuleModel>(
            value: module,
            child: Text(module.title),
          );
        }).toList(),
        onChanged: onModuleChanged,
      ),
    );
  }
}
