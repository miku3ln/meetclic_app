import 'package:flutter/cupertino.dart';

class MoreSectionHeaderMolecule extends StatelessWidget {
  final String title;

  const MoreSectionHeaderMolecule({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
