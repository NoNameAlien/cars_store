import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/catalog_repository.dart';
import 'product_dto.dart';

class ProductLocalDataSource {
  ProductLocalDataSource(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const cacheKey = 'catalog.v1';

  Future<CatalogSnapshot?> read() async {
    final raw = await _preferences.getString(cacheKey);
    if (raw == null) return null;
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic> ||
        json['version'] != 1 ||
        json['updatedAt'] is! String) {
      throw const FormatException('Invalid catalog cache');
    }
    return CatalogSnapshot(
      products: parseProducts(json['products'])
          .map((dto) => dto.toDomain())
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Future<void> write(List<ProductDto> products, DateTime updatedAt) =>
      _preferences.setString(
        cacheKey,
        jsonEncode({
          'version': 1,
          'updatedAt': updatedAt.toUtc().toIso8601String(),
          'products': products.map((dto) => dto.toJson()).toList(),
        }),
      );
}
