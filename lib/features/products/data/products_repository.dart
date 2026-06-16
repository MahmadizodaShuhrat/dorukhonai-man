import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import 'product_models.dart';

/// Products (reference-data) repository contract.
///
/// Endpoints (API contract):
///   GET    /products?search=&page=1&size=20
///   GET    /products/{id}
///   GET    /products/by-barcode/{barcode}
///   POST   /products
///   PUT    /products/{id}
///   DELETE /products/{id}   (soft delete)
abstract interface class ProductsRepository {
  Future<ApiResult<Paged<Product>>> list({
    String? search,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<Product>> getById(String id);

  Future<ApiResult<Product>> getByBarcode(String barcode);

  Future<ApiResult<Product>> create(Product product);

  Future<ApiResult<Product>> update(Product product);

  Future<ApiResult<void>> delete(String id);
}

/// Dio-backed implementation of [ProductsRepository].
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<Paged<Product>>> list({
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'page': page,
          'size': size,
        },
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Paged<Product>.fromJson(body, Product.fromJson));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Product>> getById(String id) =>
      _getProduct('/products/$id');

  @override
  Future<ApiResult<Product>> getByBarcode(String barcode) =>
      _getProduct('/products/by-barcode/$barcode');

  Future<ApiResult<Product>> _getProduct(String path) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Дору ёфт нашуд.'));
      }
      return Success(Product.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Product>> create(Product product) async {
    try {
      final payload = product.toJson()..remove('id');
      final response = await _dio.post<Map<String, dynamic>>(
        '/products',
        data: payload,
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Product.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Product>> update(Product product) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/products/${product.id}',
        data: product.toJson(),
      );
      final body = response.data;
      // Some APIs return 204/empty on PUT; fall back to the sent model.
      if (body == null) return Success(product);
      return Success(Product.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    try {
      await _dio.delete<void>('/products/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          return const AuthFailure();
        }
        if (status == 404) {
          return const ServerFailure('Дору ёфт нашуд.', statusCode: 404);
        }
        return ServerFailure(
          'Хатои сервер (${status ?? '—'}).',
          statusCode: status,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownFailure();
    }
  }
}

/// Provider exposing the [ProductsRepository] implementation.
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductsRepositoryImpl(dio);
});
