const maxUnitPriceCents = 1000000000;

int apiPriceToCents(num value) {
  if (!value.isFinite || value < 0 || value > maxUnitPriceCents / 100) {
    throw const FormatException('Invalid price');
  }
  final match = RegExp(r'^(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?$')
      .firstMatch(value.toString());
  if (match == null) throw const FormatException('Invalid price');
  final fraction = match[2] ?? '';
  final digits = BigInt.parse('${match[1]}$fraction');
  final shift = 2 + int.parse(match[3] ?? '0') - fraction.length;
  final BigInt cents;
  if (shift >= 0) {
    cents = digits * BigInt.from(10).pow(shift);
  } else {
    final divisor = BigInt.from(10).pow(-shift);
    cents = (digits + divisor ~/ BigInt.two) ~/ divisor;
  }
  return cents.toInt();
}

String formatUsd(int cents) =>
    '\$${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

int? parsePriceInput(String text) {
  final value = text.trim().replaceAll(',', '.');
  if (value.isEmpty) return null;
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value)) {
    throw const FormatException(
      'Введите неотрицательную цену, до двух знаков после запятой',
    );
  }
  final parts = value.split('.');
  final dollars = int.tryParse(parts[0]);
  if (dollars == null || dollars > maxUnitPriceCents ~/ 100) {
    throw const FormatException('Цена слишком велика');
  }
  final cents =
      dollars * 100 +
      int.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0'));
  if (cents > maxUnitPriceCents) {
    throw const FormatException('Цена слишком велика');
  }
  return cents;
}

String priceInputValue(int? cents) => cents == null
    ? ''
    : '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
