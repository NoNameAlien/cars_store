import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/presentation/pages/catalog_page.dart';
import '../features/catalog/presentation/pages/product_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/checkout/presentation/checkout_page.dart';
import '../features/checkout/presentation/checkout_success_page.dart';

abstract final class StoreRoutes {
  static const catalog = '/';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const checkoutSuccess = '/checkout/success';
  static String product(int id) => '/products/$id';
}

GoRouter createRouter() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return GoRouter(
    routes: [
      GoRoute(
        path: StoreRoutes.catalog,
        builder: (_, _) => const CatalogPage(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (_, state) => ProductPage(
          productId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(path: StoreRoutes.cart, builder: (_, _) => const CartPage()),
      GoRoute(
        path: StoreRoutes.checkout,
        builder: (_, _) => const CheckoutPage(),
      ),
      GoRoute(
        path: StoreRoutes.checkoutSuccess,
        builder: (_, state) => CheckoutSuccessPage(
          orderNumber: state.extra is String ? state.extra as String : null,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Страница не найдена'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(StoreRoutes.catalog),
              child: const Text('В каталог'),
            ),
          ],
        ),
      ),
    ),
  );
}
