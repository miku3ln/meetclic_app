import 'audio_item.dart';

class G2POutput {
  final List<String> tokens;   // ["p","a","k","ch","a"]
  final String phonemic;       // "pakča"
  final List<AudioItem> audioPlan; // vacío si no hay audios
  const G2POutput({
    required this.tokens,
    required this.phonemic,
    required this.audioPlan,
  });
}
