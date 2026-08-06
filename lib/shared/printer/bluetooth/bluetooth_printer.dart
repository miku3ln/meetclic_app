import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/printer_device.dart';

class BluetoothPrinter {
  final PrinterDevice device;
  final BluetoothDevice bluetoothDevice;

  BluetoothCharacteristic? writeCharacteristic;

  BluetoothPrinter({
    required this.device,
    required this.bluetoothDevice,
    this.writeCharacteristic,
  });

  bool get isConnected =>
      bluetoothDevice.isConnected;
}
class PrinterCapabilities {
  late final bool supportsText;
  late final bool supportsQr;
  late final bool supportsBarcode;
  late final bool supportsImage;
  late final bool supportsCut;
  late final bool supportsLabels;
  late final bool supportsReceipts;
  late final int maxWidthDots;
}