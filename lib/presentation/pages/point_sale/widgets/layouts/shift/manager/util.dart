class UtilCashCommon {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> list(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  static int toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static double toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static String currency(dynamic value) {
    final double amount = toDouble(value);

    return '\$${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String movementLabel({
    required dynamic name,
    required int count,
  }) {
    final String movementName =
        name?.toString() ?? '';

    if (count <= 1) {
      return movementName;
    }

    return '$movementName ($count)';
  }
}