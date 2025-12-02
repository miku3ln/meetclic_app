import 'package:flutter/material.dart';

class CenterReticle extends StatelessWidget {
  const CenterReticle({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 8, spreadRadius: 1),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
