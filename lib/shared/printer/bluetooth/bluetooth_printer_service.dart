import '../models/printer_device.dart';

abstract class BluetoothPrinterService {

  Future<List<PrinterDevice>> getBondedDevices();

  Future<List<PrinterDevice>> scan();

  Future<void> connect(String deviceId);

  Future<void> disconnect();

  Stream<bool> connectionState();

  Future<void> write(
      List<int> bytes);

}