class UserRegistrationFieldError {
  final String field;
  final List<String> messages;

  UserRegistrationFieldError({
    required this.field,
    required this.messages,
  });
}
