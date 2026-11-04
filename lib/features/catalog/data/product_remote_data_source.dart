import 'package:dio/dio.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import 'product_dto.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<ProductDto>> fetchProducts() async {
    try {
      final response = await _dio.get<Object?>('/products');
      return parseProducts(response.data);
    } on DioException catch (error) {
      throw mapNetworkFailure(error);
    } on FormatException {
      throw const AppFailure(FailureKind.unexpected);
    }
  }
}
