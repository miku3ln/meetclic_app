import 'package:meetclic_app/domain/entities/module_model.dart';

class ModuleApiFake {
  Future<List<ModuleModel>> getModules() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      ModuleModel(title: 'Módulo 1'),
      ModuleModel(title: 'Módulo 2'),
      ModuleModel(title: 'Módulo 3'),
    ];
  }
}
