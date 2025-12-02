import '../models/user_registration_error_model.dart';

class UserRegistrationErrorViewModel {
  final List<UserRegistrationFieldError> errors;

  UserRegistrationErrorViewModel({required this.errors});

  factory UserRegistrationErrorViewModel.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'] as Map<String, dynamic>? ?? {};

    final parsedErrors = rawErrors.entries.map((entry) {
      final field = entry.key;
      final messages = (entry.value as List<dynamic>)
          .map((item) => item.toString())
          .toList();

      return UserRegistrationFieldError(field: field, messages: messages);
    }).toList();

    return UserRegistrationErrorViewModel(errors: parsedErrors);
  }

  /// Lista {campo, primer mensaje} lista para mostrar
  List<Map<String, String>> toDisplayList() {
    return errors.map((e) {
      final firstMessage = e.messages.isNotEmpty ? e.messages.first : 'Error desconocido';
      return {
        'field': e.field,
        'message': firstMessage,
      };
    }).toList();
  }

  /// Saber si un campo específico tiene errores
  bool hasErrorForField(String field) {
    return errors.any((e) => e.field == field && e.messages.isNotEmpty);
  }

  /// Obtener todos los mensajes de un campo
  List<String> getMessagesForField(String field) {
    return errors.firstWhere(
          (e) => e.field == field,
      orElse: () => UserRegistrationFieldError(field: field, messages: []),
    ).messages;
  }

  String generateGlobalMessage() {
    if (errors.isEmpty) {
      return 'Ocurrió un error desconocido.';
    }

    final List<String> messages = [];

    for (final error in errors) {
      final firstMessage = error.messages.isNotEmpty
          ? error.messages.first
          : 'Error en ${error.field}';

      messages.add('- ${_formatField(error.field)}: $firstMessage');
    }

    return messages.join('\n');
  }

  /// Formatea el nombre del campo para hacerlo legible
  String _formatField(String field) {
    switch (field) {
      case 'email':
        return 'Correo electrónico';
      case 'password':
        return 'Contraseña';
      case 'name':
        return 'Nombre';
      case 'last_name':
        return 'Apellido';
      default:
        return field[0].toUpperCase() + field.substring(1);
    }
  }
}
