import 'package:flutter/material.dart';
class InputTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isTouched;
  final bool isValid;
  final String? errorMessage;
  final TextInputType keyboardType;
  final FocusNode? focusNode; // <-- Añadido
  InputTextField({
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.isTouched = false,
    this.isValid = true,
    this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.focusNode, // <-- Añadido
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey;
    if (isTouched) {
      borderColor = isValid ? Colors.green : Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          focusNode: focusNode, // <-- Añadido
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            suffixIcon: isTouched
                ? (isValid
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.error, color: Colors.red))
                : null,
          ),
          keyboardType: keyboardType,
        ),
        if (isTouched && !isValid && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
