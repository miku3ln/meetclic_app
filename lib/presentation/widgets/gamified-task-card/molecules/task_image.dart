import 'package:flutter/material.dart';

class TaskImage extends StatelessWidget {
  final String imageUrl;
  const TaskImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetwork
          ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover)
          : Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
    );
  }
}
