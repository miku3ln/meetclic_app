// g2p_symbols.dart
// Centraliza símbolos y claves de asset para audio.

class G2PSymbols {
  static const Map<String, ({String ipa, String symbol, String key})>
  graphemeMap = {
    "a": (ipa: "a", symbol: "a", key: "a"),
    "i": (ipa: "i", symbol: "i", key: "i"),
    "u": (ipa: "u", symbol: "u", key: "u"),
    "p": (ipa: "p", symbol: "p", key: "p"),
    "t": (ipa: "t", symbol: "t", key: "t"),
    "k": (ipa: "k", symbol: "k", key: "k"),
    "q": (ipa: "q", symbol: "q", key: "q"),
    "ch": (ipa: "ʧ", symbol: "č", key: "ch"),
    "h": (ipa: "h", symbol: "h", key: "h"),
    "s": (ipa: "s", symbol: "s", key: "s"),
    "sh": (ipa: "ʃ", symbol: "š", key: "sh"),
    "m": (ipa: "m", symbol: "m", key: "m"),
    "n": (ipa: "n", symbol: "n", key: "n"),
    "ñ": (ipa: "ɲ", symbol: "ɲ", key: "ny"),
    "l": (ipa: "l", symbol: "l", key: "l"),
    "ll": (ipa: "ʎ", symbol: "ʎ", key: "ll"),
    "r": (ipa: "ɾ", symbol: "ɾ", key: "r"),
    "rr": (ipa: "r", symbol: "r", key: "rr"),
    "w": (ipa: "w", symbol: "w", key: "w"),
    "y": (ipa: "j", symbol: "y", key: "y"),
    "ts": (ipa: "ts", symbol: "ts", key: "ts"),
    "z": (ipa: "z", symbol: "z", key: "z"),
    "zh": (ipa: "ʒ", symbol: "ž", key: "zh"),
    "e": (ipa: "e", symbol: "e", key: "e"),
    "o": (ipa: "o", symbol: "o", key: "o"),
  };

  static String assetKey(String sym) {
    const keys = <String, String>{
      'a': 'a',
      'i': 'i',
      'u': 'u',
      'e': 'e',
      'o': 'o',
      'p': 'p',
      't': 't',
      'k': 'k',
      'q': 'q',
      'g': 'g',
      'm': 'm',
      'n': 'n',
      'l': 'l',
      's': 's',
      'z': 'z',
      'w': 'w',
      'y': 'y',
      'ɾ': 'r',
      'r': 'rr',
      'č': 'ch',
      'š': 'sh',
      'ž': 'zh',
      'ɲ': 'ny',
      'ʎ': 'll',
      'ʝ': 'll',
      'x': 'h',
      'ŋ': 'n',
      'ts': 'ts',
    };
    return keys[sym] ?? sym;
  }
}
