// g2p_mapper.dart
import '../../../domain/entities/kichwa-ecuador/audio_item.dart';
import '../../../domain/entities/kichwa-ecuador/g2p_output.dart';
import '../../../domain/entities/kichwa-ecuador/phoneme_unit.dart';
import '../../../domain/models/kichwa-ecuador/manager_kichwa.dart'; // <- VariantWithAudio, KAMUParams
import '../../../domain/services/kichwa-ecuador/g2p_service.dart';
import '../../../domain/value_objects/kichwa-ecuador/word_input.dart';
import '../../../infrastructure/kichwa-ecuador/audio/local_audio_bank.dart';
import 'g2p_config.dart';
import 'g2p_expander.dart';
import 'g2p_normalizer.dart';
import 'g2p_pre_detector.dart';
import 'g2p_rules.dart';
import 'g2p_symbols.dart';
import 'segmenter.dart';

class G2PRunOptions {
  final bool? emitLyForLl; // solo salida visible
  final bool? allowKDeletionBeforeApproximants; // reglas de expansión /k/
  const G2PRunOptions({
    this.emitLyForLl,
    this.allowKDeletionBeforeApproximants,
  });
}

extension G2POverrides on G2PKichwaMapper {
  /// Igual que analyzeSmart pero permitiendo overrides por llamada
  List<VariantWithAudio> analyzeSmartWithOverrides(
    String word, {
    G2PRunOptions opts = const G2PRunOptions(),
  }) {
    // 1) Clonamos la config SOLO para esta ejecución (sin tocar la instancia)
    final tmpCfg = cfg.copyWith(
      emitLyForLl: opts.emitLyForLl,
      allowKDeletionBeforeApproximants: opts.allowKDeletionBeforeApproximants,
    );

    // 2) Construimos normalizador y expansor temporales con esa config
    final norm = G2PNormalizer(tmpCfg);
    final exp = G2PExpander(tmpCfg);

    // 3) Canónica con el pipeline normal de la instancia (cfg base)
    final base = analyze(word);
    final params = _autoParams(word); // esto ya es por palabra

    // 4) Expandimos KAMU con el expansor temporal (para que respete overrides)
    final toks = exp.tokenize(base.phonemic);
    final tmp = exp.buildKAMU(
      toks: toks,
      preKichwa: params.preKichwa,
      maxPerSegment: params.maxPerSegment,
      maxVariants: params.maxVariants,
      conservative: true,
    );

    // 5) Resultado: canónica + variantes (forma visible con norm temporal)
    final results = <VariantWithAudio>[
      VariantWithAudio(
        form: norm.visibleFromCanonical(base.phonemic),
        audioPlan: _audioPlanFromPhonemic(base.phonemic),
        note: "Forma fonémica canónica (base).",
      ),
    ];

    final seen = <String>{base.phonemic};
    for (final v in exp.postDialect(tmp, amazonico: params.amazonico)) {
      if (!seen.add(v.form)) continue;
      results.add(
        VariantWithAudio(
          form: norm.visibleFromCanonical(v.form),
          audioPlan: _audioPlanFromPhonemic(v.form),
          note: v.ruleIds.isEmpty
              ? "Variante según catálogo KAMU."
              : "Variante KAMU: ${v.ruleIds.join(", ")}",
        ),
      );
    }
    return results;
  }
}

class G2PKichwaMapper implements G2PService {
  final Segmenter _segmenter;
  final LocalAudioBank? _audio;
  final G2PConfig cfg;
  final G2PNormalizer _norm;
  final G2PExpander _expander;

  G2PKichwaMapper(
    this._segmenter, {
    LocalAudioBank? audioBank,
    G2PConfig config =
        const G2PConfig(), // <- sin const si tu constructor no es const
  }) : _audio = audioBank,
       cfg = config,
       _norm = G2PNormalizer(config),
       _expander = G2PExpander(config);

  // ============== Public API ==============

