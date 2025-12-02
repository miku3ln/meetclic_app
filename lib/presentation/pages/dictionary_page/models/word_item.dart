// pages/dictionary_page/models/word_item.dart
class WordItem {
  /// Imagen ilustrativa (URL o asset)
  final String? image;

  /// Palabra principal (Kichwa)
  final String title;

  /// Traducción corta (ES) – se mantiene para compatibilidad
  final String subtitle;

  /// Descripción/uso en contexto
  final String description;

  /// Fonema / transcripción (p. ej. [ač­ačaw])
  final String? phoneme;

  /// Traducciones adicionales opcionales
  final String? translationEs; // “expresión de frío”

  /// Clases gramaticales: ["Adj.", "Sust.", "Interj."] etc.
  final List<String> classes;

  /// Audio para reproducción (opcional)
  final String? audioUrl;

  const WordItem({
    this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    this.phoneme,
    this.translationEs,
    this.classes = const [],
    this.audioUrl,
  });

  /// Fábrica útil para migrar desde tu estructura anterior
  factory WordItem.basic({
    String? image,
    required String title,
    required String subtitle,
    required String description,
  }) => WordItem(
    image: image,
    title: title,
    subtitle: subtitle,
    description: description,
  );
}
