import 'package:flutter/material.dart';
class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const SocialIcon(this.icon, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFE0E0E0),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}

class StartButtonWidget extends StatelessWidget {
  const StartButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {


        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.circle, size: 90, color: Colors.black26),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: theme.colorScheme.onPrimary,
                size: 40,
              ),
            ),
            Positioned(
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('START', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}