import '../domain/catalog_repository.dart';
import 'product_local_data_source.dart';
import 'product_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote, this._local);
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  @override
  Future<CatalogSnapshot?> readCache() async {
    try {
      return await _local.read();
    } catch (_) {
      // A corrupt or unavailable cache must not prevent a network request.
      return null;
    }
  }

  @override
  Future<CatalogSnapshot> refresh() async {
    final dtos = await _remote.fetchProducts();
    final updatedAt = DateTime.now().toUtc();
    var cacheWriteFailed = false;
    try {
      await _local.write(dtos, updatedAt);
    } catch (_) {
      cacheWriteFailed = true;
    }
    return CatalogSnapshot(
      products: dtos.map((dto) => dto.toDomain()).toList(),
      updatedAt: updatedAt,
      cacheWriteFailed: cacheWriteFailed,
    );
  }
}
