import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import '../../products/data/product_models.dart';

/// Read access to the reference-data lists used to populate [EntityPicker]s
/// (TZ_03 §C.5/P2): drug groups, manufacturers, units, suppliers.
///
/// Endpoints (API contract): `GET /drug-groups`, `/manufacturers`, `/units`,
/// `/suppliers` — all returning the standard paged envelope. Mirrors the
/// `ProductsRepository` pattern (Dio + `ApiResult` + `Paged`).
abstract interface class ReferenceRepository {
  Future<ApiResult<Paged<DrugGroup>>> drugGroups({
    String? search,
    int page = 1,
    int size = 50,
  });

  Future<ApiResult<Paged<Manufacturer>>> manufacturers({
    String? search,
    int page = 1,
    int size = 50,
  });

  Future<ApiResult<Paged<Unit>>> units({
    String? search,
    int page = 1,
    int size = 50,
  });

  Future<ApiResult<Paged<Supplier>>> suppliers({
    String? search,
    int page = 1,
    int size = 50,
  });
}

/// Dio-backed implementation of [ReferenceRepository].
class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<Paged<DrugGroup>>> drugGroups({
    String? search,
    int page = 1,
    int size = 50,
  }) => _list('/drug-groups', DrugGroup.fromJson, search, page, size);

  @override
  Future<ApiResult<Paged<Manufacturer>>> manufacturers({
    String? search,
    int page = 1,
    int size = 50,
  }) => _list('/manufacturers', Manufacturer.fromJson, search, page, size);

  @override
  Future<ApiResult<Paged<Unit>>> units({
    String? search,
    int page = 1,
    int size = 50,
  }) => _list('/units', Unit.fromJson, search, page, size);

  @override
  Future<ApiResult<Paged<Supplier>>> suppliers({
    String? search,
    int page = 1,
    int size = 50,
  }) => _list('/suppliers', Supplier.fromJson, search, page, size);

  /// Shared list fetch for any reference entity. Tolerates either the paged
  /// envelope `{items,total,page,size}` or a bare JSON array.
  Future<ApiResult<Paged<T>>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    String? search,
    int page,
    int size,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'page': page,
          'size': size,
        },
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return Success(Paged<T>.fromJson(body, fromJson));
      }
      if (body is List) {
        final items = body
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
        return Success(
          Paged<T>(items: items, total: items.length, page: 1, size: size),
        );
      }
      return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
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
        if (status == 401 || status == 403) return const AuthFailure();
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

/// Provider exposing the [ReferenceRepository] implementation.
final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReferenceRepositoryImpl(dio);
});
