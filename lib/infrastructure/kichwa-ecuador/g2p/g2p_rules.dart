// g2p_rules.dart
// Regla base + catálogo KAMU + reglas contextuales conservadoras.

typedef RuleMatch = bool Function(String seg, int i, List<String> toks);
typedef RuleApply = List<String> Function(String seg);

class Rule {
  final String id;
  final String explain;
  final RuleMatch match;
  final RuleApply apply;
  const Rule({
    required this.id,
    required this.explain,
    required this.match,
    required this.apply,
  });
}

class G2PRules {
  // Catálogo KAMU (restringido en ll/ʎ → no expanden a l/š/č/ž por defecto)
  static const Map<String, List<String>> KAMU_VARIANTS = {
    "p": ["p", "ph", "f", "b"],
    "t": ["t", "th", "d", "r"],
    "k": ["k", "kh", "x", "g", ""],
    "q": ["q", "k", "kh", "x"],
    "č": ["č", "ts", "š", "s", "ž"],
    "h": ["h", "x", ""],
    "s": ["s", "š"],
    "š": ["š", "s"],
    "m": ["m", "n", "w"],
    "n": ["n", "m", "k"],
    "ñ": ["ñ", "n", "y", "ly"],
    "l": ["l"],
    "ly": ["ly"],
    "r": ["r", "R", "l", "ly"],
    "w": ["w", "b", ""],
    "y": ["y"],
    "i": ["i", "e"],
    "u": ["u", "o"],
    "a": ["a", "i", "u"],
    "ʎ": ["ʎ"],
  };

  static const Set<String> ALLOWED_EXPAND = {
    "p",
    "t",
    "k",
    "q",
    "h",
    "č",
    "s",
    "š",
    "ly",
    "ʎ",
    "ñ",
    "w",
    "r",
  };

  static bool isVowel(String s) => "aiueo".contains(s);

  // ==== Reglas contextuales (conservadoras) ====
  static final Rule K_BEFORE_CH_OR_T_TO_X = Rule(
    id: "K>X_BEFORE_Č_OR_T",
    explain: "k→x ante č o t",
    match: (seg, i, toks) {
      if (seg != "k") return false;
      final next = (i + 1 < toks.length) ? toks[i + 1] : "";
      return (next == "č" || next == "t");
    },
    apply: (_) => ["x", "k"],
  );

  static final Rule K_INTERVOCALIC_OR_AFTER_NASAL_TO_G = Rule(
    id: "K>G_VKV_OR_AFTER_NASAL",
    explain: "k→g en V_k_V o tras nasal",
    match: (seg, i, toks) {
      if (seg != "k") return false;
      final prev = i > 0 ? toks[i - 1] : "";
      final next = (i + 1 < toks.length) ? toks[i + 1] : "";
      final prevIsNasal = (prev == "n" || prev == "ŋ" || prev == "ɲ");
      final intervoc = isVowel(prev) && isVowel(next);
      return prevIsNasal || intervoc;
    },
    apply: (_) => ["g", "k", "x"],
  );

  static final Rule K_FINAL_ALTS = Rule(
    id: "K_FINAL_X_G",
    explain: "k final → x/g/k",
    match: (seg, i, toks) => seg == "k" && i == toks.length - 1,
    apply: (_) => ["x", "g", "k"],
  );

  static final Rule H_TO_X_OR_NULL = Rule(
    id: "H>X_OR_Ø",
    explain: "h→x/∅",
    match: (seg, i, toks) => seg == "h",
    apply: (_) => ["x", ""],
  );

  static final Rule S_SH_SWAP = Rule(
    id: "S↔Š",
    explain: "s↔š",
    match: (seg, i, toks) => (seg == "s" || seg == "š"),
    apply: (seg) => seg == "s" ? ["š"] : ["s"],
  );

  // ll/ʎ: solo ly (visible) en variantes
  static final Rule LY_ALTS_EXTRA = Rule(
    id: "LY_ALTS_EXTRA",
    explain: "ll→ly",
    match: (seg, i, toks) => (seg == "ly" || seg == "ʎ"),
    apply: (_) => ["ly"],
  );

  static final Rule N_ASSIMILATION = Rule(
    id: "N_ASSIM",
    explain: "n→m ante p/b/m; n→ŋ ante k/g/q",
    match: (seg, i, toks) {
      if (seg != "n") return false;
      final next = (i + 1 < toks.length) ? toks[i + 1] : "";
      if (next.isEmpty) return false;
      return next == "p" ||
          next == "b" ||
          next == "m" ||
          next == "k" ||
          next == "g" ||
          next == "q";
    },
    apply: (_) => ["m", "ŋ", "n"],
  );

  static final Rule N_TILDE_ALTS = Rule(
    id: "Ñ_ALTS",
    explain: "ñ→n/y/ly",
    match: (seg, i, toks) => (seg == "ñ" || seg == "ɲ"),
    apply: (_) => ["n", "y", "ly"],
  );

  static final Rule W_ALTS = Rule(
    id: "W_ALTS",
    explain: "w→b/∅",
    match: (seg, i, toks) => seg == "w",
    apply: (_) => ["b", ""],
  );

  static final Rule R_ALTS_EXTRA = Rule(
    id: "R_EXTRA",
    explain: "r↔R/l/ly",
    match: (seg, i, toks) => (seg == "r" || seg == "ɾ"),
    apply: (_) => ["R", "l", "ly"],
  );

  static List<Rule> RULES_KAMU = [
    K_BEFORE_CH_OR_T_TO_X,
    K_INTERVOCALIC_OR_AFTER_NASAL_TO_G,
    K_FINAL_ALTS,
    H_TO_X_OR_NULL,
    S_SH_SWAP,
    LY_ALTS_EXTRA,
    N_ASSIMILATION,
    N_TILDE_ALTS,
    W_ALTS,
    R_ALTS_EXTRA,
  ];
}
