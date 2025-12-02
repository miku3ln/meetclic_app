class Validators {
  static bool isValidDocument(String value) {
    return value.isNotEmpty && value.length >= 6;
  }

  static bool isValidAge(int age) {
    return age >= 0 && age <= 120;
  }
}
