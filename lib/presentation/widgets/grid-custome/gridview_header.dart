import 'package:flutter/material.dart';

class GridViewHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Text('Identificación', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text('Nombres', style: TextStyle(fontWeight: FontWeight.bold))),
      //  Expanded(child: Text('Adulto/Niño', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text('Edad', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}
