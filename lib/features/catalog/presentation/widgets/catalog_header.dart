import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class CatalogHeading extends StatelessWidget {
  const CatalogHeading({
    super.key,
    required this.count,
    required this.refreshing,
    required this.onRefresh,
  });
  final int? count;
  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        constraints.maxWidth < 500 ? 12 : 28,
        0,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Каталог товаров',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: constraints.maxWidth < 500 ? 28 : 38,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              MergeSemantics(
                child: Semantics(
                  value: refreshing ? 'Загрузка' : null,
                  child: IconButton(
                    tooltip: 'Обновить каталог',
                    onPressed: refreshing ? null : onRefresh,
                    icon: ExcludeSemantics(
                      child: refreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: StoreColors.muted,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (constraints.maxWidth >= 500) ...[
            const SizedBox(height: 8),
            Text(
              count == null
                  ? 'Одежда, украшения и техника. Цены в USD.'
                  : 'Одежда, украшения и техника · $count товаров · USD',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: StoreColors.muted),
            ),
          ],
        ],
      ),
    ),
  );
}
