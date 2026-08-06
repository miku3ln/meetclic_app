enum PrinterLanguage{
  escPos,
  tspl,
  cpcl,
  zpl,
  unknown,

}
enum PrinterConnection{
  bluetooth,
  usb,
  wifi,

}
class PrinterInfo {

  late final String id;

  late final String name;

  late final String address;

  late final PrinterLanguage language;

  late final PrinterConnection connection;

}
