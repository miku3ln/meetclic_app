import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initial;
  final String? suffix;
  final ValueChanged<double>? onChanged; // ✅ Añadido

  const CustomSlider({
    super.key,
    required this.min,
    required this.max,
    required this.initial,
    this.suffix,
    this.onChanged, // ✅ Añadido
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle titleStyle =TextStyle(
      color: theme.primaryColor,
      fontSize:18,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          min: widget.min,
          max: widget.max,
          value: _value,
          onChanged: (val) {
            setState(() => _value = val);
            if (widget.onChanged != null) {
              widget.onChanged!(val); // ✅ Dispara el callback hacia fuera
            }
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        Text(
          '${_value.toStringAsFixed(0)}${widget.suffix ?? ''}',
          style: titleStyle,
        ),
      ],
    );
  }
}
