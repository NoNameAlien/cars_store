import '../../../core/money.dart';
import '../domain/cart_item.dart';

class CartItemDto {
  static CartItem fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid cart item');
    }
    final id = value['productId'];
    final title = value['title'];
    final image = value['imageUrl'];
    final price = value['unitPriceCents'];
    final quantity = value['quantity'];
    final uri = image is String ? Uri.tryParse(image) : null;
    if (id is! int ||
        id <= 0 ||
        title is! String ||
        title.trim().isEmpty ||
        uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        price is! int ||
        price < 0 ||
        price > maxUnitPriceCents ||
        quantity is! int ||
        quantity < 1 ||
        quantity > CartItem.maxQuantity) {
      throw const FormatException('Invalid cart snapshot');
    }
    return CartItem(
      productId: id,
      title: title,
      imageUrl: image as String,
      unitPriceCents: price,
      quantity: quantity,
    );
  }

  static Map<String, Object> toJson(CartItem item) => {
    'productId': item.productId,
    'title': item.title,
    'imageUrl': item.imageUrl,
    'unitPriceCents': item.unitPriceCents,
    'quantity': item.quantity,
  };
}
