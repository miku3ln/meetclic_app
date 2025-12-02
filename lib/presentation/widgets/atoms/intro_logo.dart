import 'package:flutter/material.dart';

class IntroLogo extends StatelessWidget {
  final String assetPath;
  final double height;

  const IntroLogo({super.key, required this.assetPath, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, height: height);
  }
}
