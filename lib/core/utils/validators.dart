// lib/core/utils/validators.dart

String? validateUsername(String? value) {
  if (value == null || value.trim().length < 3) {
    return 'Mínimo 3 caracteres';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || !value.contains('@')) {
    return 'Email inválido';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 8) {
    return 'Mínimo 8 caracteres';
  }
  return null;
}

String? validateRequired(String? value, [String field = 'Campo']) {
  if (value == null || value.trim().isEmpty) return '$field es obligatorio';
  return null;
}

String? validatePositiveNumber(String? value, String field) {
  final num = double.tryParse(value ?? '');
  if (num == null || num <= 0) return '$field inválido';
  return null;
}

String? validateNonNegativeInt(String? value, String field) {
  final num = int.tryParse(value ?? '');
  if (num == null || num < 0) return '$field inválido';
  return null;
}