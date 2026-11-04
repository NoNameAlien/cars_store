import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.unitPriceCents,
    required this.category,
    required this.imageUrl,
    this.description = '',
    this.rating,
    this.ratingCount,
  });
  final int id;
  final String title;
  final int unitPriceCents;
  double get price => unitPriceCents / 100;
  final String category;
  final String imageUrl;
  final String description;
  final double? rating;
  final int? ratingCount;

  @override
  List<Object?> get props => [
    id,
    title,
    unitPriceCents,
    category,
    imageUrl,
    description,
    rating,
    ratingCount,
  ];
}
