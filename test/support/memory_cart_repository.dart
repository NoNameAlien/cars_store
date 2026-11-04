import 'package:cars_store/features/cart/domain/cart_repository.dart';
import 'package:cars_store/features/cart/domain/cart_item.dart';

class MemoryCartRepository implements CartRepository {
  List<CartItem> items = [];

  @override
  Future<List<CartItem>> read() async => List.of(items);

  @override
  Future<void> save(List<CartItem> value) async {
    items = List.of(value);
  }
}
