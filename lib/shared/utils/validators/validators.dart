typedef Validator<T> = String? Function(T value);
class ValidatorsUtil {
  ValidatorsUtil._();

  /// =========================
  /// 🔴 REQUIRED (STRING)
  /// =========================
  static Validator<String?> required([String field = "Campo"]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return "$field requerido";
      }
      return null;
    };
  }

  /// =========================
  /// 🔤 ALPHANUMERIC
  /// =========================
  static Validator<String?> alphanumeric(
      [String message = "Solo letras y números"]) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) return message;
      return null;
    };
  }

  /// =========================
  /// 🔢 NUMBER (STRING → DOUBLE)
  /// =========================
  static Validator<String?> number(
      [String message = "Número inválido"]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (double.tryParse(value) == null) return message;
      return null;
    };
  }

  /// =========================
  /// 🔢 POSITIVE (STRING)
  /// =========================
  static Validator<String?> positive(
      [String message = "Debe ser mayor a 0"]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final n = double.tryParse(value);
      if (n == null || n <= 0) return message;
      return null;
    };
  }

  /// =========================
  /// 🔢 NON NEGATIVE (STRING)
  /// =========================
  static Validator<String?> nonNegative(
      [String message = "No puede ser negativo"]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final n = double.tryParse(value);
      if (n == null || n < 0) return message;
      return null;
    };
  }

  /// =========================
  /// 🔢 POSITIVE DOUBLE
  /// =========================
  static Validator<double?> positiveDouble([String field = "Campo"]) {
    return (value) {
      if (value == null) return "$field requerido";
      if (value <= 0) return "$field debe ser mayor a 0";
      return null;
    };
  }

  /// =========================
  /// 🔢 NON NEGATIVE DOUBLE
  /// =========================
  static Validator<double?> nonNegativeDouble([String field = "Campo"]) {
    return (value) {
      if (value == null) return "$field requerido";
      if (value < 0) return "$field no puede ser negativo";
      return null;
    };
  }

  /// =========================
  /// 📏 MIN LENGTH
  /// =========================
  static Validator<String?> minLength(int length,
      [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < length) {
        return message ?? "Mínimo $length caracteres";
      }
      return null;
    };
  }

  /// =========================
  /// 📏 MAX LENGTH
  /// =========================
  static Validator<String?> maxLength(int length,
      [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > length) {
        return message ?? "Máximo $length caracteres";
      }
      return null;
    };
  }

  /// =========================
  /// 📧 EMAIL
  /// =========================
  static Validator<String?> email(
      [String message = "Email inválido"]) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) return message;
      return null;
    };
  }

  /// =========================
  /// 🔗 CUSTOM REGEX
  /// =========================
  static Validator<String?> regex(
      RegExp regex, String message) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) return message;
      return null;
    };
  }

  /// =========================
  /// 🧠 COMPOSE
  /// =========================
  static Validator<T> compose<T>(List<Validator<T>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// =========================
  /// 🚀 EXECUTOR (🔥 CLAVE)
  /// =========================
  static String? validate<T>(
      T value,
      List<Validator<T>> validators,
      ) {
    return compose(validators)(value);
  }
}