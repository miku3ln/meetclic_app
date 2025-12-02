import '../../entities/kichwa-ecuador/g2p_output.dart';

abstract class G2PService {
  G2POutput analyze(String word);
}
