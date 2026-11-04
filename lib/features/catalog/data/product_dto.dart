import '../../../core/money.dart';
import '../domain/product.dart';

class ProductDto {
  const ProductDto(this.product);
  final Product product;

  factory ProductDto.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Product must be an object');
    }
    final id = value['id'];
    final price = value['price'];
    String text(String key) {
      final field = value[key];
      if (field is! String || field.trim().isEmpty) {
        throw FormatException('Invalid product $key');
      }
      return field.trim();
    }

    if (id is! int ||
        id <= 0 ||
        price is! num ||
        !price.isFinite ||
        price < 0) {
      throw const FormatException('Invalid product id or price');
    }
    final image = text('image');
    final uri = Uri.tryParse(image);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const FormatException('Invalid product image URL');
    }
    final description = value['description'];
    if (description != null && description is! String) {
      throw const FormatException('Invalid description');
    }
    final rawRating = value['rating'];
    double? rating;
    int? count;
    if (rawRating != null) {
      if (rawRating is! Map<String, dynamic>) {
        throw const FormatException('Invalid rating');
      }
      final rate = rawRating['rate'];
      final total = rawRating['count'];
      if ((rate != null &&
              (rate is! num || !rate.isFinite || rate < 0 || rate > 5)) ||
          (total != null && (total is! int || total < 0))) {
        throw const FormatException('Invalid rating');
      }
      rating = (rate as num?)?.toDouble();
      count = total as int?;
    }
    return ProductDto(
      Product(
        id: id,
        title: text('title'),
        unitPriceCents: apiPriceToCents(price),
        description: description as String? ?? '',
        rating: rating,
        ratingCount: count,
        category: text('category'),
        imageUrl: image,
      ),
    );
  }

  Product toDomain() => product;

  Map<String, Object?> toJson() => {
    'id': product.id,
    'title': product.title,
    'price': product.price,
    'category': product.category,
    'image': product.imageUrl,
    'description': product.description,
    'rating': product.rating == null && product.ratingCount == null
        ? null
        : {'rate': product.rating, 'count': product.ratingCount},
  };
}

List<ProductDto> parseProducts(Object? value) {
  if (value is! List) throw const FormatException('Catalog must be a list');
  final products = value.map(ProductDto.fromJson).toList(growable: false);
  if (products.map((dto) => dto.product.id).toSet().length != products.length) {
    throw const FormatException('Duplicate product IDs');
  }
  return products;
}
