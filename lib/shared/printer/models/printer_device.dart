
enum PrinterBluetoothType {
  classic,
  ble,
  unknown,
}

class PrinterDevice {
  final String id;
  final String name;
  final String address;
  final bool bonded;
  final bool connected;
  final PrinterBluetoothType bluetoothType;
  final int? rssi;
  final int? deviceClass;
  final DateTime? lastSeen;

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.address,
    this.bonded = false,
    this.connected = false,
    this.bluetoothType = PrinterBluetoothType.unknown,
    this.rssi,
    this.deviceClass,
    this.lastSeen,
  });

  PrinterDevice copyWith({
    String? name,
    bool? bonded,
    bool? connected,
    PrinterBluetoothType? bluetoothType,
    int? rssi,
    int? deviceClass,
    DateTime? lastSeen,
  }) {
    return PrinterDevice(
      id: id,
      name: name ?? this.name,
      address: address,
      bonded: bonded ?? this.bonded,
      connected: connected ?? this.connected,
      bluetoothType: bluetoothType ?? this.bluetoothType,
      rssi: rssi ?? this.rssi,
      deviceClass: deviceClass ?? this.deviceClass,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }


  factory PrinterDevice.fromJson(Map<String, dynamic> json) {
    final address = (json['address'] ?? json['id'])
        ?.toString()
        .trim();

    if (address == null || address.isEmpty) {
      throw const FormatException(
        'El dispositivo no tiene una dirección válida.',
      );
    }

    final id = json['id']?.toString().trim();

    final bluetoothTypeValue =
    json['bluetoothType']?.toString().toLowerCase();

    return PrinterDevice(
      id: id == null || id.isEmpty ? address : id,
      name: json['name']?.toString() ?? 'Sin nombre',
      address: address,
      bonded: json['bonded'] == true,
      connected: json['connected'] == true,
      bluetoothType: PrinterBluetoothType.values.firstWhere(
            (type) => type.name == bluetoothTypeValue,
        orElse: () => PrinterBluetoothType.unknown,
      ),
      rssi: json['rssi'] is num
          ? (json['rssi'] as num).toInt()
          : null,
      deviceClass: json['deviceClass'] is num
          ? (json['deviceClass'] as num).toInt()
          : null,
      lastSeen: DateTime.tryParse(
        json['lastSeen']?.toString() ?? '',
      ),
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'bonded': bonded,
    'connected': connected,
    'bluetoothType': bluetoothType.name,
    'rssi': rssi,
    'deviceClass': deviceClass,
    'lastSeen': lastSeen?.toIso8601String(),
  };
}
