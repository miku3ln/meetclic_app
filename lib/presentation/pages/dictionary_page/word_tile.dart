import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/themes/app_colors.dart';

import 'models/word_item.dart';

class WordTile extends StatelessWidget {
  final WordItem item;
  final VoidCallback onPlay;

  const WordTile({super.key, required this.item, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Entrada de diccionario: ${item.title}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar imagen solo si viene
            if ((item.image!).isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.image!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.azulClic.withOpacity(.08),
                    alignment: Alignment.center,
                    child: const Icon(Icons.menu_book_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Contenido ocupa todo el espacio restante
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------
                  // Fila 1: Traducción (icono + texto)
                  // ---------------------------
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onPlay,
                        icon: const Icon(Icons.volume_up_rounded),
                        color: AppColors.azulClic,
                        tooltip: 'Reproducir pronunciación',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ---------------------------
                  // Fila 2: Palabra (col1) + Fonema (col2)
                  // ---------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.grisOscuro,
                            letterSpacing: .3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (item.phoneme case final p?
                          when p.trim().isNotEmpty &&
                              p.trim().toLowerCase() != 'none')
                        Text(
                          '[${item.phoneme}]',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _TranslationBadge(
                          text: (item.translationEs ?? item.subtitle).isNotEmpty
                              ? (item.translationEs ?? item.subtitle)
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ---------------------------
                  // Fila 3: "Clases gramaticales:" + valores
                  // ---------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clases Gramaticales:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF7A1B1B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: item.classes.isEmpty
                            ? Text('—', style: theme.textTheme.titleMedium)
                            : Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: item.classes
                                    .map((c) => _ClassPill(text: c))
                                    .toList(),
                              ),
                      ),
                    ],
                  ),

                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.25),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassPill extends StatelessWidget {
  final String text;
  const _ClassPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.moradoSuave.withOpacity(.10),
        border: Border.all(color: AppColors.moradoSuave.withOpacity(.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.moradoSuave,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _TranslationBadge extends StatelessWidget {
  final String text;
  const _TranslationBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    // Colores base (ajusta si tienes modo oscuro)
    final Color accent = AppColors.azulClic; // barrita e icono
    final Color bg = AppColors.azulClic.withOpacity(.10); // fondo suave
    final Color fg = Colors.black87; // texto

    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // barrita izquierda
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.translate_rounded, size: 16, color: accent),
          const SizedBox(width: 6),
          // texto con elipsis
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
