import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cars_store/core/errors/app_failure.dart';
import 'package:cars_store/features/catalog/data/catalog_repository_impl.dart';
import 'package:cars_store/features/catalog/data/product_dto.dart';
import 'package:cars_store/features/catalog/data/product_remote_data_source.dart';
import 'package:cars_store/features/catalog/data/product_local_data_source.dart';
import 'package:cars_store/features/catalog/domain/catalog_repository.dart';

import 'support/fixtures.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockProductLocalDataSource extends Mock
    implements ProductLocalDataSource {}

void main() {
  late MockProductRemoteDataSource remote;
  late MockProductLocalDataSource local;
  late CatalogRepository repository;
  setUpAll(() {
    registerFallbackValue(<ProductDto>[]);
    registerFallbackValue(DateTime.utc(2026));
  });
  setUp(() {
    remote = MockProductRemoteDataSource();
    local = MockProductLocalDataSource();
    repository = CatalogRepositoryImpl(remote, local);
    when(() => local.write(any(), any())).thenAnswer((_) async {});
  });
  test('загрузка и кэширование', () async {
    when(() => remote.fetchProducts())
        .thenAnswer((_) async => [const ProductDto(product)]);
    final result = await repository.refresh();
    expect(result.products, [product]);
    expect(result.cacheWriteFailed, false);
    verify(() => local.write(any(), result.updatedAt)).called(1);
  });
  test('сохранение кэша при ошибке', () async {
    final cached = CatalogSnapshot(
      products: [product],
      updatedAt: DateTime.utc(2026),
    );
    when(() => local.read()).thenAnswer((_) async => cached);
    when(() => remote.fetchProducts())
        .thenThrow(const AppFailure(FailureKind.noConnection));
    await expectLater(
      repository.refresh(),
      throwsA(const AppFailure(FailureKind.noConnection)),
    );
    expect((await repository.readCache())!.products, [product]);
    verifyNever(() => local.write(any(), any()));
  });
  test('кэширование пустого ответа', () async {
    when(() => remote.fetchProducts()).thenAnswer((_) async => []);
    expect((await repository.refresh()).products, isEmpty);
    verify(() => local.write([], any())).called(1);
  });
}
