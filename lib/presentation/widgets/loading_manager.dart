
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PosLoadingView extends StatelessWidget {
  const PosLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando información...'),
        ],
      ),
    );
  }
}