  @override
  G2POutput analyze(String word) {
    final normalized = _norm.normalizeInput(word);
    final tokens = _segmenter.segment(WordInput(normalized));

    final units = <PhonemeUnit>[];
    final outTokens = <String>[];

    for (final t in tokens) {
      var spec = G2PSymbols.graphemeMap[t.value];
      if (spec == null) {
        units.add(
          PhonemeUnit(grapheme: t.value, ipa: "?", symbol: "�", key: "_beep"),
        );
        outTokens.add(t.value);
        continue;
      }
      if (t.value == 'll') {
        spec = (ipa: spec.ipa, symbol: cfg.llSymbol, key: spec.key);
      } else if (t.value == 'h') {
        spec = (ipa: spec.ipa, symbol: cfg.hSymbol, key: spec.key);
      }
      units.add(
        PhonemeUnit(
          grapheme: t.value,
          ipa: "/${spec.ipa}/",
          symbol: spec.symbol,
          key: spec.key,
        ),
      );
      outTokens.add(t.value);
    }

    final canonical = cfg.enableNarrowPhonology
        ? _applyNarrowPhonology(units)
        : units.map((u) => u.symbol).join();

    final withKAllophony = _applyKAllophony(units, canonical);

    final audioPlan = <AudioItem>[];
    if (_audio != null) {
      for (final u in units) {
        audioPlan.add(
          AudioItem(
            grapheme: u.grapheme,
            ipa: u.ipa,
            assetPath: _audio!.resolveAsset(u),
          ),
        );
      }
    }

    return G2POutput(
      tokens: outTokens,
      phonemic: _norm.visibleFromCanonical(withKAllophony),
      audioPlan: audioPlan,
    );
  }

  /// Smart: usa detector preKichwa, expande con KAMU y aplica forma visible.
  List<VariantWithAudio> analyzeSmart(String word) {
    final base = analyzeCanonical(word);
    final p = _autoParams(word);

    final toks = _expander.tokenize(base.phonemic);
    final tmp = _expander.buildKAMU(
      toks: toks,
      preKichwa: p.preKichwa,
      maxPerSegment: p.maxPerSegment,
      maxVariants: p.maxVariants,
      conservative: true,
    );

    final results = <VariantWithAudio>[
      VariantWithAudio(
        form: _norm.visibleFromCanonical(base.phonemic),
        audioPlan: _audioPlanFromPhonemic(base.phonemic),
        note: "Forma fonémica canónica (base).",
      ),
    ];

    final seen = <String>{base.phonemic};
    for (final v in _expander.postDialect(tmp, amazonico: p.amazonico)) {
      if (!seen.add(v.form)) continue;
      results.add(
        VariantWithAudio(
          form: _norm.visibleFromCanonical(v.form),
          audioPlan: _audioPlanFromPhonemic(v.form),
          note: v.ruleIds.isEmpty
              ? "Variante según catálogo KAMU."
              : "Variante KAMU: ${v.ruleIds.join(", ")}",
        ),
      );
    }
    return results;
  }

  /// Igual que analyzeSmart pero devolviendo siempre canónica + variantes KAMU.
  List<VariantWithAudio> analyzeWithVariantsAndAudioKAMU(String word) {
    final base = analyze(word);
    final params = _autoParams(word);
    final toks = _expander.tokenize(base.phonemic);

    final tmp = _expander.buildKAMU(
      toks: toks,
      preKichwa: params.preKichwa,
      maxPerSegment: params.maxPerSegment,
      maxVariants: params.maxVariants,
      conservative: true,
    );

    final results = <VariantWithAudio>[
      VariantWithAudio(
        form: _norm.visibleFromCanonical(base.phonemic),
        audioPlan: _audioPlanFromPhonemic(base.phonemic),
        note: "Forma fonémica canónica (base).",
      ),
    ];

    final seen = <String>{base.phonemic};
    for (final v in _expander.postDialect(tmp, amazonico: params.amazonico)) {
      if (!seen.add(v.form)) continue;
      results.add(
        VariantWithAudio(
          form: _norm.visibleFromCanonical(v.form),
          audioPlan: _audioPlanFromPhonemic(v.form),
          note: v.ruleIds.isEmpty
              ? "Variante según catálogo KAMU."
              : "Variante KAMU: ${v.ruleIds.join(", ")}",
        ),
      );
    }
    return results;
  }

