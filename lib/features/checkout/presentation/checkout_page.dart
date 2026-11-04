import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../../core/widgets/store_scaffold.dart';
import '../../cart/presentation/cubit/cart_cubit.dart';
import '../../cart/presentation/cubit/cart_state.dart';
import '../../catalog/presentation/widgets/catalog_feedback.dart';
import 'checkout_validation.dart';
import 'order_number.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _form = GlobalKey<FormState>();
  final _fields = List.generate(4, (_) => GlobalKey<FormFieldState<String>>());
  void _revalidateField(int index) {
    final field = _fields[index].currentState;
    if (field?.hasError ?? false) field!.validate();
  }

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _valid = false;
  bool _submitting = false;
  String? _error;

  void _changed() {
    final valid =
        validateName(_name.text) == null &&
        validateEmail(_email.text) == null &&
        validatePhone(_phone.text) == null &&
        validateAddress(_address.text) == null;
    if (_valid != valid || _error != null) {
      setState(() {
        _valid = valid;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting || !_form.currentState!.validate()) {
      return;
    }
    final cart = context.read<CartCubit>();
    if (cart.state.status != CartStatus.ready ||
        cart.state.items.isEmpty ||
        cart.state.isCheckingOut) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final number = createLocalOrderNumber();
      final saved = await cart.clearForCheckout();
      if (!mounted) {
        return;
      }
      if (saved) {
        context.go(StoreRoutes.checkoutSuccess, extra: number);
        return;
      }
      setState(() {
        _submitting = false;
        _error = cart.state.issue == CartIssue.writeFailed
            ? 'Не удалось сохранить оформление. Корзина сохранена на экране. Попробуйте ещё раз.'
            : 'Корзина недоступна или изменилась. Проверьте товары и повторите оформление.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Не удалось оформить заказ. Попробуйте ещё раз.';
        });
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_submitting,
    child: StoreScaffold(
      showBackButton: true,
      hideCartButton: true,
      navigationLocked: _submitting,
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.initial ||
              state.status == CartStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CartStatus.readError) {
            return CatalogFeedback(
              title: 'Корзина недоступна',
              message: 'Повторите загрузку корзины перед оформлением.',
              buttonLabel: 'Повторить',
              onRetry: context.read<CartCubit>().initialize,
            );
          }
          if (state.items.isEmpty && !_submitting) {
            return CatalogFeedback(
              title: 'Нет товаров для оформления',
              message: 'Сначала добавьте товары в корзину.',
              buttonLabel: 'В каталог',
              onRetry: () => context.go(StoreRoutes.catalog),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Оформление заказа',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Локальный учебный заказ. Оплата и отправка данных на сервер не выполняются.',
                      style: TextStyle(color: StoreColors.muted),
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final form = _buildForm(context, state);
                        final summary = _CheckoutSummary(state: state);
                        if (constraints.maxWidth >= 850) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: form),
                              const SizedBox(width: 28),
                              SizedBox(width: 320, child: summary),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [summary, const SizedBox(height: 24), form],
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
    ),
  );

  Widget _buildForm(BuildContext context, CartState cart) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: StoreColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: AutofillGroup(
      child: Form(
        key: _form,
        onChanged: _changed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Контактные данные',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: _fields[0],
              autovalidateMode: AutovalidateMode.onUnfocus,
              onChanged: (_) => _revalidateField(0),
              controller: _name,
              enabled: !_submitting,
              validator: validateName,
              autofillHints: const [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: _fields[1],
              autovalidateMode: AutovalidateMode.onUnfocus,
              onChanged: (_) => _revalidateField(1),
              controller: _email,
              enabled: !_submitting,
              validator: validateEmail,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: _fields[2],
              autovalidateMode: AutovalidateMode.onUnfocus,
              onChanged: (_) => _revalidateField(2),
              controller: _phone,
              enabled: !_submitting,
              validator: validatePhone,
              autofillHints: const [AutofillHints.telephoneNumber],
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                hintText: '+7 (999) 999-99-99',
                helperText:
                    'От 10 до 15 цифр; пробелы, +, скобки и дефисы допустимы.',
                helperMaxLines: 3,
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: _fields[3],
              autovalidateMode: AutovalidateMode.onUnfocus,
              onChanged: (_) => _revalidateField(3),
              controller: _address,
              enabled: !_submitting,
              validator: validateAddress,
              autofillHints: const [AutofillHints.fullStreetAddress],
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (_valid) _submit();
              },
              decoration: const InputDecoration(
                labelText: 'Адрес',
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed:
                  _valid &&
                      !_submitting &&
                      !cart.isCheckingOut &&
                      cart.items.isNotEmpty
                  ? _submit
                  : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_submitting ? 'Оформляем…' : 'Оформить'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: StoreColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Ваш заказ', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final item in state.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} шт. · ${formatUsd(item.totalCents)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        const Divider(color: StoreColors.border),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text('Итого', style: Theme.of(context).textTheme.titleLarge),
            Text(
              formatUsd(state.totalCents),
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: StoreColors.ink),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${state.totalQuantity} шт. · USD',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
