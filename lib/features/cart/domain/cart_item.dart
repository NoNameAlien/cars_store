import 'package:equatable/equatable.dart';

import '../../catalog/domain/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.unitPriceCents,
    required this.quantity,
  });
  static const maxQuantity = 999;
  final int productId;
  final String title;
  final String imageUrl;
  final int unitPriceCents;
  final int quantity;
  int get totalCents => unitPriceCents * quantity;
  factory CartItem.fromProduct(Product product) => CartItem(
    productId: product.id,
    title: product.title,
    imageUrl: product.imageUrl,
    unitPriceCents: product.unitPriceCents,
    quantity: 1,
  );
  CartItem withQuantity(int value) => CartItem(
    productId: productId,
    title: title,
    imageUrl: imageUrl,
    unitPriceCents: unitPriceCents,
    quantity: value,
  );

  @override
  List<Object> get props => [
    productId,
    title,
    imageUrl,
    unitPriceCents,
    quantity,
  ];
}
