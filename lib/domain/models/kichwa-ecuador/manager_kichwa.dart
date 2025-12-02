// --- Parámetros auto para KAMU ---
class KAMUParams {
  final bool preKichwa;
  final bool amazonico;
  final int maxPerSegment;
  final int maxVariants;

  const KAMUParams({
    required this.preKichwa,
    required this.amazonico,
    required this.maxPerSegment,
    required this.maxVariants,
  });
}

// Tipos para reglas
typedef RuleMatch = bool Function(String seg, int idx, List<String> toks);
typedef RuleApply = List<String> Function(String seg);

class Rule {
  final String id;
  final RuleMatch match;
  final RuleApply apply;
  final String explain;
  final String? example;

  const Rule({
    required this.id,
    required this.match,
    required this.apply,
    required this.explain,
    this.example,
  });
}

// Var temporal (DFS)
class VarTmp {
  final String form;
  final List<String> ruleIds;
  VarTmp(this.form, this.ruleIds);
}
