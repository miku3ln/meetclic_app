import 'dart:typed_data';

abstract class PrinterDriver {
  Future<List<int>> text(String text);

  Future<List<int>> qr(String value);

  Future<List<int>> barcode(String value);

  Future<List<int>> image(Uint8List image);

  Future<List<int>> cut();
  Future<List<int>> feed(int lines);
}