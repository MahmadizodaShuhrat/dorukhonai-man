import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import 'receipt_models.dart';

/// Goods-receipt (Приход) repository contract.
///
/// Endpoints (API contract):
///   GET  /receipts?from=&to=&supplierId=&status=&page=1&size=20
///   GET  /receipts/{id}
///   POST /receipts
///   PUT  /receipts/{id}
///   POST /receipts/{id}/post
///   POST /receipts/{id}/cancel
abstract interface class ReceiptsRepository {
  Future<ApiResult<Paged<Receipt>>> list({
    DateTime? from,
    DateTime? to,
    String? supplierId,
    ReceiptStatus? status,
    int page = 1,
    int size = 20,
  });

  Future<ApiResult<Receipt>> getById(String id);

  /// Creates a new Draft receipt from [receipt]'s header + lines.
  Future<ApiResult<Receipt>> create(Receipt receipt);

  /// Updates an existing Draft (the server rejects non-Draft).
  Future<ApiResult<Receipt>> update(Receipt receipt);

  /// Posts a Draft: creates/updates Batch + Stock + StockMovement.
  Future<ApiResult<Receipt>> post(String id);

  /// Cancels a receipt.
  Future<ApiResult<Receipt>> cancel(String id);
}

/// Dio-backed implementation of [ReceiptsRepository].
class ReceiptsRepositoryImpl implements ReceiptsRepository {
  ReceiptsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<Paged<Receipt>>> list({
    DateTime? from,
    DateTime? to,
    String? supplierId,
    ReceiptStatus? status,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/receipts',
        queryParameters: {
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
          if (supplierId != null && supplierId.trim().isNotEmpty)
            'supplierId': supplierId.trim(),
          if (status != null) 'status': status.wire,
          'page': page,
          'size': size,
        },
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Paged<Receipt>.fromJson(body, Receipt.fromJson));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Receipt>> getById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/receipts/$id');
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Приход ёфт нашуд.'));
      }
      return Success(Receipt.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Receipt>> create(Receipt receipt) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/receipts',
        data: receipt.toCreateJson(),
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Receipt.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Receipt>> update(Receipt receipt) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/receipts/${receipt.id}',
        data: receipt.toCreateJson(),
      );
      final body = response.data;
      // Some APIs return 204/empty on PUT; fall back to the sent model.
      if (body == null) return Success(receipt);
      return Success(Receipt.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Receipt>> post(String id) => _action('/receipts/$id/post');

  @override
  Future<ApiResult<Receipt>> cancel(String id) =>
      _action('/receipts/$id/cancel');

  Future<ApiResult<Receipt>> _action(String path) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path);
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Receipt.fromJson(body));
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
          return const ServerFailure('Приход ёфт нашуд.', statusCode: 404);
        }
        if (status == 400 || status == 409) {
          // Validation / state conflict (e.g. double-post, editing a posted
          // receipt). Surface the server message when present.
          final serverMessage = _extractMessage(e.response?.data);
          return ServerFailure(
            serverMessage ?? 'Амалиёт иҷро нашуд (вазъи нодуруст).',
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

  /// Best-effort extraction of a human message from a problem-details body.
  String? _extractMessage(Object? data) {
    if (data is Map) {
      final detail = data['detail'] ?? data['title'] ?? data['message'];
      if (detail is String && detail.trim().isNotEmpty) return detail.trim();
    }
    return null;
  }
}

/// Provider exposing the [ReceiptsRepository] implementation.
final receiptsRepositoryProvider = Provider<ReceiptsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReceiptsRepositoryImpl(dio);
});
