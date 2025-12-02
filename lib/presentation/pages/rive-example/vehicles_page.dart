import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:rive/rive.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/utils/rive_util_common.dart';

class VehiclesScreenPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const VehiclesScreenPage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<VehiclesScreenPage> createState() => _VehiclesScreenPageState();
}

class _VehiclesScreenPageState extends State<VehiclesScreenPage> {
  Artboard? _riveArtboard;
  RiveInspector? _inspector;
  final List<RiveAnimationController> _controllers = [];

  String? _selectedAnimation;
  String? _selectedStateMachine;
  bool _isPlaying = true;

  // Layout settings
  BoxFit _fit = BoxFit.cover;
  Alignment _alignment = Alignment.center;
  Color _backgroundColor = AppColors.moradoSuave;

  // State machine inputs
  Map<String, SMIInput?> _stateInputs = {};

  // Rive files
  final List<String> _riveFiles = [
    'vehicles.riv',
    'lip-sync.riv',
    'skills.riv',
    'acqua_text_out_of_band.riv',
    'coyote.riv',
    'liquid_download.riv',
    'little_machine.riv',
    'off_road_car.riv',
    'ping_pong_audio_demo.riv',
    'rewards.riv',
    'rocket.riv',
    'skins_demo.riv',
  ];

  String _selectedRiveFile = 'vehicles.riv';

  @override
  void initState() {
    super.initState();
    _loadRiveInspector(_selectedRiveFile);
  }

  Future<void> _loadRiveInspector(String fileName) async {
    _controllers.clear();
    _inspector = await RiveInspector.fromAsset('assets/$fileName');
    final artboard = _inspector!.riveFile.mainArtboard;

    final animations = _inspector!.getAnimations();
    if (animations.isNotEmpty) {
      _selectedAnimation = animations.first;
      final controller = SimpleAnimation(_selectedAnimation!);
      _controllers.add(controller);
      artboard.addController(controller);
    }

    setState(() {
      _riveArtboard = artboard;
      _selectedStateMachine = null;
      _stateInputs = {};
    });
  }

  void _switchAnimation(String name) {
    for (final controller in _controllers) {
      controller.isActive = false;
    }

    final newController = SimpleAnimation(name);
    _riveArtboard?.addController(newController);
    _controllers.add(newController);

    setState(() {
      _selectedAnimation = name;
      _isPlaying = true;
    });
  }

