import 'package:flutter/material.dart';

class AddRowButton extends StatelessWidget {
  final VoidCallback onPressed;

  AddRowButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Add Row'),
    );
  }
}
