import 'package:flutter/material.dart';
import 'atom_styles.dart';

class InputTextAtom extends StatefulWidget {
  final String? label;
  final TextInputType keyboardType;
  final bool obscureText;
  final double? height;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const InputTextAtom({
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.height,
    this.labelStyle,
    this.textStyle,
    this.decoration,
    this.onChanged,
    this.validator,
    this.controller,
    super.key,
  });

  @override
  State<InputTextAtom> createState() => _InputTextAtomState();
}

class _InputTextAtomState extends State<InputTextAtom> {
  bool _showText = false; // Control interno para mostrar/ocultar

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: widget.height,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText ? !_showText : false,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        validator: widget.validator,
        style: (widget.textStyle ?? AtomStyles.inputTextStyle).copyWith(
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: (widget.decoration ??
            InputDecoration(
              labelText: widget.label,
              labelStyle: (widget.labelStyle ?? AtomStyles.labelTextStyle)
                  .copyWith(
                color: theme.textTheme.titleSmall?.color,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
                borderRadius: AtomStyles.inputBorder.borderRadius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.secondary,
                  width: 1.5,
                ),
                borderRadius: AtomStyles.inputBorder.borderRadius,
              ),
            )).copyWith(
          // ✅ Solo si es un campo de tipo password muestra el icono
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _showText ? Icons.visibility : Icons.visibility_off,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _showText = !_showText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}
