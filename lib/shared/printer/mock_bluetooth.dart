import 'bluetooth/bluetooth_printer_service.dart';
import 'drivers/printer_driver.dart';
import 'models/printer_device.dart';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FlutterBluetoothPrinterService implements BluetoothPrinterService {
  BluetoothDevice? _connectedDevice;

  @override
  Future<List<PrinterDevice>> getBondedDevices() async {
    // flutter_blue_plus no permite obtener "paired devices"
    // directamente en Android moderno.
    // Usamos dispositivos encontrados previamente.

    final devices = FlutterBluePlus.connectedDevices;

    return devices.map((device) {
      return PrinterDevice(
        id: device.remoteId.str,
        name: device.platformName.isEmpty
            ? 'Bluetooth Device'
            : device.platformName,
        address: device.remoteId.str,
        bonded: true,
        connected: true,
      );
    }).toList();
  }

  @override
  Future<List<PrinterDevice>> scan() async {
    final List<PrinterDevice> result = [];

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final device = r.device;

        final exists = result.any((e) => e.id == device.remoteId.str);

        if (!exists) {
          result.add(
            PrinterDevice(
              id: device.remoteId.str,

              name: device.platformName.isEmpty
                  ? 'Bluetooth Device'
                  : device.platformName,

              address: device.remoteId.str,

              bonded: false,

              connected: device.isConnected,
            ),
          );
        }
      }
    });

    await Future.delayed(const Duration(seconds: 5));

    await FlutterBluePlus.stopScan();
    await subscription.cancel();
    return result;
  }

  @override
  Future<void> connect(String deviceId) async {
    final devices = await FlutterBluePlus.connectedDevices;

    final device = devices.firstWhere(
      (e) => e.remoteId.str == deviceId,
      orElse: () => throw Exception('Dispositivo no encontrado'),
    );

    await device.connect();

    _connectedDevice = device;
  }

  @override
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();

      _connectedDevice = null;
    }
  }

  @override
  Stream<bool> connectionState() {
    if (_connectedDevice == null) {
      return Stream.value(false);
    }

    return _connectedDevice!.connectionState.map(
      (state) => state == BluetoothConnectionState.connected,
    );
  }

  @override
  Future<void> write(List<int> bytes) async {
    if (_connectedDevice == null) {
      throw Exception('No existe impresora conectada');
    }

    final services = await _connectedDevice!.discoverServices();

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.properties.write ||
            characteristic.properties.writeWithoutResponse) {
          await characteristic.write(
            bytes,
            withoutResponse: characteristic.properties.writeWithoutResponse,
          );

          return;
        }
      }
    }

    throw Exception('No se encontró característica de escritura');
  }
}

class MockPrinterDriver implements PrinterDriver {
  @override
  Future<List<int>> text(String text) async {
    return text.codeUnits;
  }

  @override
  Future<List<int>> qr(String value) async {
    return value.codeUnits;
  }

  @override
  Future<List<int>> barcode(String value) async {
    return value.codeUnits;
  }

  @override
  Future<List<int>> image(Uint8List image) async {
    return image.toList();
  }

  @override
  Future<List<int>> cut() async {
    return [0x1D, 0x56, 0x00];
  }

  @override
  Future<List<int>> feed(int lines) async {
    return List.generate(lines, (index) => 0x0A);
  }
}
