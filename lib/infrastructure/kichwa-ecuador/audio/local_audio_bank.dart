import '../../../domain/entities/kichwa-ecuador/audio_item.dart';
import '../../../domain/entities/kichwa-ecuador/phoneme_unit.dart';
import '../../../domain/repositories/kichwa-ecuador/audio_bank_repository.dart';

class LocalAudioBank implements AudioBankRepository {
  //TODO CHAT
  static const String base = "assets/audio/phonemes";
  @override
  String resolveAsset(PhonemeUnit unit) {
    final name = unit.key.isEmpty ? "_beep" : unit.key;
    return "$base/$name.wav";
  }
}

// Salida de variantes con audio
class VariantWithAudio {
  final String form; // "ačupalya"
  final List<AudioItem> audioPlan; // rutas por fonema
  final String note; // explicación corta
  const VariantWithAudio({
    required this.form,
    required this.audioPlan,
    required this.note,
  });
}
