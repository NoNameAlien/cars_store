import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/store_scaffold.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key, required this.orderNumber});
  final String? orderNumber;

  @override
  Widget build(BuildContext context) => StoreScaffold(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: StoreColors.border),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  orderNumber == null
                      ? Icons.receipt_long_outlined
                      : Icons.check_circle_outline_rounded,
                  size: 72,
                  color: StoreColors.accent,
                ),
                const SizedBox(height: 24),
                Text(
                  orderNumber == null
                      ? 'Нет данных о заказе'
                      : 'Заказ оформлен',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (orderNumber != null) ...[
                  const Text(
                    'Номер локального заказа',
                    style: TextStyle(color: StoreColors.muted),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    orderNumber!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: StoreColors.accent),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  orderNumber == null
                      ? 'Подтверждение доступно сразу после оформления. История заказов не сохраняется.'
                      : 'Оформление завершено на этом устройстве. Корзина очищена. Это учебный заказ без оплаты и доставки.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: StoreColors.muted, height: 1.5),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => context.go(StoreRoutes.catalog),
                  child: const Text('Вернуться в каталог'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
