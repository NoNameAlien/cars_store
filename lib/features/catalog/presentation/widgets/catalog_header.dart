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
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 500;
      final button = MergeSemantics(
        child: Semantics(
          value: refreshing ? 'Загрузка' : null,
          child: IconButton.outlined(
            tooltip: 'Обновить каталог',
            onPressed: refreshing ? null : onRefresh,
            icon: ExcludeSemantics(
              child: refreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ),
        ),
      );
      return Padding(
        padding: EdgeInsets.fromLTRB(0, narrow ? 24 : 36, 0, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'НАЙДИТЕ СВОЁ',
              style: TextStyle(
                color: StoreColors.accent,
                letterSpacing: 2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Каталог товаров',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(fontSize: narrow ? 28 : 40),
                  ),
                ),
                if (!narrow) button,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Для повседневной жизни. Для вашего стиля.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: StoreColors.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: StoreColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            count == null
                                ? 'Все товары'
                                : 'Все товары · $count',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (narrow)
                    button
                  else
                    const Text(
                      'Цены в USD',
                      style: TextStyle(color: StoreColors.muted, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
