import 'package:equatable/equatable.dart';

import '../../../core/money.dart';

class CatalogFilter extends Equatable {
  const CatalogFilter({this.category, this.minPriceCents, this.maxPriceCents});
  final String? category;
  final int? minPriceCents;
  final int? maxPriceCents;
  bool get isActive =>
      category != null || minPriceCents != null || maxPriceCents != null;
  bool get isValid =>
      (minPriceCents == null ||
          (minPriceCents! >= 0 && minPriceCents! <= maxUnitPriceCents)) &&
      (maxPriceCents == null ||
          (maxPriceCents! >= 0 && maxPriceCents! <= maxUnitPriceCents)) &&
      (minPriceCents == null ||
          maxPriceCents == null ||
          minPriceCents! <= maxPriceCents!);

  @override
  List<Object?> get props => [category, minPriceCents, maxPriceCents];
}
