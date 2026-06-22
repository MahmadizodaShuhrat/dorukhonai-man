import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import 'branch_models.dart';

/// Read access to the branch directory (TZ_05 FW1 / NEW-ENDPOINT CONTRACT).
///
/// Endpoint (API contract): `GET /branches` → a bare array of branches.
abstract interface class BranchRepository {
  /// Lists all branches (tolerates a paged envelope or a bare array).
  Future<ApiResult<List<Branch>>> list();
}

/// Dio-backed implementation of [BranchRepository].
class BranchRepositoryImpl implements BranchRepository {
  BranchRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<List<Branch>>> list() async {
    try {
      final response = await _dio.get<dynamic>('/branches');
      final body = _unwrap(response.data);
      if (body is List) {
        return Success(
          body
              .map((e) => Branch.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
      }
      if (body is Map<String, dynamic> && body['items'] is List) {
        return Success(
          (body['items'] as List)
              .map((e) => Branch.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
      }
      return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('data') &&
        data.containsKey('error')) {
      return data['data'];
    }
    return data;
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

/// Provider exposing the [BranchRepository] implementation.
final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BranchRepositoryImpl(dio);
});
