// language_drop_down.dart
import 'package:flutter/material.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';

class LanguageDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final double height;
  final double flagSize;

  /// Opcional: restringe los idiomas visibles (ej. ['ES','KI'])
  final List<String>? options;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 52,
    this.flagSize = 22,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    // Mapa de código -> ruta del asset
    final Map<String, String> all = {
      'ES': AppImages.flagLanguageEs,
      'KI': AppImages.flagLanguageKi,
    };

    final entries = (options == null)
        ? all.entries.toList()
        : all.entries.where((e) => options!.contains(e.key)).toList();

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          items: entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: _FlagLabelRow(
                    path: e.value,
                    code: e.key,
                    flagSize: flagSize,
                  ),
                ),
              )
              .toList(),
          // Asegura que el "closed button" también muestre bandera + código
          selectedItemBuilder: (context) => entries
              .map(
                (e) => _FlagLabelRow(
                  path: e.value,
                  code: e.key,
                  flagSize: flagSize,
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _FlagLabelRow extends StatelessWidget {
  final String path;
  final String code;
  final double flagSize;

  const _FlagLabelRow({
    required this.path,
    required this.code,
    required this.flagSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(path, width: flagSize, height: flagSize, fit: BoxFit.cover),
        const SizedBox(width: 8),
        Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
