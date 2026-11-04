import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/money.dart';
import '../../domain/catalog_filter.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import 'product_card.dart';

class CatalogFilters extends StatefulWidget {
  const CatalogFilters({
    super.key,
    this.onApplied,
    this.applyImmediately = true,
  });
  final VoidCallback? onApplied;
  final bool applyImmediately;

  @override
  State<CatalogFilters> createState() => _CatalogFiltersState();
}

class _CatalogFiltersState extends State<CatalogFilters> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _min;
  late final TextEditingController _max;
  final _minFocus = FocusNode();
  final _maxFocus = FocusNode();
  String? _rangeError;
  String? _category;
  late CatalogFilter _applied;

  @override
  void initState() {
    super.initState();
    _applied = context.read<CatalogCubit>().state.filter;
    _minFocus.addListener(() => _onPriceFocusChanged(_minFocus));
    _maxFocus.addListener(() => _onPriceFocusChanged(_maxFocus));
    _category = _applied.category;
    _min = TextEditingController(text: priceInputValue(_applied.minPriceCents));
    _max = TextEditingController(text: priceInputValue(_applied.maxPriceCents));
  }

  @override
  void dispose() {
    _minFocus.dispose();
    _maxFocus.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _sync(CatalogFilter filter) {
    _applied = filter;
    setState(() {
      _rangeError = null;
      _category = filter.category;
      _min.text = priceInputValue(filter.minPriceCents);
      _max.text = priceInputValue(filter.maxPriceCents);
    });
    _form.currentState?.validate();
  }

  String? _validate(String? value) {
    try {
      parsePriceInput(value ?? '');
      return null;
    } on FormatException catch (error) {
      return error.message;
    }
  }

  void _onPriceFocusChanged(FocusNode focus) {
    if (widget.applyImmediately && !focus.hasFocus) _apply();
  }

  void _selectCategory(String? category) {
    setState(() => _category = category);
    if (widget.applyImmediately) {
      _commit(
        CatalogFilter(
          category: category,
          minPriceCents: _applied.minPriceCents,
          maxPriceCents: _applied.maxPriceCents,
        ),
      );
    }
  }

  void _commit(CatalogFilter filter) {
    _applied = filter;
    context.read<CatalogCubit>().applyFilter(filter);
  }

  void _apply() {
    final form = _form.currentState;
    if (!mounted || form == null) return;
    final fieldsValid = form.validate();
    final min = fieldsValid ? parsePriceInput(_min.text) : null;
    final max = fieldsValid ? parsePriceInput(_max.text) : null;
    final invalidRange = min != null && max != null && min > max;
    setState(
      () => _rangeError = invalidRange
          ? 'Минимальная цена не должна превышать максимальную'
          : null,
    );
    if (!fieldsValid || invalidRange) return;
    _commit(
      CatalogFilter(
        category: _category,
        minPriceCents: min,
        maxPriceCents: max,
      ),
    );
    widget.onApplied?.call();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<CatalogCubit, CatalogState>(
    listenWhen: (previous, current) => previous.filter != current.filter,
    listener: (_, state) {
      if (widget.applyImmediately && state.filter != _applied) {
        _sync(state.filter);
      }
    },
    child: BlocBuilder<CatalogCubit, CatalogState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories,
      builder: (context, state) => Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Фильтры',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.applyImmediately) {
                      context.read<CatalogCubit>().resetFilters();
                    }
                    _sync(const CatalogFilter());
                  },
                  child: const Text('Сбросить'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Категория', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  showCheckmark: false,
                  label: const Text('Все категории'),
                  selected: _category == null,
                  onSelected: (_) => _selectCategory(null),
                ),
                for (final category in state.categories)
                  ChoiceChip(
                    showCheckmark: false,
                    label: Text(categoryLabel(category)),
                    selected: _category == category,
                    onSelected: (_) => _selectCategory(category),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Цена, USD', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('min-price'),
              controller: _min,
              focusNode: _minFocus,
              onFieldSubmitted: widget.applyImmediately
                  ? (_) => _apply()
                  : null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validate,
              decoration: const InputDecoration(
                labelText: 'Цена от',
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('max-price'),
              controller: _max,
              focusNode: _maxFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validate,
              onFieldSubmitted: widget.applyImmediately
                  ? (_) => _apply()
                  : null,
              decoration: const InputDecoration(
                labelText: 'Цена до',
                border: OutlineInputBorder(),
                errorMaxLines: 3,
              ),
            ),
            if (_rangeError != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _rangeError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('apply-filters'),
                onPressed: _apply,
                child: const Text('Показать товары'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Фильтры применяются к загруженному каталогу.',
              style: TextStyle(fontSize: 12, color: StoreColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class FilterSummary extends StatelessWidget {
  const FilterSummary({
    super.key,
    required this.state,
    required this.showFilterButton,
  });
  final CatalogState state;
  final bool showFilterButton;

  @override
  Widget build(BuildContext context) {
    final filter = state.filter;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (showFilterButton)
            OutlinedButton.icon(
              key: const Key('open-filters'),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Фильтры'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                builder: (sheetContext) => BlocProvider.value(
                  value: context.read<CatalogCubit>(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: CatalogFilters(
                        applyImmediately: false,
                        onApplied: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (filter.category != null)
            Chip(label: Text(categoryLabel(filter.category!))),
          if (filter.minPriceCents != null || filter.maxPriceCents != null)
            Chip(
              label: Text(
                '${filter.minPriceCents == null ? 'от 0' : 'от ${formatUsd(filter.minPriceCents!)}'} · ${filter.maxPriceCents == null ? 'без верхней границы' : 'до ${formatUsd(filter.maxPriceCents!)}'}',
              ),
            ),
          if (filter.isActive)
            TextButton(
              onPressed: context.read<CatalogCubit>().resetFilters,
              child: const Text('Сбросить фильтры'),
            ),
          Text(
            'Найдено: ${state.filteredProducts.length}',
            style: const TextStyle(color: StoreColors.muted),
          ),
        ],
      ),
    );
  }
}
