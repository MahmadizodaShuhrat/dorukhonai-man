import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import 'operations_models.dart';

/// MODUL 6 (Амалиёти анбор) repository contract.
///
/// Endpoints (NEW-ENDPOINT CONTRACT, base `/api/v1`):
///   POST /write-offs       { branchId, reason, note?, lines:[{batchId,quantity}] }
///   GET  /write-offs?from=&to=&page=
///   POST /inventory        { branchId, note?, lines:[{batchId,countedQuantity}] }
///   GET  /inventory?from=&to=&page=
///   POST /supplier-returns { supplierId, branchId, note?, lines:[{batchId,quantity}] }
///   GET  /supplier-returns?from=&to=&page=
abstract interface class OperationsRepository {
  Future<ApiResult<WriteOff>> createWriteOff({
    required String branchId,
    required WriteOffReason reason,
    String? note,
    required List<WriteOffLineRequest> lines,
  });

  Future<ApiResult<Paged<WriteOff>>> listWriteOffs({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<InventoryResult>> createInventory({
    required String branchId,
    String? note,
    required List<InventoryLineRequest> lines,
  });

  Future<ApiResult<Paged<InventoryDoc>>> listInventory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<SupplierReturn>> createSupplierReturn({
    required String supplierId,
    required String branchId,
    String? note,
    required List<SupplierReturnLineRequest> lines,
  });

  Future<ApiResult<Paged<SupplierReturn>>> listSupplierReturns({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  });
}

/// Dio-backed implementation of [OperationsRepository].
class OperationsRepositoryImpl implements OperationsRepository {
  OperationsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<WriteOff>> createWriteOff({
    required String branchId,
    required WriteOffReason reason,
    String? note,
    required List<WriteOffLineRequest> lines,
  }) {
    return _single(
      () => _dio.post<Map<String, dynamic>>(
        '/write-offs',
        data: {
          'branchId': branchId,
          'reason': reason.wire,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          'lines': lines.map((l) => l.toJson()).toList(growable: false),
        },
      ),
      WriteOff.fromJson,
    );
  }

  @override
  Future<ApiResult<Paged<WriteOff>>> listWriteOffs({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet('/write-offs', WriteOff.fromJson, from, to, page, size);
  }

  @override
  Future<ApiResult<InventoryResult>> createInventory({
    required String branchId,
    String? note,
    required List<InventoryLineRequest> lines,
  }) {
    return _single(
      () => _dio.post<Map<String, dynamic>>(
        '/inventory',
        data: {
          'branchId': branchId,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          'lines': lines.map((l) => l.toJson()).toList(growable: false),
        },
      ),
      InventoryResult.fromJson,
    );
  }

  @override
  Future<ApiResult<Paged<InventoryDoc>>> listInventory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet('/inventory', InventoryDoc.fromJson, from, to, page, size);
  }

  @override
  Future<ApiResult<SupplierReturn>> createSupplierReturn({
    required String supplierId,
    required String branchId,
    String? note,
    required List<SupplierReturnLineRequest> lines,
  }) {
    return _single(
      () => _dio.post<Map<String, dynamic>>(
        '/supplier-returns',
        data: {
          'supplierId': supplierId,
          'branchId': branchId,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          'lines': lines.map((l) => l.toJson()).toList(growable: false),
        },
      ),
      SupplierReturn.fromJson,
    );
  }

  @override
  Future<ApiResult<Paged<SupplierReturn>>> listSupplierReturns({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) {
    return _pagedGet(
      '/supplier-returns',
      SupplierReturn.fromJson,
      from,
      to,
      page,
      size,
    );
  }

  /// Runs a request returning a single object decoded by [fromJson].
  Future<ApiResult<T>> _single<T>(
    Future<Response<Map<String, dynamic>>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  /// Shared GET → [Paged] decoder for the document lists.
  Future<ApiResult<Paged<T>>> _pagedGet<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    DateTime? from,
    DateTime? to,
    int page,
    int size,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
          'page': page,
          'size': size,
        },
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Paged<T>.fromJson(body, fromJson));
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
        if (status == 400 || status == 409) {
          final message = _extractMessage(e.response?.data);
          return ServerFailure(
            message ?? 'Амалиёт иҷро нашуд (вазъи нодуруст).',
            statusCode: status,
          );
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

  String? _extractMessage(Object? data) {
    if (data is Map) {
      final detail = data['detail'] ?? data['title'] ?? data['message'];
      if (detail is String && detail.trim().isNotEmpty) return detail.trim();
    }
    return null;
  }
}

/// Provider exposing the [OperationsRepository] implementation.
final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OperationsRepositoryImpl(dio);
});
