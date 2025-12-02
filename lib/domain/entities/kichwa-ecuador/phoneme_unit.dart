class PhonemeUnit {
  final String grapheme; // grafema origen (ej. "ch")
  final String ipa;      // AFI, ej. "/ʧ/"
  final String symbol;   // símbolo legible, ej. "č"
  final String key;      // clave para archivo, ej. "ch"
  const PhonemeUnit({
    required this.grapheme,
    required this.ipa,
    required this.symbol,
    required this.key,
  });
}
