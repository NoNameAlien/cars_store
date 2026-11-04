import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cars_store/app/theme.dart';
import 'package:cars_store/core/errors/app_failure.dart';
import 'package:cars_store/features/catalog/domain/catalog_repository.dart';
import 'package:cars_store/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:cars_store/features/catalog/presentation/pages/catalog_page.dart';
import 'package:cars_store/features/catalog/presentation/widgets/catalog_feedback.dart';
import 'package:cars_store/features/catalog/presentation/widgets/product_card.dart';
import 'package:cars_store/features/cart/presentation/cubit/cart_cubit.dart';

import 'support/fixtures.dart';
import 'support/memory_cart_repository.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository repository;
  setUp(() {
    repository = MockCatalogRepository();
    when(() => repository.readCache()).thenAnswer((_) async => null);
  });
  Future<void> pumpCatalog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: createTheme(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CatalogCubit(repository)..load()),
            BlocProvider(
              create: (_) => CartCubit(MemoryCartRepository())..initialize(),
            ),
          ],
          child: const CatalogPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('каталог: загрузка', (tester) async {
    final pending = Completer<CatalogSnapshot>();
    when(() => repository.refresh()).thenAnswer((_) => pending.future);
    await pumpCatalog(tester);
    expect(find.byType(CatalogSkeleton), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(
      CatalogSnapshot(products: [], updatedAt: DateTime.utc(2026)),
    );
  });
  testWidgets('каталог: ошибка и повтор', (tester) async {
    when(() => repository.refresh())
        .thenThrow(const AppFailure(FailureKind.noConnection));
    await pumpCatalog(tester);
    expect(find.text('Каталог недоступен'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
    when(() => repository.refresh()).thenAnswer(
      (_) async =>
          CatalogSnapshot(products: [product], updatedAt: DateTime.utc(2026)),
    );
    await tester.tap(find.text('Повторить'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ProductCard), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('каталог: товар и цена', (tester) async {
    when(() => repository.refresh()).thenAnswer(
      (_) async =>
          CatalogSnapshot(products: [product], updatedAt: DateTime.utc(2026)),
    );
    await pumpCatalog(tester);
    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('\$109.95'), findsOneWidget);
    expect(find.text('Каталог недоступен'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
