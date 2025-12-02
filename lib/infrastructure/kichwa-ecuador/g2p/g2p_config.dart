// g2p_config.dart
class G2PConfig {
  // Fonología “estrecha”
  final bool enableNarrowPhonology;

  // Alófonos /k/ en analyze() básico
  final bool kVoicingAfterNasal;
  final bool kIntervocalicVoicing;
  final bool kSpirantizeBeforeT;
  final bool kSpirantizeBeforeCH;

  // Símbolos / ortografía
  final String llSymbol; // "ʎ" o "ʝ"
  final String hSymbol; // "h" o "x"
  final bool repairLyToLl;
  final bool mapXtoH;
  final bool emitLyForLl;

  // Variantes
  final bool allowKDeletionBeforeApproximants;

  const G2PConfig({
    this.enableNarrowPhonology = false,
    this.kVoicingAfterNasal = false,
    this.kIntervocalicVoicing = false,
    this.kSpirantizeBeforeT = false,
    this.kSpirantizeBeforeCH = false,
    this.llSymbol = "ʎ",
    this.hSymbol = "h",
    this.repairLyToLl = true,
    this.mapXtoH = true,
    this.emitLyForLl = false,
    this.allowKDeletionBeforeApproximants = false,
  });

  G2PConfig copyWith({
    bool? enableNarrowPhonology,
    bool? kVoicingAfterNasal,
    bool? kIntervocalicVoicing,
    bool? kSpirantizeBeforeT,
    bool? kSpirantizeBeforeCH,
    String? llSymbol,
    String? hSymbol,
    bool? repairLyToLl,
    bool? mapXtoH,
    bool? emitLyForLl,
    bool? allowKDeletionBeforeApproximants,
  }) => G2PConfig(
    enableNarrowPhonology: enableNarrowPhonology ?? this.enableNarrowPhonology,
    kVoicingAfterNasal: kVoicingAfterNasal ?? this.kVoicingAfterNasal,
    kIntervocalicVoicing: kIntervocalicVoicing ?? this.kIntervocalicVoicing,
    kSpirantizeBeforeT: kSpirantizeBeforeT ?? this.kSpirantizeBeforeT,
    kSpirantizeBeforeCH: kSpirantizeBeforeCH ?? this.kSpirantizeBeforeCH,
    llSymbol: llSymbol ?? this.llSymbol,
    hSymbol: hSymbol ?? this.hSymbol,
    repairLyToLl: repairLyToLl ?? this.repairLyToLl,
    mapXtoH: mapXtoH ?? this.mapXtoH,
    emitLyForLl: emitLyForLl ?? this.emitLyForLl,
    allowKDeletionBeforeApproximants:
        allowKDeletionBeforeApproximants ??
        this.allowKDeletionBeforeApproximants,
  );
}
