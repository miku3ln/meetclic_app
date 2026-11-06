
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/printer_device.dart';

class PrinterDeviceCache {
  static const String _storageKey = 'pos_printer_devices_v1';

  Future<void> _pendingWrite = Future<void>.value();

  // ==========================================
  // DEVICE KEY
  // ==========================================

  String _deviceKey(PrinterDevice device) {
    return '${device.bluetoothType.name}:'
        '${device.address.trim().toUpperCase()}';
  }

  // ==========================================
  // GET ALL
  // ==========================================

  Future<List<PrinterDevice>> getAll() async {
    await _pendingWrite;

    return _read();
  }

  Future<List<PrinterDevice>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    List<dynamic> decoded;

    try {
      final value = jsonDecode(raw);

      if (value is! List) {
        return [];
      }

      decoded = value;
    } catch (_) {
      return [];
    }

    final devices = <String, PrinterDevice>{};

    for (final item in decoded) {
      try {
        if (item is! Map) continue;

        final device = PrinterDevice.fromJson(
          Map<String, dynamic>.from(item),
        );

        devices[_deviceKey(device)] = device;
      } catch (_) {
        // Ignorar solo el registro inválido.
      }
    }

    return devices.values.toList();
  }

  // ==========================================
  // SAVE ALL
  // ==========================================

  Future<void> saveAll(
      List<PrinterDevice> devices,
      ) {
    return _enqueue(() async {
      final unique = <String, PrinterDevice>{};

      for (final device in devices) {
        unique[_deviceKey(device)] = device;
      }

      await _write(unique.values.toList());
    });
  }

  // ==========================================
  // UPSERT
  // ==========================================

  Future<void> upsert(
      PrinterDevice device,
      ) {
    return _enqueue(() async {
      final devices = await _read();

      final unique = <String, PrinterDevice>{
        for (final item in devices)
          _deviceKey(item): item,
      };

      unique[_deviceKey(device)] = device;

      await _write(unique.values.toList());
    });
  }

  // ==========================================
  // REMOVE BY ID
  // ==========================================

  Future<void> remove(String id) {
    return _enqueue(() async {
      final devices = await _read();

      devices.removeWhere(
            (device) => device.id == id,
      );

      await _write(devices);
    });
  }

  // ==========================================
  // CLEAR
  // ==========================================

  Future<void> clear() {
    return _enqueue(() async {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_storageKey)) {
        return;
      }

      final removed = await prefs.remove(_storageKey);

      if (!removed) {
        throw StateError(
          'No se pudo limpiar la caché de impresoras.',
        );
      }
    });
  }

  // ==========================================
  // INTERNAL WRITE
  // ==========================================

  Future<void> _write(
      List<PrinterDevice> devices,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      devices.map((device) => device.toJson()).toList(),
    );

    final saved = await prefs.setString(
      _storageKey,
      encoded,
    );

    if (!saved) {
      throw StateError(
        'No se pudieron guardar los dispositivos.',
      );
    }
  }

  // ==========================================
  // SERIALIZE WRITES
  // ==========================================

  Future<void> _enqueue(
      Future<void> Function() operation,
      ) {
    final result = _pendingWrite
        .catchError((Object _) {})
        .then((_) => operation());

    _pendingWrite = result;

    return result;
  }
}
