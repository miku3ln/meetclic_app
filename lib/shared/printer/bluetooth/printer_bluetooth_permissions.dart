
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PrinterBluetoothPermissions {
  static Future<bool> request() async {
    if (!Platform.isAndroid) return false;

    final info = await DeviceInfoPlugin().androidInfo;

    if (info.version.sdkInt >= 31) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      return statuses.values.every(
            (status) => status.isGranted,
      );
    }

    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
