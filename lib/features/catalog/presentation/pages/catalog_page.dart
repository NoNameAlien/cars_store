import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/store_scaffold.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../widgets/catalog_feedback.dart';
import '../widgets/catalog_filters.dart';
import '../widgets/catalog_header.dart';
import '../widgets/product_card.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) => StoreScaffold(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1040;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wide) ...[
                    SizedBox(
                      width: 260,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 36, bottom: 24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: StoreColors.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: CatalogFilters(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                  Expanded(child: _CatalogContent(showFilterButton: !wide)),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({required this.showFilterButton});
  final bool showFilterButton;

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) {
      final cubit = context.read<CatalogCubit>();
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 4
              : constraints.maxWidth >= 700
              ? 3
              : constraints.maxWidth >= 300
              ? 2
              : 1;
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final extent =
              (constraints.maxWidth >= 700 ? 350.0 : 310.0) +
              (scale - 1).clamp(0, 4) * 160;
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: CatalogHeading(
                  count: state.hasCatalog ? state.products.length : null,
                  refreshing:
                      state.isRefreshing ||
                      state.status == CatalogStatus.loading,
                  onRefresh: cubit.refresh,
                ),
              ),
              if (state.hasCatalog &&
                  (state.isFromCache ||
                      state.failure != null ||
                      state.cacheWriteFailed))
                SliverToBoxAdapter(child: CatalogNotice(state: state)),
              if (state.hasCatalog)
                SliverToBoxAdapter(
                  child: FilterSummary(
                    state: state,
                    showFilterButton: showFilterButton,
                  ),
                ),
            ],
            body: switch (state.status) {
              CatalogStatus.initial || CatalogStatus.loading => CatalogSkeleton(
                columns: columns,
                extent: extent,
              ),
              CatalogStatus.error => CatalogFeedback(
                failure: state.failure,
                onRetry: cubit.refresh,
              ),
              CatalogStatus.empty => CatalogFeedback(onRetry: cubit.refresh),
              CatalogStatus.success when state.filteredProducts.isEmpty =>
                CatalogFeedback(
                  title: 'Ничего не нашлось',
                  message:
                      'Попробуйте другую категорию или измените диапазон цен.',
                  buttonLabel: 'Сбросить фильтры',
                  onRetry: cubit.resetFilters,
                ),
              CatalogStatus.success => RefreshIndicator(
                onRefresh: cubit.refresh,
                child: GridView.builder(
                  key: const PageStorageKey('catalog'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: extent,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.filteredProducts.length,
                  itemBuilder: (context, index) => ProductCard(
                    key: ValueKey(state.filteredProducts[index].id),
                    product: state.filteredProducts[index],
                  ),
                ),
              ),
            },
          );
        },
      );
    },
  );
}
