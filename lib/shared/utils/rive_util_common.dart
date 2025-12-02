import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveInspector {
  final RiveFile riveFile;

  RiveInspector._(this.riveFile);

  static Future<RiveInspector> fromAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final file = RiveFile.import(data);
    return RiveInspector._(file);
  }

  List<String> getAnimations() =>
      riveFile.mainArtboard.animations.map((a) => a.name).toList();

  List<String> getStateMachines() =>
      riveFile.mainArtboard.stateMachines.map((s) => s.name).toList();

  List<String> getTriggers(String stateMachineName) {
    final controller = _getController(stateMachineName);
    return controller?.inputs.whereType<SMITrigger>().map((t) => t.name).toList() ?? [];
  }

  List<String> getBooleans(String stateMachineName) {
    final controller = _getController(stateMachineName);
    return controller?.inputs.whereType<SMIBool>().map((b) => b.name).toList() ?? [];
  }

  List<String> getNumbers(String stateMachineName) {
    final controller = _getController(stateMachineName);
    return controller?.inputs.whereType<SMINumber>().map((n) => n.name).toList() ?? [];
  }

  StateMachineController? _getController(String name) {
    return StateMachineController.fromArtboard(riveFile.mainArtboard, name);
  }

  List<String> getBackgroundColors() => ['Black', 'Transparent', 'White', 'Pink'];

  List<String> getFitOptions() =>
      BoxFit.values.map((f) => f.name).toList();

  List<String> getAlignmentOptions() => [
    'TopLeft', 'TopCenter', 'TopRight',
    'CenterLeft', 'Center', 'CenterRight',
    'BottomLeft', 'BottomCenter', 'BottomRight',
  ];
}
