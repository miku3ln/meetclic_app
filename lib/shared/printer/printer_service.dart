import 'dart:typed_data';

import 'bluetooth/bluetooth_printer_service.dart';
import 'drivers/printer_driver.dart';
import 'models/printer_device.dart';

class PrinterService {
  PrinterService({
    required this.bluetooth,
    required this.driver,
  });

  final BluetoothPrinterService bluetooth;
  final PrinterDriver driver;

  /// Obtiene los dispositivos emparejados
  Future<List<PrinterDevice>> getBondedDevices() {
    return bluetooth.getBondedDevices();
  }

  /// Escanea dispositivos cercanos
  Future<List<PrinterDevice>> scan() {
    return bluetooth.scan();
  }

  /// Conecta una impresora
  Future<void> connect(String deviceId) {
    return bluetooth.connect(deviceId);
  }

  /// Desconecta la impresora
  Future<void> disconnect() {
    return bluetooth.disconnect();
  }

  /// Estado de conexión
  Stream<bool> connectionState() {
    return bluetooth.connectionState();
  }

  /// Envía bytes directamente
  Future<void> printBytes(List<int> bytes) async {
    await bluetooth.write(bytes);
  }

  /// Imprime texto
  Future<void> printText(String text) async {
    final bytes = <int>[];

    bytes.addAll(await driver.text(text));
    bytes.addAll(await driver.feed(2));
    bytes.addAll(await driver.cut());

    await printBytes(bytes);
  }

  /// Imprime un QR
  Future<void> printQr(String value) async {
    final bytes = <int>[];

    bytes.addAll(await driver.qr(value));
    bytes.addAll(await driver.feed(2));
    bytes.addAll(await driver.cut());

    await printBytes(bytes);
  }

  /// Imprime una imagen
  Future<void> printImage(Uint8List image) async {
    final bytes = <int>[];

    bytes.addAll(await driver.image(image));
    bytes.addAll(await driver.feed(2));
    bytes.addAll(await driver.cut());

    await printBytes(bytes);
  }
}