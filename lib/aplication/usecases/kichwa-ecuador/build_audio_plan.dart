import '../../../domain/entities/kichwa-ecuador/audio_item.dart';
import '../../../domain/entities/kichwa-ecuador/g2p_output.dart';
import '../../../domain/entities/kichwa-ecuador/phoneme_unit.dart';
import '../../../domain/repositories/kichwa-ecuador/audio_bank_repository.dart';
import '../../../domain/services/kichwa-ecuador/g2p_service.dart';

class BuildAudioPlan {
  final G2PService g2p;
  final AudioBankRepository audioBank;

  BuildAudioPlan({required this.g2p, required this.audioBank});

  G2POutput call(String word, {bool withAudio = true}) {
    final base = g2p.analyze(word); // ya arma tokens+phonemic y audioPlan vacío
    if (!withAudio) return base;

    final plans = <AudioItem>[];
    for (final unit in _extractUnits(base)) {
      plans.add(AudioItem(
        grapheme: unit.grapheme,
        ipa: unit.ipa,
        assetPath: audioBank.resolveAsset(unit),
      ));
    }
    return G2POutput(tokens: base.tokens, phonemic: base.phonemic, audioPlan: plans);
  }

  // Obtiene los PhonemeUnit a partir de lo que entregó el G2P (simple shim)
  List<PhonemeUnit> _extractUnits(G2POutput out) {//TODO CHAT
    // Este use case delega al mapper interno; para simplicidad,
    // reconstituimos desde tokens+phonemic no es trivial.
    // En práctica, el G2PService puede exponer los units; aquí lo simplificamos:
    throw UnimplementedError(
        'Para producción: expón units desde G2PService o devuelve AudioItem directo en analyze().'
    );
  }
}
