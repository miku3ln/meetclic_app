import 'dart:convert';
import 'dart:typed_data';

class CpclPrinterProfile {
  final int dpi;
  final int printableWidthDots;
  final int leftMarginDots;
  final int rightMarginDots;
  final int topMarginDots;
  final int bottomMarginDots;
  final int normalFont;
  final int titleFont;
  final int normalCharWidthDots;
  final int normalLineHeightDots;
  final int titleLineHeightDots;
  final bool useForm;
  final int maxPageHeightDots;

  const CpclPrinterProfile({
    this.dpi = 203,
    required this.printableWidthDots,
    this.leftMarginDots = 8,
    this.rightMarginDots = 8,
    this.topMarginDots = 15,
    this.bottomMarginDots = 30,
    this.normalFont = 0,
    this.titleFont = 4,
    this.normalCharWidthDots = 12,
    this.normalLineHeightDots = 30,
    this.titleLineHeightDots = 55,
    this.useForm = true,
    this.maxPageHeightDots = 1600,
  }) : assert(printableWidthDots > leftMarginDots + rightMarginDots),
        assert(dpi > 0),
        assert(maxPageHeightDots > 0);

  static const model608L80D = CpclPrinterProfile(
    dpi: 203,
    printableWidthDots: 384,
    maxPageHeightDots: 1600,
  );

  static int mmToDots(double mm, int dpi) => (mm * dpi / 25.4).round();
}

class CpclReceiptItem {
  final String code;
  final String name;
  final int quantity;
  final int unitPriceCents;

  const CpclReceiptItem({
    required this.code,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
  });

  int get lineTotalCents => quantity * unitPriceCents;
}

class CpclReceiptData {
  final String businessName;
  final String businessCategory;
  final String address;
  final String phone;
  final String ticketNumber;
  final DateTime issuedAt;
  final List<CpclReceiptItem> items;
  final int? amountPaidCents;
  final String footer;

  const CpclReceiptData({
    required this.businessName,
    this.businessCategory = '',
    this.address = '',
    this.phone = '',
    required this.ticketNumber,
    required this.issuedAt,
    required this.items,
    this.amountPaidCents,
    this.footer = 'GRACIAS POR SU COMPRA',
  });
}

class CpclReceiptUtil {
  CpclReceiptUtil._();

  static Uint8List buildReceipt({
    required CpclPrinterProfile profile,
    required CpclReceiptData receipt,
  }) {
    if (receipt.items.isEmpty) {
      throw ArgumentError('El ticket debe tener al menos un producto.');
    }
    if (receipt.items.any((e) => e.quantity <= 0 || e.unitPriceCents < 0)) {
      throw ArgumentError('Cantidad o precio de producto invalido.');
    }
    final int subtotal = receipt.items.fold<int>(
      0, (sum, item) => sum + item.lineTotalCents,
    );
    final int total = subtotal;
    final paid = receipt.amountPaidCents;
    if (paid != null && paid < 0) {
      throw ArgumentError('El monto pagado no puede ser negativo.');
    }

    final left = profile.leftMarginDots;
    final right = profile.printableWidthDots - profile.rightMarginDots;
    final contentWidth = right - left;
    final charWidth = profile.normalCharWidthDots;
    final maxChars = contentWidth ~/ charWidth;
    if (maxChars < 16) {
      throw ArgumentError('Ancho imprimible insuficiente para el ticket.');
    }

    final commands = <String>[];
    int y = profile.topMarginDots;

    String safe(String value) => value
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '?')
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .trim();

    String money(int cents) {
      final sign = cents < 0 ? '-' : '';
      final abs = cents.abs();
      return '$sign\$${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
    }

    void rawText(String value, int x, int atY, {int? font}) {
      commands.add('TEXT ${font ?? profile.normalFont} 0 $x $atY ${safe(value)}');
    }

