import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/store_scaffold.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../domain/product.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../widgets/catalog_feedback.dart';
import '../widgets/product_card.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.productId});
  final int? productId;

  @override
  Widget build(BuildContext context) => StoreScaffold(
    showBackButton: true,
    child: BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final product = productId == null
            ? null
            : state.productById(productId!);
        if (product == null) {
          if (productId != null && productId! > 0) {
            if (state.status == CatalogStatus.initial ||
                state.status == CatalogStatus.loading ||
                state.isRefreshing) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null) {
              return CatalogFeedback(
                title: 'Товар пока недоступен',
                message:
                    'Товара нет в сохранённом каталоге. ${failureMessage(state.failure!)}',
                buttonLabel: 'Повторить',
                onRetry: context.read<CatalogCubit>().refresh,
              );
            }
          }
          return CatalogFeedback(
            title: 'Товар не найден',
            message: 'Возможно, он больше не представлен в каталоге.',
            buttonLabel: 'В каталог',
            onRetry: () => context.go(StoreRoutes.catalog),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.isFromCache ||
                      state.failure != null ||
                      state.cacheWriteFailed)
                    CatalogNotice(state: state),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final image = Container(
                        padding: EdgeInsets.all(
                          constraints.maxWidth >= 800 ? 32 : 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: StoreColors.border),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: AspectRatio(
                          aspectRatio: constraints.maxWidth >= 800 ? 1.1 : 1.4,
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const ImagePlaceholder(),
                            errorWidget: (_, _, _) =>
                                const ImagePlaceholder(failed: true),
                          ),
                        ),
                      );
                      final info = _ProductInfo(product: product);
                      return constraints.maxWidth >= 800
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: image),
                                const SizedBox(width: 48),
                                Expanded(child: info),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                image,
                                const SizedBox(height: 20),
                                info,
                              ],
                            );
                    },
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

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        categoryLabel(product.category),
        style: const TextStyle(
          color: StoreColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        product.title,
        style: Theme.of(context).textTheme.headlineLarge
            ?.copyWith(fontSize: 30, height: 1.2),
      ),
      if (product.rating != null || product.ratingCount != null) ...[
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFE7AD3D), size: 23),
            if (product.rating != null)
              Text(
                '${product.rating!.toStringAsFixed(1)} / 5',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (product.ratingCount != null)
              Text(
                'Оценок: ${product.ratingCount}',
                style: const TextStyle(color: StoreColors.muted),
              ),
          ],
        ),
      ],
      const SizedBox(height: 24),
      Text(
        formatUsd(product.unitPriceCents),
        style: Theme.of(context).textTheme.headlineLarge
            ?.copyWith(fontSize: 36),
      ),
      const SizedBox(height: 8),
      const Text(
        'Цена в USD',
        style: TextStyle(color: StoreColors.muted, fontSize: 12),
      ),
      const SizedBox(height: 24),
      _CartActions(product: product),
      const SizedBox(height: 28),
      const Divider(color: StoreColors.border),
      const SizedBox(height: 20),
      Text('О товаре', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Text(
        product.description.isEmpty
            ? 'Описание отсутствует в сохранённых данных. Обновите каталог при наличии сети.'
            : product.description,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(height: 1.7, color: StoreColors.muted),
      ),
    ],
  );
}

class _CartActions extends StatelessWidget {
  const _CartActions({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartCubit, CartState, (CartStatus, int)>(
        selector: (state) => (state.status, state.quantityOf(product.id)),
        builder: (context, selected) {
          final (status, quantity) = selected;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (quantity > 0) ...[
                Text(
                  'В корзине: $quantity шт.',
                  key: const Key('product-cart-quantity'),
                  style: const TextStyle(
                    color: StoreColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    key: const Key('add-to-cart'),
                    onPressed:
                        status == CartStatus.ready &&
                            quantity < CartItem.maxQuantity
                        ? () => context.read<CartCubit>().add(product)
                        : null,
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: Text(
                      status != CartStatus.ready
                          ? 'Корзина недоступна'
                          : quantity >= CartItem.maxQuantity
                          ? 'Достигнут лимит 999 шт.'
                          : quantity > 0
                          ? 'Добавить ещё'
                          : 'В корзину',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push(StoreRoutes.cart),
                    child: const Text('Перейти в корзину'),
                  ),
                ],
              ),
            ],
          );
        },
      );
}
