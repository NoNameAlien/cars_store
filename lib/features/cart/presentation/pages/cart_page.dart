import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/store_scaffold.dart';
import '../../../catalog/presentation/widgets/catalog_feedback.dart';
import '../../../catalog/presentation/widgets/product_card.dart';
import '../../domain/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) => StoreScaffold(
    showBackButton: true,
    hideCartButton: true,
    child: BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.status == CartStatus.initial ||
            state.status == CartStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == CartStatus.readError) {
          return CatalogFeedback(
            title: 'Корзина недоступна',
            message:
                'Не удалось прочитать сохранённые товары. Повторите загрузку.',
            buttonLabel: 'Повторить',
            onRetry: context.read<CartCubit>().initialize,
          );
        }
        if (state.items.isEmpty) {
          return CatalogFeedback(
            title: 'Ваша корзина пока пуста',
            message: 'Найдите что-нибудь для себя в каталоге и добавьте сюда.',
            buttonLabel: 'Перейти в каталог',
            onRetry: () => context.go(StoreRoutes.catalog),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1248),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ваша корзина',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.items.length} поз. · ${state.totalQuantity} шт.',
                    style: const TextStyle(color: StoreColors.muted),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final list = ListView.separated(
                          key: const PageStorageKey('cart-items'),
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) => CartItemTile(
                            key: ValueKey(state.items[index].productId),
                            item: state.items[index],
                          ),
                        );
                        final summary = CartSummary(state: state);
                        if (constraints.maxWidth >= 850) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: list),
                              const SizedBox(width: 28),
                              SizedBox(
                                width: 320,
                                child: SingleChildScrollView(child: summary),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Expanded(child: list),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight * .52,
                              ),
                              child: SingleChildScrollView(child: summary),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: StoreColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                height: 80,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const ImagePlaceholder(),
                  errorWidget: (_, _, _) =>
                      const ImagePlaceholder(failed: true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextButton(
                  style:
                      TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(48, 48),
                        alignment: Alignment.centerLeft,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) => states.contains(WidgetState.hovered)
                              ? Colors.transparent
                              : null,
                        ),
                      ),
                  onPressed: () =>
                      context.push(StoreRoutes.product(item.productId)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatUsd(item.unitPriceCents)} / шт.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                key: Key('cart-remove-${item.productId}'),
                tooltip: 'Удалить товар',
                onPressed: () => cubit.remove(item.productId),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: StoreColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('cart-minus-${item.productId}'),
                        tooltip: 'Уменьшить количество',
                        onPressed: () => cubit.decrement(item.productId),
                        icon: const Icon(Icons.remove_rounded, size: 18),
                      ),
                      Semantics(
                        label: 'Количество: ${item.quantity}',
                        child: Text(
                          '${item.quantity}',
                          key: Key('cart-quantity-${item.productId}'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        key: Key('cart-plus-${item.productId}'),
                        tooltip: 'Увеличить количество',
                        onPressed: item.quantity < CartItem.maxQuantity
                            ? () => cubit.increment(item.productId)
                            : null,
                        icon: const Icon(Icons.add_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatUsd(item.totalCents),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({super.key, required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: StoreColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text('Итого', style: Theme.of(context).textTheme.titleLarge),
            Text(
              formatUsd(state.totalCents),
              key: const Key('cart-total'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: StoreColors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${state.totalQuantity} шт. · USD',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state.isCheckingOut
              ? null
              : () => context.push(StoreRoutes.checkout),
          child: const Text('Оформить заказ'),
        ),
        const SizedBox(height: 8),
        Text(
          'Локальный заказ · без оплаты и доставки.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (state.isSaving) ...[
          const SizedBox(height: 6),
          Text(
            'Сохраняем изменения…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    ),
  );
}
