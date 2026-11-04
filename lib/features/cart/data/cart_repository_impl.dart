import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cart_item.dart';
import '../domain/cart_repository.dart';
import 'cart_item_dto.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const cacheKey = 'cart.v1';

  @override
  Future<List<CartItem>> read() async {
    final raw = await _preferences.getString(cacheKey);
    if (raw == null) return const [];
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> ||
          json['version'] != 1 ||
          json['items'] is! List) {
        throw const FormatException('Invalid cart');
      }
      final values = json['items'] as List;
      if (values.length > 1000) throw const FormatException('Cart too large');
      final items = values.map(CartItemDto.fromJson).toList(growable: false);
      if (items.map((item) => item.productId).toSet().length != items.length) {
        throw const FormatException('Duplicate cart IDs');
      }
      return List.unmodifiable(items);
    } on FormatException {
      throw const CorruptCartException();
    }
  }

  @override
  Future<void> save(List<CartItem> items) => _preferences.setString(
    cacheKey,
    jsonEncode({'version': 1, 'items': items.map(CartItemDto.toJson).toList()}),
  );
}
