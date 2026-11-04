import 'package:flutter_test/flutter_test.dart';
import 'package:cars_store/features/cart/presentation/cubit/cart_cubit.dart';

import 'support/fixtures.dart';
import 'support/memory_cart_repository.dart';

void main() {
  late CartCubit cubit;
  late MemoryCartRepository repository;
  setUp(() {
    repository = MemoryCartRepository();
    cubit = CartCubit(repository);
  });
  tearDown(() => cubit.close());
  test('повторное добавление', () async {
    await cubit.add(product);
    await cubit.add(product);
    expect(cubit.state.items, hasLength(1));
    expect(cubit.state.items.single.title, product.title);
    expect(cubit.state.quantityOf(product.id), 2);
    expect(repository.items, cubit.state.items);
  });
  test('удаление и уменьшение до нуля', () async {
    await cubit.add(product);
    await cubit.add(secondProduct);
    await cubit.remove(product.id);
    expect(cubit.state.items.single.productId, secondProduct.id);
    await cubit.decrement(secondProduct.id);
    expect(cubit.state.items, isEmpty);
    expect(repository.items, isEmpty);
  });
  test('сохранение быстрых изменений', () async {
    await cubit.add(product);
    await Future.wait(List.generate(10, (_) => cubit.increment(product.id)));
    await Future.wait(List.generate(3, (_) => cubit.decrement(product.id)));
    expect(cubit.state.quantityOf(product.id), 8);
    expect(repository.items, cubit.state.items);
  });
  test('пересчёт суммы в центах', () async {
    await cubit.add(product);
    await cubit.add(product);
    await cubit.add(secondProduct);
    await cubit.add(secondProduct);
    await cubit.add(secondProduct);
    expect(cubit.state.totalQuantity, 5);
    expect(cubit.state.totalCents, 10995 * 2 + 2230 * 3);
    await cubit.decrement(product.id);
    expect(cubit.state.totalCents, 10995 + 2230 * 3);
  });
}
