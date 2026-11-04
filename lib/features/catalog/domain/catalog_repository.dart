import 'product.dart';

class CatalogSnapshot {
  CatalogSnapshot({
    required List<Product> products,
    required this.updatedAt,
    this.cacheWriteFailed = false,
  }) : products = List.unmodifiable(products);
  final List<Product> products;
  final DateTime updatedAt;
  final bool cacheWriteFailed;
}

abstract interface class CatalogRepository {
  Future<CatalogSnapshot?> readCache();
  Future<CatalogSnapshot> refresh();
}