    void lineText(String value, {int? x, int? font, int? height}) {
      rawText(value, x ?? left, y, font: font);
      y += height ?? profile.normalLineHeightDots;
    }

    void centered(String value) {
      final width = safe(value).length * charWidth;
      final x = left + ((contentWidth - width) ~/ 2).clamp(0, contentWidth);
      lineText(value, x: x);
    }

    void wrapped(String value, {bool center = false}) {
      final words = safe(value).split(RegExp(r'\s+'));
      var current = '';
      for (final word in words) {
        if (word.isEmpty) continue;
        if (word.length > maxChars) {
          if (current.isNotEmpty) {
            center ? centered(current) : lineText(current);
            current = '';
          }
          for (var start = 0; start < word.length; start += maxChars) {
            final end = (start + maxChars).clamp(0, word.length);
            final chunk = word.substring(start, end);
            center ? centered(chunk) : lineText(chunk);
          }
        } else if (current.isEmpty) {
          current = word;
        } else if ('$current $word'.length <= maxChars) {
          current = '$current $word';
        } else {
          center ? centered(current) : lineText(current);
          current = word;
        }
      }
      if (current.isNotEmpty) {
        center ? centered(current) : lineText(current);
      }
    }

    void separator() {
      y += 4;
      commands.add('LINE $left $y $right $y 2');
      y += 14;
    }

    void row(String label, String amount) {
      final amountChars = amount.length;
      final availableLabelChars = maxChars - amountChars - 1;
      if (availableLabelChars < 1) {
        throw ArgumentError('No hay espacio para las columnas.');
      }
      final cleanLabel = safe(label);
      final shortLabel = cleanLabel.length > availableLabelChars
          ? cleanLabel.substring(0, availableLabelChars)
          : cleanLabel;
      rawText(shortLabel, left, y);
      rawText(amount, right - amountChars * charWidth, y);
      y += profile.normalLineHeightDots;
    }

    final title = safe(receipt.businessName);
    // La fuente 4 tiene métricas dependientes del firmware.
    // Se utiliza fuente 0 para un centrado predecible.
    wrapped(title, center: true);
    if (receipt.businessCategory.isNotEmpty) {
      wrapped(receipt.businessCategory, center: true);
    }
    if (receipt.address.isNotEmpty) wrapped(receipt.address, center: true);
    if (receipt.phone.isNotEmpty) wrapped('TEL: ${receipt.phone}', center: true);
    separator();

    String two(int n) => n.toString().padLeft(2, '0');
    lineText('TICKET: ${receipt.ticketNumber}');
    lineText('FECHA: ${two(receipt.issuedAt.day)}/${two(receipt.issuedAt.month)}/${receipt.issuedAt.year}');
    lineText('HORA: ${two(receipt.issuedAt.hour)}:${two(receipt.issuedAt.minute)}');
    separator();

    lineText('COD / PRODUCTO');
    separator();

    for (final item in receipt.items) {
      wrapped('${item.code} ${item.name}');
      row('${item.quantity} x ${money(item.unitPriceCents)}', money(item.lineTotalCents));
    }
    separator();
    row('SUBTOTAL', money(subtotal));
    separator();
    row('TOTAL', money(total));
    if (paid != null) {
      row('EFECTIVO', money(paid));
      row('CAMBIO', money(paid - total));
    }
    separator();
    wrapped(receipt.footer, center: true);
    centered('YAPITA POS');
    y += profile.bottomMarginDots;

    if (y > profile.maxPageHeightDots) {
      throw StateError('Ticket de $y puntos supera el maximo de ${profile.maxPageHeightDots}. Dividir en paginas o configurar otro limite.');
    }

    final cpcl = <String>[
      '! 0 200 200 $y 1',
      'PAGE-WIDTH ${profile.printableWidthDots}',
      ...commands,
      if (profile.useForm) 'FORM',
      'PRINT',
    ].join('\r\n') + '\r\n';

    return Uint8List.fromList(ascii.encode(cpcl));
  }
}
