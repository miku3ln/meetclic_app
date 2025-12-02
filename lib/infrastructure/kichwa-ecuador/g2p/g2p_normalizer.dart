// g2p_normalizer.dart
// Normalización del texto y conversión a forma visible.

import 'g2p_config.dart';

class G2PNormalizer {
  final G2PConfig cfg;
  G2PNormalizer(this.cfg);

  String normalizeInput(String raw) {
    var s = raw.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s
        .replaceAll(' l y', ' ly')
        .replaceAll('l y ', 'ly ')
        .replaceAll('l y', 'ly');

    if (cfg.repairLyToLl) {
      s = s.replaceAllMapped(
        RegExp(r'(^|[aiueo])ly(?=[aiueo]|$)'),
        (m) => '${m.group(1)}ll',
      );
    }
    if (cfg.mapXtoH) s = s.replaceAll('x', 'h');
    s = s.replaceAll('ž', 'zh').replaceAll('ʒ', 'zh');
    return s;
  }

  String visibleFromCanonical(String s) {
    if (!cfg.emitLyForLl) return s;
    return s.replaceAll('ʎ', 'ly');
  }
}
