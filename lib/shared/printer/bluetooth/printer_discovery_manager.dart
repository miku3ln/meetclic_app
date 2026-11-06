
import '../cache/printer_device_cache.dart';
import '../models/printer_device.dart';
import 'android_classic_printer_service.dart';

class PrinterDiscoveryManager {
  final AndroidClassicPrinterService bluetooth;
  final PrinterDeviceCache cache;

  PrinterDiscoveryManager({
    required this.bluetooth,
    required this.cache,
  });

  // ==========================================
  // DEVICE KEY
  // ==========================================

  String _key(PrinterDevice device) {
    return '${device.bluetoothType.name}:'
        '${device.address.trim().toUpperCase()}';
  }

  // ==========================================
  // LOAD SAVED
  // ==========================================

  Future<List<PrinterDevice>> loadSaved() async {
    final saved = await cache.getAll();

    return _sort(saved);
  }

  // ==========================================
  // BONDED DEVICES
  // ==========================================

  Future<List<PrinterDevice>> getBondedDevices() async {
    final bonded = await bluetooth.getBondedDevices();

    final merged = await _mergeAndSave(
      scanned: const [],
      bonded: bonded,
    );

    final bondedKeys = bonded.map(_key).toSet();

    return merged
        .where((device) => bondedKeys.contains(_key(device)))
        .toList();
  }

  // ==========================================
  // SCAN
  // ==========================================

  Future<List<PrinterDevice>> scan() async {
    final scanned = await bluetooth.scan();

    // Consultar Android después del escaneo.
    final bonded = await bluetooth.getBondedDevices();

    final merged = await _mergeAndSave(
      scanned: scanned,
      bonded: bonded,
    );

    final visibleKeys = {
      ...scanned.map(_key),
      ...bonded.map(_key),
    };

    // Mostrar encontrados y emparejados,
    // no todos los registros históricos.
    return merged
        .where(
          (device) => visibleKeys.contains(_key(device)),
    )
        .toList();
  }

  // ==========================================
  // PAIR
  // ==========================================

  Future<PrinterDevice> pair(
      PrinterDevice device,
      ) async {
    if (device.bluetoothType !=
        PrinterBluetoothType.classic) {
      throw UnsupportedError(
        'El emparejamiento actual solo admite '
            'Bluetooth Classic.',
      );
    }

    final paired = await bluetooth.pair(device.address);

    if (!paired.bonded) {
      throw StateError(
        'Android no confirmó el emparejamiento.',
      );
    }

    final saved = await cache.getAll();
    final key = _key(paired);

    PrinterDevice? previous;

    for (final item in saved) {
      if (_key(item) == key) {
        previous = item;
        break;
      }
    }

    final updated = paired.copyWith(
      name: _bestName(
        paired.name,
        previous?.name ?? device.name,
      ),
      rssi: device.rssi ?? previous?.rssi,
      lastSeen: DateTime.now(),
      bonded: true,
      connected: false,
    );

    await cache.upsert(updated);

    return updated;
  }

  // ==========================================
  // DETAILS
  // ==========================================

  Future<PrinterDevice> getDetails(
      PrinterDevice device,
      ) async {
    if (device.bluetoothType !=
        PrinterBluetoothType.classic) {
      throw UnsupportedError(
        'Los detalles nativos actuales '
            'solo admiten Bluetooth Classic.',
      );
    }

    final details =
    await bluetooth.getDetails(device.address);

    final saved = await cache.getAll();
    final key = _key(details);

    PrinterDevice? previous;

    for (final item in saved) {
      if (_key(item) == key) {
        previous = item;
        break;
      }
    }

    final updated = details.copyWith(
      name: _bestName(
        details.name,
        previous?.name ?? device.name,
      ),
      rssi: device.rssi ?? previous?.rssi,
      lastSeen: device.lastSeen ?? previous?.lastSeen,
      connected: false,
    );

    await cache.upsert(updated);

    return updated;
  }

  // ==========================================
  // MERGE AND SAVE
  // ==========================================

  Future<List<PrinterDevice>> _mergeAndSave({
    required List<PrinterDevice> scanned,
    required List<PrinterDevice> bonded,
  }) async {
    final previous = await cache.getAll();
    final now = DateTime.now();

    final bondedKeys = bonded.map(_key).toSet();

    final devices = <String, PrinterDevice>{};

    // ------------------------------------------
    // 1. HISTORICAL CACHE
    // ------------------------------------------

    for (final device in previous) {
      final key = _key(device);

      devices[key] = device.copyWith(
        bonded: device.bluetoothType ==
            PrinterBluetoothType.classic
            ? bondedKeys.contains(key)
            : device.bonded,
        connected: false,
      );
    }

    // ------------------------------------------
    // 2. SCANNED DEVICES
    // ------------------------------------------

    for (final device in scanned) {
      final key = _key(device);
      final old = devices[key];

      devices[key] = device.copyWith(
        name: _bestName(device.name, old?.name),
        bonded: bondedKeys.contains(key),
        connected: false,
        rssi: device.rssi ?? old?.rssi,
        lastSeen: now,
      );
    }

    // ------------------------------------------
    // 3. ANDROID BONDED DEVICES
    // ------------------------------------------

    for (final device in bonded) {
      final key = _key(device);
      final old = devices[key];

      devices[key] = device.copyWith(
        name: _bestName(device.name, old?.name),
        bonded: true,
        connected: false,
        rssi: old?.rssi,
        lastSeen: old?.lastSeen,
      );
    }

    final result = _sort(devices.values.toList());

    await cache.saveAll(result);

    return result;
  }

  // ==========================================
  // NAME RESOLUTION
  // ==========================================

  String _bestName(
      String current,
      String? previous,
      ) {
    final name = current.trim();

    const genericNames = {
      '',
      'Sin nombre',
      'Bluetooth Device',
      'Dispositivo Bluetooth',
    };

    if (genericNames.contains(name) &&
        previous != null &&
        previous.trim().isNotEmpty &&
        !genericNames.contains(previous.trim())) {
      return previous;
    }

    return name.isEmpty
        ? 'Dispositivo Bluetooth'
        : name;
  }

  // ==========================================
  // SORT
  // ==========================================

  List<PrinterDevice> _sort(
      List<PrinterDevice> devices,
      ) {
    devices.sort((a, b) {
      if (a.bonded != b.bonded) {
        return a.bonded ? -1 : 1;
      }

      return a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
    });

    return devices;
  }
}
