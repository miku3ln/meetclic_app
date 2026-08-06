class PrinterDevice {
  final String id;
  final String name;
  final String address;

  final bool bonded;
  final bool connected;

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.bonded,
    required this.connected,
  });
}

