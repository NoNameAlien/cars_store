import 'cart_item.dart';

abstract interface class CartRepository {
  Future<List<CartItem>> read();
  Future<void> save(List<CartItem> items);
}

class CorruptCartException implements Exception {
  const CorruptCartException();
}
