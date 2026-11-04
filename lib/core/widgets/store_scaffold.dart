import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import 'catalog_connection_notice.dart';
import '../../app/theme.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/cart_state.dart';

class StoreScaffold extends StatelessWidget {
  const StoreScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.hideCartButton = false,
    this.navigationLocked = false,
  });
  final bool navigationLocked;
  final Widget child;
  final bool showBackButton;
  final bool hideCartButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          IgnorePointer(
            ignoring: navigationLocked,
            child: StoreHeader(
              showBackButton: showBackButton,
              hideCartButton: hideCartButton,
            ),
          ),
          const CatalogConnectionNotice(),
          const CartStorageNotice(),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class StoreHeader extends StatelessWidget {
  const StoreHeader({
    super.key,
    this.showBackButton = false,
    this.hideCartButton = false,
  });
  final bool showBackButton;
  final bool hideCartButton;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: StoreColors.border)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1248),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  tooltip: 'Назад',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(StoreRoutes.catalog);
                    }
                  },
                ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go(StoreRoutes.catalog),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: StoreColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_mosaic_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'cars store',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(letterSpacing: -.7),
                ),
              ),
              if (!hideCartButton) const CartButton(),
            ],
          ),
        ),
      ),
    ),
  );
}

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) => BlocSelector<CartCubit, CartState, int>(
    selector: (state) => state.totalQuantity,
    builder: (context, quantity) => Semantics(
      button: true,
      label: 'Корзина, $quantity товаров',
      excludeSemantics: true,
      onTap: () => context.push(StoreRoutes.cart),
      child: IconButton(
        key: const Key('open-cart'),
        tooltip: 'Корзина, $quantity товаров',
        onPressed: () => context.push(StoreRoutes.cart),
        icon: Badge(
          isLabelVisible: quantity > 0,
          label: Text(quantity > 99 ? '99+' : '$quantity'),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: StoreColors.ink,
          ),
        ),
      ),
    ),
  );
}

class CartStorageNotice extends StatelessWidget {
  const CartStorageNotice({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartCubit, CartState, CartIssue?>(
        selector: (state) => state.issue,
        builder: (context, issue) {
          if (issue == null) return const SizedBox.shrink();
          final cubit = context.read<CartCubit>();
          final text = switch (issue) {
            CartIssue.readFailed => 'Не удалось прочитать корзину. Изменения недоступны до повторной загрузки.',
            CartIssue.corruptData => 'Сохранённая корзина повреждена. Добавление товаров создаст новую корзину.',
            CartIssue.writeFailed =>
              'Корзина не сохранена. Изменения пока доступны только в памяти.',
          };
          return Container(
            width: double.infinity,
            color: const Color(0xFFFFF4DE),
            constraints: const BoxConstraints(maxHeight: 180),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  Text(text, style: const TextStyle(color: Color(0xFF795719))),
                  if (issue != CartIssue.corruptData)
                    TextButton(
                      onPressed: issue == CartIssue.readFailed
                          ? cubit.initialize
                          : cubit.retrySave,
                      child: const Text('Повторить'),
                    ),
                ],
              ),
            ),
          );
        },
      );
}
