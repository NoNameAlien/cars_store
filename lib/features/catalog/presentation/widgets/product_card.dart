import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/money.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/product.dart';

String categoryLabel(String category) => switch (category) {
  "men's clothing" => 'Мужская одежда',
  "women's clothing" => 'Женская одежда',
  'jewelery' => 'Украшения',
  'electronics' => 'Электроника',
  _ => category,
};

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      hoverColor: StoreColors.accent.withValues(alpha: .05),
      focusColor: StoreColors.accent.withValues(alpha: .1),
      key: Key('product-${product.id}'),
      onTap: () => context.push(StoreRoutes.product(product.id)),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StoreColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (_, _) => const ImagePlaceholder(),
                      errorWidget: (_, _, _) =>
                          const ImagePlaceholder(failed: true),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                categoryLabel(product.category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: StoreColors.accent),
              ),
              const SizedBox(height: 6),
              Tooltip(
                message: product.title,
                child: Text(
                  product.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontSize: 14, height: 1.35),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                formatUsd(product.unitPriceCents),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.5),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, this.failed = false});
  final bool failed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: failed ? 'Изображение недоступно' : 'Загрузка изображения',
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: StoreColors.canvas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        failed ? Icons.broken_image_outlined : Icons.image_outlined,
        size: 32,
        color: const Color(0xFFBBCBC5),
      ),
    ),
  );
}
