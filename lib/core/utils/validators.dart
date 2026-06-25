class Validators {
  static String? requiredField(
    String? value, {
    String fieldName = 'Trường này',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
}