  // ============== Helpers internos ==============

  G2POutput analyzeCanonical(String word) => analyze(word);

  KAMUParams _autoParams(String input) {
    final hits = <PreKichwaHit>[];
    final isPre = PreKichwaDetector().isPreKichwa(input, outHits: hits);

    final canon = analyze(input).phonemic;
    final toks = _expander.tokenize(canon);

    final hasRich =
        canon.contains('č') || canon.contains('ʎ') || canon.contains('ʝ');
    int mps = hasRich && canon.length <= 7 ? 3 : 2;
    if (canon.length >= 10) mps = 2;

    int est = 1;
    for (final t in toks) {
      final vList = G2PRules.KAMU_VARIANTS[t] ?? [t];
      final contrib = (vList.length > 1)
          ? (vList.length.clamp(1, mps) as int)
          : 1;
      est *= contrib;
      if (est > 80) {
        est = 80;
        break;
      }
    }
    final maxVars = (est.clamp(12, 40) as int);

    return KAMUParams(
      preKichwa: isPre,
      amazonico: false,
      maxPerSegment: mps,
      maxVariants: maxVars,
    );
  }

  String _applyNarrowPhonology(List<PhonemeUnit> units) {
    final buf = StringBuffer();
    for (var i = 0; i < units.length; i++) {
      final cur = units[i];
      var sym = cur.symbol;
      if (cur.grapheme == 'n') {
        final hasNext = i + 1 < units.length;
        final next = hasNext ? units[i + 1] : null;
        final nextKey = next?.key ?? '';
        final beforeVelar = nextKey == 'k' || nextKey == 'q' || nextKey == 'g';
        if (beforeVelar) sym = 'ŋ'; // final absoluto: lo evitamos aquí
      }
      buf.write(sym);
    }
    return buf.toString();
  }

  String _applyKAllophony(List<PhonemeUnit> units, String current) {
    if (!(cfg.kVoicingAfterNasal ||
        cfg.kIntervocalicVoicing ||
        cfg.kSpirantizeBeforeT ||
        cfg.kSpirantizeBeforeCH)) {
      return current;
    }
    final out = current.split('');
    for (int i = 0; i < units.length; i++) {
      if (units[i].grapheme != 'k') continue;
      final prevChar = i > 0 ? out[i - 1] : '';
      final nextChar = i + 1 < out.length ? out[i + 1] : '';
      final prevIsV = 'aiueo'.contains(prevChar);
      final nextIsV = 'aiueo'.contains(nextChar);
      final prevIsNasal =
          (prevChar == 'n' || prevChar == 'ŋ' || prevChar == 'ɲ');
      final nextIsT = (nextChar == 't');
      final nextIsC = (nextChar == 'č');

      if (cfg.kVoicingAfterNasal && prevIsNasal) {
        out[i] = 'g';
      } else if (cfg.kIntervocalicVoicing && prevIsV && nextIsV) {
        out[i] = 'g';
      } else if (cfg.kSpirantizeBeforeT && nextIsT) {
        out[i] = 'x';
      } else if (cfg.kSpirantizeBeforeCH && nextIsC) {
        out[i] = 'x';
      }
    }
    return out.join();
  }

  List<AudioItem> _audioPlanFromPhonemic(String phonemic) {
    final plan = <AudioItem>[];
    final toks = _expander.tokenize(phonemic.replaceAll('ly', 'ʎ'));
    for (final t in toks) {
      final sym = (t == 'ly') ? 'ʎ' : t;
      final key = G2PSymbols.assetKey(sym);
      final asset = (_audio != null)
          ? _audio!.resolveAsset(
              PhonemeUnit(grapheme: sym, ipa: "/$sym/", symbol: sym, key: key),
            )
          : "assets/audio/phonemes/$key.wav";
      plan.add(AudioItem(grapheme: sym, ipa: "/$sym/", assetPath: asset));
    }
    return plan;
  }
}
