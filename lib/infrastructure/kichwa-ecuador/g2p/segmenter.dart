import '../../../domain/entities/kichwa-ecuador/grapheme_token.dart';
import '../../../domain/value_objects/kichwa-ecuador/word_input.dart';

class Segmenter {
  static const _digraphs = <String>{"sh","ch","ll","rr","ts","zh"};

  List<GraphemeToken> segment(WordInput input) {
    final s = input.raw;
    final out = <GraphemeToken>[];
    int i = 0;
    while (i < s.length) {
      if (i + 1 < s.length) {
        final two = s.substring(i, i + 2);
        if (_digraphs.contains(two)) {
          out.add(GraphemeToken(two));
          i += 2;
          continue;
        }
      }
      out.add(GraphemeToken(s[i]));
      i++;
    }
    return out;
  }
}
