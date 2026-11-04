import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../features/catalog/data/catalog_repository_impl.dart';
import '../features/catalog/data/product_local_data_source.dart';
import '../features/catalog/data/product_remote_data_source.dart';
import '../features/catalog/domain/catalog_repository.dart';
import '../features/cart/data/cart_repository_impl.dart';
import '../features/cart/domain/cart_repository.dart';

class AppDependencies {
  AppDependencies({
    CatalogRepository? catalogRepository,
    CartRepository? cartRepository,
  }) {
    dio = createApiClient();
    SharedPreferencesAsync? preferences;
    SharedPreferencesAsync storage() =>
        preferences ??= SharedPreferencesAsync();
    this.catalogRepository =
        catalogRepository ??
        CatalogRepositoryImpl(
          ProductRemoteDataSource(dio),
          ProductLocalDataSource(storage()),
        );
    this.cartRepository = cartRepository ?? CartRepositoryImpl(storage());
  }
  late final Dio dio;
  late final CatalogRepository catalogRepository;
  late final CartRepository cartRepository;
  void dispose() => dio.close(force: true);
}