  void _togglePlayPause() {
    setState(() {
      for (final controller in _controllers) {
        controller.isActive = !controller.isActive;
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _initStateMachine(String name) {
    final controller = StateMachineController.fromArtboard(
      _riveArtboard!,
      name,
    );
    if (controller != null) {
      _riveArtboard!.addController(controller);
      final inputs = {for (final input in controller.inputs) input.name: input};
      setState(() {
        _selectedStateMachine = name;
        _stateInputs = inputs;
      });
    }
  }

  void _onTriggerPressed(String name) {
    final input = _stateInputs[name];
    if (input is SMITrigger) input.fire();
  }

  void _onBoolChanged(String name, bool value) {
    final input = _stateInputs[name];
    if (input is SMIBool) input.value = value;
  }

  void _onNumberChanged(String name, double value) {
    final input = _stateInputs[name];
    if (input is SMINumber) input.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animations = _inspector?.getAnimations() ?? [];
    final stateMachines = _inspector?.getStateMachines() ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Column(
        children: [
          // RENDER BOX (70%)
          Expanded(
            flex: 7,
            child: Container(
              key: const ValueKey("RenderBox"),
              width: double.infinity,
              color: _backgroundColor,
              child: Center(
                child: _riveArtboard == null
                    ? const CircularProgressIndicator()
                    : Rive(
                        useArtboardSize: true,
                        artboard: _riveArtboard!,
                        fit: _fit,
                        alignment: _alignment,
                      ),
              ),
            ),
          ),
          const Divider(height: 1),
          // CONTROLES (30%)
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildDropdown<String>(
                    context: context,
                    label: "Archivo Rive",
                    value: _selectedRiveFile,
                    items: _riveFiles,
                    display: (f) => f.replaceAll('.riv', ''),
                    onChanged: (value) {
                      setState(() {
                        _selectedRiveFile = value!;
                        _loadRiveInspector(value);
                      });
                    },
                  ),
                  ...animations.map(
                    (anim) => ElevatedButton(
                      onPressed: () => _switchAnimation(anim),
                      child: Text(
                        anim,
                        style: TextStyle(
                          fontSize: theme.textTheme.labelLarge?.fontSize,
                          height: 4,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  if (stateMachines.isNotEmpty && _selectedStateMachine != null)
                    _buildDropdown<String>(
                      context: context,
                      label: "State Machine",
                      value: _selectedStateMachine!,
                      items: stateMachines,
                      display: (f) => f,
                      onChanged: (value) => _initStateMachine(value!),
                    ),
                  if (_selectedStateMachine != null) ...[
                    for (final name in _inspector!.getTriggers(
                      _selectedStateMachine!,
                    ))
                      ElevatedButton(
                        onPressed: () => _onTriggerPressed(name),
                        child: Text(
                          'Trigger: $name',
                          style: TextStyle(
                            fontSize: theme.textTheme.labelLarge?.fontSize,
                            height: 4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    for (final name in _inspector!.getBooleans(
                      _selectedStateMachine!,
                    ))
                      SwitchListTile(
                        title: Text(
                          'Bool: $name',
                          style: TextStyle(
                            fontSize: theme.textTheme.labelLarge?.fontSize,
                            height: 4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        value: (_stateInputs[name] as SMIBool?)?.value ?? false,
                        onChanged: (v) => _onBoolChanged(name, v),
                      ),
                    for (final name in _inspector!.getNumbers(
                      _selectedStateMachine!,
                    ))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Number: $name',
                            style: TextStyle(
                              fontSize: theme.textTheme.labelLarge?.fontSize,
                              height: 4,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Slider(
                            value:
                                (_stateInputs[name] as SMINumber?)?.value ?? 0,
                            onChanged: (v) => _onNumberChanged(name, v),
                            min: 0,
                            max: 100,
                          ),
                        ],
                      ),
                  ],
                  ElevatedButton(
                    onPressed: _togglePlayPause,
                    child: Text(
                      _isPlaying ? 'Pausar' : 'Reanudar',
                      style: TextStyle(
                        fontSize: theme.textTheme.labelLarge?.fontSize,
                        height: 4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _buildDropdown<BoxFit>(
                    context: context,
                    label: "Fit",
                    value: _fit,
                    items: BoxFit.values,
                    display: (f) => f.name.toUpperCase(),
                    onChanged: (value) => setState(() => _fit = value!),
                  ),
                  _buildDropdown<Alignment>(
                    context: context,
                    label: "Alignment",
                    value: _alignment,
                    items: [
                      Alignment.center,
                      Alignment.topCenter,
                      Alignment.bottomCenter,
                      Alignment.centerLeft,
                      Alignment.centerRight,
                    ],
                    display: (a) {
                      if (a == Alignment.center) return "Centro";
                      if (a == Alignment.topCenter) return "Arriba";
                      if (a == Alignment.bottomCenter) return "Abajo";
                      if (a == Alignment.centerLeft) return "Izquierda";
                      if (a == Alignment.centerRight) return "Derecha";
                      return "Otro";
                    },
                    onChanged: (value) => setState(() => _alignment = value!),
                  ),
                  _buildDropdown<String>(
                    context: context,
                    label: "Fondo",
                    value: _backgroundColorString(),
                    items: ['Black', 'Transparent', 'White', 'Pink'],
                    display: (c) => c,
                    onChanged: (value) => setState(() {
                      _backgroundColor = _parseColor(value!);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: theme.colorScheme.surface,
          style: TextStyle(color: theme.colorScheme.onSurface),
          onChanged: onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(display(item)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _backgroundColorString() {
    if (_backgroundColor == Colors.black) return 'Black';
    if (_backgroundColor == Colors.transparent) return 'Transparent';
    if (_backgroundColor == Colors.white) return 'White';
    return 'Pink';
  }

  Color _parseColor(String value) {
    switch (value) {
      case 'Black':
        return Colors.black;
      case 'Transparent':
        return Colors.transparent;
      case 'White':
        return Colors.white;
      default:
        return AppColors.moradoSuave;
    }
  }
}
