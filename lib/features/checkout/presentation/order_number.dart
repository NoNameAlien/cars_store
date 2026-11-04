import 'dart:math';

String createLocalOrderNumber() {
  final random = Random.secure();
  final suffix = List.generate(
    12,
    (_) => random.nextInt(16).toRadixString(16),
  ).join();
  return 'CS-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}-${suffix.toUpperCase()}';
}
