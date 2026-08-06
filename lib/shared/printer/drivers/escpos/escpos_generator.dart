import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import 'package:image/image.dart' as img;

class EscPosGenerator {
  final Generator _generator;

  EscPosGenerator._(this._generator);

  static Future<EscPosGenerator> create({
    PaperSize paperSize = PaperSize.mm80,
  }) async {
    final profile = await CapabilityProfile.load();

    return EscPosGenerator._(
      Generator(
        paperSize,
        profile,
      ),
    );
  }

  List<int> text(
      String value, {
        PosAlign align = PosAlign.left,
        PosTextSize width = PosTextSize.size1,
        PosTextSize height = PosTextSize.size1,
        bool bold = false,
      }) {
    final bytes = <int>[];

    bytes.addAll(
      _generator.text(
        value,
        styles: PosStyles(
          align: align,
          width: width,
          height: height,
          bold: bold,
        ),
      ),
    );

    return bytes;
  }

  List<int> qr(String value) {
    final bytes = <int>[];

    bytes.addAll(_generator.qrcode(value));

    return bytes;
  }

  List<int> barcode(String value) {
    final bytes = <int>[];

    bytes.addAll(
      _generator.barcode(
        Barcode.upcA(value as List),
      ),
    );

    return bytes;
  }

  List<int> image(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      return [];
    }

    final bytes = <int>[];

    bytes.addAll(
      _generator.image(image),
    );

    return bytes;
  }

  List<int> feed([int lines = 1]) {
    return _generator.feed(lines);
  }

  List<int> cut() {
    return _generator.cut();
  }
}