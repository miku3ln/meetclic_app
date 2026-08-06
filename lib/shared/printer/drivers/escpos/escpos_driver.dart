import 'dart:typed_data';

import '../printer_driver.dart';
import 'escpos_generator.dart';

class EscPosDriver implements PrinterDriver {
  final EscPosGenerator generator;

  EscPosDriver(this.generator);

  @override
  Future<List<int>> text(String text) async {
    return generator.text(text);
  }

  @override
  Future<List<int>> qr(String value) async {
    return generator.qr(value);
  }

  @override
  Future<List<int>> barcode(String value) async {
    return generator.barcode(value);
  }

  @override
  Future<List<int>> image(Uint8List image) async {
    return generator.image(image);
  }

  @override
  Future<List<int>> feed(int lines) async {
    return generator.feed(lines);
  }

  @override
  Future<List<int>> cut() async {
    return generator.cut();
  }
}