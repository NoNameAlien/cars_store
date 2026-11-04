String? validateName(String? value) =>
    (value ?? '').trim().isEmpty ? 'Введите имя' : null;

String? validateAddress(String? value) =>
    (value ?? '').trim().isEmpty ? 'Введите адрес' : null;

String? validateEmail(String? input) {
  final value = (input ?? '').trim();
  if (value.isEmpty) {
    return 'Введите email';
  }
  final parts = value.split('@');
  if (parts.length != 2 ||
      value.length > 254 ||
      parts[0].length > 64 ||
      parts[0].isEmpty ||
      parts[0].startsWith('.') ||
      parts[0].endsWith('.') ||
      parts[0].contains('..')) {
    return 'Введите корректный email';
  }
  final local = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$");
  final domain = parts[1];
  final labels = domain.split('.');
  final validLabel = RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$');
  if (!local.hasMatch(parts[0]) ||
      domain.length > 253 ||
      labels.length < 2 ||
      labels.any((label) => label.length > 63 || !validLabel.hasMatch(label)) ||
      !RegExp(r'^[a-zA-Z]{2,}$').hasMatch(labels.last)) {
    return 'Введите корректный email';
  }
  return null;
}

String? validatePhone(String? input) {
  final value = (input ?? '').trim();
  if (value.isEmpty) {
    return 'Введите телефон';
  }
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (!RegExp(r'^[0-9+()\s-]+$').hasMatch(value) ||
      digits.length < 10 ||
      digits.length > 15) {
    return 'Введите от 10 до 15 цифр';
  }
  return null;
}
