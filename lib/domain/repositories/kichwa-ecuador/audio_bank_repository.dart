import '../../entities/kichwa-ecuador/phoneme_unit.dart';

abstract class AudioBankRepository {
  String resolveAsset(PhonemeUnit unit); // devuelve ruta asset (.wav)
}
