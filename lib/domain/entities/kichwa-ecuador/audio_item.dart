class AudioItem {
  final String grapheme;  // ej. "ch"
  final String ipa;       // ej. "/ʧ/"
  final String assetPath; // ej. "assets/audio/phonemes/ch.wav"
  const AudioItem({
    required this.grapheme,
    required this.ipa,
    required this.assetPath,
  });
}
