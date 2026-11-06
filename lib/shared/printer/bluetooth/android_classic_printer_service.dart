
import 'package:flutter/services.dart';

import '../models/printer_device.dart';

class AndroidClassicPrinterService {
  static const MethodChannel _channel =
  MethodChannel('pos/printer_bluetooth_classic');

  Future<List<PrinterDevice>> scan() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'scan',
    );

    return _parseDevices(result);
  }

  Future<List<PrinterDevice>> getBondedDevices() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getBondedDevices',
    );

    return _parseDevices(result);
  }

  Future<PrinterDevice> pair(String address) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pair',
      {'address': address},
    );

    if (result == null) {
      throw StateError('No se recibió respuesta de Android');
    }

    return PrinterDevice.fromJson(
      Map<String, dynamic>.from(result),
    );
  }

  Future<PrinterDevice> getDetails(String address) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'details',
      {'address': address},
    );

    if (result == null) {
      throw StateError('No se encontraron detalles');
    }

    return PrinterDevice.fromJson(
      Map<String, dynamic>.from(result),
    );
  }

  List<PrinterDevice> _parseDevices(List<dynamic>? values) {
    return (values ?? []).map((value) {
      return PrinterDevice.fromJson(
        Map<String, dynamic>.from(value as Map),
      );
    }).toList();
  }
}
