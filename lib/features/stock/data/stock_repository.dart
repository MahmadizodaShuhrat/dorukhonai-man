import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/cache_dao.dart';
import '../../sync/data/offline_first_repositories.dart';
import 'stock_models.dart';

/// Stock / warehouse (Анбор) repository contract.
///
/// Endpoints (API contract):
///   GET /stock?branchId=&search=&page=1&size=20
///   GET /stock/expiring?days=90&branchId=
///   GET /stock/low?branchId=
///   GET /stock/movements?productId=&from=&to=&page=1&size=20
abstract interface class StockRepository {
  Future<ApiResult<Paged<StockItem>>> list({
    String? branchId,
    String? search,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<Paged<StockItem>>> expiring({
    int days = 90,
    String? branchId,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<Paged<LowStockItem>>> low({
    String? branchId,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<Paged<StockMovement>>> movements({
    required String productId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  });
}

/// Dio-backed implementation of [StockRepository].
class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<Paged<StockItem>>> list({
    String? branchId,
    String? search,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet(
      '/stock',
      StockItem.fromJson,
      queryParameters: {
        if (branchId != null && branchId.trim().isNotEmpty)
          'branchId': branchId.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'size': size,
      },
    );
  }

  @override
  Future<ApiResult<Paged<StockItem>>> expiring({
    int days = 90,
    String? branchId,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet(
      '/stock/expiring',
      StockItem.fromJson,
      queryParameters: {
        'days': days,
        if (branchId != null && branchId.trim().isNotEmpty)
          'branchId': branchId.trim(),
        'page': page,
        'size': size,
      },
    );
  }

  @override
  Future<ApiResult<Paged<LowStockItem>>> low({
    String? branchId,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet(
      '/stock/low',
      LowStockItem.fromJson,
      queryParameters: {
        if (branchId != null && branchId.trim().isNotEmpty)
          'branchId': branchId.trim(),
        'page': page,
        'size': size,
      },
    );
  }

  @override
  Future<ApiResult<Paged<StockMovement>>> movements({
    required String productId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet(
      '/stock/movements',
      StockMovement.fromJson,
      queryParameters: {
        'productId': productId,
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
        'page': page,
        'size': size,
      },
    );
  }

  /// Shared GET → [Paged] decoder with Dio-error mapping.
  Future<ApiResult<Paged<T>>> _pagedGet<T>(
    String path,
    T Function(Map<String, dynamic>) fromJsonT, {
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Paged<T>.fromJson(body, fromJsonT));
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

/// Provider exposing the [StockRepository].
///
/// Wrapped in an offline-first decorator (Dio online + Drift cache fallback for
/// the balance view, TZ_04 §1). Tests override this provider directly with a
/// fake, bypassing the decorator.
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final dao = CacheDao(ref.watch(appDatabaseProvider));
  return OfflineFirstStockRepository(
    StockRepositoryImpl(ref.watch(dioProvider)),
    dao,
    branchId: '',
  );
});
