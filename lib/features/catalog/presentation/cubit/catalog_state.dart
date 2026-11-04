import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/product.dart';
import '../../domain/catalog_filter.dart';

enum CatalogConnection { unknown, offline, checking, online, unreachable }

enum CatalogStatus { initial, loading, success, empty, error }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.filter = const CatalogFilter(),
    this.isRefreshing = false,
    this.isFromCache = false,
    this.failure,
    this.updatedAt,
    this.cacheWriteFailed = false,
    this.connection = CatalogConnection.unknown,
  });
  final CatalogStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<String> categories;
  final CatalogFilter filter;
  final bool isRefreshing;
  final bool isFromCache;
  final AppFailure? failure;
  final DateTime? updatedAt;
  final bool cacheWriteFailed;
  final CatalogConnection connection;
  bool get hasCatalog =>
      status == CatalogStatus.success || status == CatalogStatus.empty;
  Product? productById(int id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    status,
    products,
    filteredProducts,
    categories,
    filter,
    isRefreshing,
    isFromCache,
    failure,
    updatedAt,
    cacheWriteFailed,
    connection,
  ];
}
