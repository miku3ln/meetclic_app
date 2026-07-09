
import 'package:flutter/cupertino.dart';
typedef Validator<T> = String? Function(T value);
enum CrudType { create, update }
class ValidationResult {
  final bool success;
  final Map<String, String?> errors;
  final String message;

  ValidationResult({
    required this.success,
    required this.errors,
    required this.message,
  });
}
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


class FieldState<T> {
  T? value;
  bool touched;
  String? error;
  final String label;

  FieldState({
    required this.label,
    this.value,
    this.touched = false,
    this.error,
  });

  bool get isValid => error == null;


  String text = '';
}

class FormFieldController<T> extends ChangeNotifier {
  T? value;
  bool touched = false;
  String? error;

  final String label;
  final List<Validator<T?>> validators;

  FormFieldController({
    required this.label,
    this.value,
    this.validators = const [],
  });

  void setValue(T? newValue) {
    value = newValue;
    touched = true;
    validate();

  }

  bool validate() {
    error = ValidatorsUtil.validate<T?>(value, validators);

    return error == null;
  }

  bool get isValid => error == null;


}

abstract class BaseFormController extends ChangeNotifier {
  final Map<String, dynamic> fields = {};
  bool validate() {
    bool valid = true;
    for (final field in fields.values) {
      if (field is FormFieldController) {
        valid = field.validate() && valid;
      }
    }
    notifyListeners();
    return valid;
  }

  bool get isValid {
    return fields.values.every(
          (field) => field is FormFieldController ? field.error == null : true,
    );
  }
  T field<T>(String key) {
    return fields[key] as T;
  }

  /// Limpia únicamente los valores
  void clearValues() {
    for (final field in fields.values) {
      if (field is FormFieldController) {
        field.value = null;
      }
    }

    notifyListeners();
  }

  /// Limpia únicamente los errores
  void clearErrors() {
    for (final field in fields.values) {
      if (field is FormFieldController) {
        field.error = null;
      }
    }

    notifyListeners();
  }

  /// Limpia únicamente touched
  void clearTouched() {
    for (final field in fields.values) {
      if (field is FormFieldController) {
        field.touched = false;
      }
    }

    notifyListeners();
  }

  bool get areAllFieldsTouched {
    for (final field in fields.values) {
      if (field is FormFieldController && !field.touched) {
        return false;
      }
    }
    return true;
  }
  /// Reinicia completamente el formulario
  void resetForm() {
    for (final field in fields.values) {
      if (field is FormFieldController) {
        field.value = null;
        field.error = null;
        field.touched = false;
      }
    }

    notifyListeners();
  }
  ValidationResult validateFields() {
    final success = validate();

    final errors = <String, String?>{};

    fields.forEach((key, field) {
      if (field is FormFieldController) {
        errors[key] = field.error;
      }
    });

    return ValidationResult(
      success: success,
      errors: errors,
      message: success
          ? "Formulario válido"
          : "Formulario inválido",
    );
  }
}
void _setTextField(
    FormFieldController<String> field,
    String value,
    ) {
  field.setValue(value);
}
double _parseDouble(String value, {
  double defaultValue = 0,
}) {
  return double.tryParse(value) ?? defaultValue;
}
String formatInput(num? value) {
  if (value == null) return '';

  if (value == value.toInt()) {
    return value.toInt().toString();
  }

  return value.toString();
}