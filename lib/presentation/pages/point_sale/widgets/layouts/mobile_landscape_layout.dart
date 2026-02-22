import 'package:flutter/material.dart';
import '../organisms/pos_header_bar.dart';

class PosMobileLandscapeLayout extends StatefulWidget {
  const PosMobileLandscapeLayout({super.key});

  @override
  State<PosMobileLandscapeLayout> createState() => _PosMobileLandscapeLayoutState();
}

class _PosMobileLandscapeLayoutState extends State<PosMobileLandscapeLayout> {
  final filters = const ['Todos los artículos', 'Favoritos', 'Promociones'];
  String selected = 'Todos los artículos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  PosHeaderBar(
        dropdownItems: filters,
        selectedItem: selected,
        onMenuTap: () {},
        onUserTap: () {},
        onMoreTap: () {},
        onDropdownChanged: (v) {
          if (v == null) return;
          setState(() => selected = v);
        },
        onSearchChanged: (text) {
          // aquí filtras tu lista en vivo
          debugPrint('search: $text');
        },
        onSearchSubmitted: (text) {
          // enter del teclado
          debugPrint('submit: $text');
        },
      ),
      body: const Center(child: Text('POS Mobile Landscape')),
    );
  }
}
