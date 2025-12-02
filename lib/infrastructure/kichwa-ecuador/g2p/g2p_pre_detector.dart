// g2p_pre_detector.dart
// Detector simple de “preKichwa”.

class PreKichwaHit {
  final String pattern;
  final int start;
  PreKichwaHit(this.pattern, this.start);
}

class PreKichwaDetector {
  final bool countXAsZh; // tratar 'x' ~ 'zh'
  final bool allowZtoSOnlyWithOtherClues;

  PreKichwaDetector({
    this.countXAsZh = true,
    this.allowZtoSOnlyWithOtherClues = true,
  });

  bool isPreKichwa(String input, {List<PreKichwaHit>? outHits}) {
    final s = input.toLowerCase();
    final hits = <PreKichwaHit>[];

    for (final pat in ['ts', 'zh']) {
      int idx = s.indexOf(pat);
      while (idx >= 0) {
        hits.add(PreKichwaHit(pat, idx));
        idx = s.indexOf(pat, idx + 1);
      }
    }

    if (countXAsZh) {
      int idx = s.indexOf('x');
      while (idx >= 0) {
        hits.add(PreKichwaHit('x≈zh', idx));
        idx = s.indexOf('x', idx + 1);
      }
    }

    final zIdx = s.indexOf('z');
    if (zIdx >= 0 && (!allowZtoSOnlyWithOtherClues || hits.isNotEmpty)) {
      hits.add(PreKichwaHit('z', zIdx));
    }

    if (outHits != null) outHits.addAll(hits);
    return hits.isNotEmpty;
  }
}
