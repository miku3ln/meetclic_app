// g2p_expander.dart
// Tokeniza, calcula variantes por segmento (KAMU) y compone combinaciones.

import 'g2p_config.dart';
import 'g2p_rules.dart';

class VarTmp {
  final String form;
  final List<String> ruleIds;
  VarTmp(this.form, this.ruleIds);
}

class G2PExpander {
  final G2PConfig cfg;
  G2PExpander(this.cfg);

  // Tokenización fonémica: maneja 'ts' y 'ly'
  List<String> tokenize(String s) {
    final out = <String>[];
    int i = 0;
    while (i < s.length) {
      if (i + 1 < s.length && s[i] == 't' && s[i + 1] == 's') {
        out.add("ts");
        i += 2;
        continue;
      }
      if (i + 1 < s.length && s[i] == 'l' && s[i + 1] == 'y') {
        out.add("ly");
        i += 2;
        continue;
      }
      out.add(s[i]);
      i++;
    }
    return out;
  }

  List<(String, List<String>)> _segmentVariantsKAMU(
    String seg,
    int i,
    List<String> toks, {
    required bool preKichwa,
    required int maxPerSegment,
    bool conservative = true,
  }) {
    List<String> baseList = List.of(G2PRules.KAMU_VARIANTS[seg] ?? [seg]);

    if (conservative && !G2PRules.ALLOWED_EXPAND.contains(seg)) {
      baseList = [seg];
    }

    if (seg == "č") {
      baseList = preKichwa ? ["č", "š", "s", "ts", "ž"] : ["č"];
    }

    if (seg == "k") {
      final isFinal = (i == toks.length - 1);
      final prev = i > 0 ? toks[i - 1] : "";
      final next = !isFinal ? toks[i + 1] : "";

      final prevIsV = G2PRules.isVowel(prev);
      final nextIsV = G2PRules.isVowel(next);
      final prevIsNasal = (prev == "n" || prev == "ŋ" || prev == "ɲ");

      baseList = ["k", "kh", "x", "g", ""];
      final allowG = prevIsNasal || (prevIsV && nextIsV);

      if (isFinal) {
        baseList = allowG ? ["x", "g", "k", "kh", ""] : ["x", "k", "kh", ""];
      } else if (next == "č" || next == "i") {
        baseList = allowG ? ["x", "g", "k", "kh"] : ["x", "k", "kh"];
      } else if (next == "y" ||
          next == "ʎ" ||
          next == "ly" ||
          next == "l" ||
          next == "t") {
        baseList = allowG ? ["x", "g", "k", "kh", ""] : ["x", "k", "kh", ""];
      } else {
        baseList = allowG ? ["g", "k", "kh", "x"] : ["k", "kh", "x"];
      }

      if (!cfg.allowKDeletionBeforeApproximants) {
        baseList = baseList.where((v) => v.isNotEmpty).toList();
      }
    }

    if (seg == "h") baseList = ["h", "x", ""];
    if (seg == "p") baseList = ["p", "ph", "f", "b"];
    if (seg == "t") baseList = ["t", "th", "d", "r"];

    final out = <(String, List<String>)>[];
    int emitted = 0;
    for (final v in baseList) {
      out.add((v, const <String>[]));
      if (++emitted >= maxPerSegment) break;
    }

    for (final r in G2PRules.RULES_KAMU) {
      if (r.match(seg, i, toks)) {
        int count = 0;
        for (final v in r.apply(seg)) {
          if (!(seg == "k" &&
              v.isEmpty &&
              !cfg.allowKDeletionBeforeApproximants)) {
            out.add((v, <String>[r.id]));
            if (++count >= maxPerSegment) break;
          }
        }
      }
    }

    final seen = <String>{};
    return out.where((e) => seen.add(e.$1)).toList();
  }

  void _buildKAMU(
    List<String> toks,
    int i,
    String acc,
    List<String> rulesPath,
    List<VarTmp> out, {
    required bool preKichwa,
    required int maxPerSegment,
    required int maxVariants,
    bool conservative = true,
    bool allowFinalGAtEnd = false, // ← nuevo
  }) {
    if (out.length >= maxVariants) return;
    if (i == toks.length) {
      out.add(VarTmp(acc, rulesPath));
      return;
    }
    final seg = toks[i];
    final alts = _segmentVariantsKAMU(
      seg,
      i,
      toks,
      preKichwa: preKichwa,
      maxPerSegment: maxPerSegment,
      conservative: conservative,
    );

    for (final alt in alts) {
      if (out.length >= maxVariants) break;
      final nextRules = alt.$2.isEmpty ? rulesPath : [...rulesPath, ...alt.$2];
      _buildKAMU(
        toks,
        i + 1,
        acc + alt.$1,
        nextRules,
        out,
        preKichwa: preKichwa,
        maxPerSegment: maxPerSegment,
        maxVariants: maxVariants,
        conservative: conservative,
      );
    }
  }

  List<VarTmp> buildKAMU({
    required List<String> toks,
    required bool preKichwa,
    required int maxPerSegment,
    required int maxVariants,
    bool conservative = true,
  }) {
    final tmp = <VarTmp>[];
    _buildKAMU(
      toks,
      0,
      "",
      <String>[],
      tmp,
      preKichwa: preKichwa,
      maxPerSegment: maxPerSegment,
      maxVariants: maxVariants,
      conservative: conservative,
    );
    return tmp;
  }

  // Ajustes dialectales (amazónico placeholder)
  List<VarTmp> postDialect(List<VarTmp> inVars, {bool amazonico = false}) {
    if (!amazonico) return inVars;
    final out = <VarTmp>[...inVars];
    final seen = out.map((v) => v.form).toSet();

    for (final v in inVars) {
      if (v.form.endsWith("aw")) {
        final stem = v.form.substring(0, v.form.length - 2);
        String raised = stem.replaceAll(RegExp(r"čača$"), "čuču");
        final altUy = raised + "uy";
        if (seen.add(altUy)) {
          out.add(VarTmp(altUy, [...v.ruleIds, "AMZ_AW_TO_UY(+raise)"]));
        }
        final altU = stem + "u";
        if (seen.add(altU)) {
          out.add(VarTmp(altU, [...v.ruleIds, "AMZ_AW_TO_U"]));
        }
      }
    }
    return out;
  }
}
