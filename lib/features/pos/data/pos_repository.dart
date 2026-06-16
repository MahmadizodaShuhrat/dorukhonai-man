import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import 'pos_models.dart';

/// POS / Касса repository contract (Module 5).
///
/// Endpoints (API contract, base `/api/v1`):
///   POST /cash-shifts/open   { branchId, openingCash }
///   POST /cash-shifts/close  { closingCash }
///   GET  /cash-shifts/current?branchId=
///   POST /sales              { branchId, lines:[...], payments:[...], discount? }
///   GET  /sales?shiftId=&from=&to=&page=1&size=20
///   GET  /sales/{id}
///   POST /sales/{id}/return  { lines:[{ saleLineId, quantity }] }
///   GET  /reports/z-report/{shiftId}
abstract interface class PosRepository {
  /// Opens a new shift for [branchId] with [openingCash]. The server rejects
  /// (409) if a shift is already open for that branch/user.
  Future<ApiResult<CashShift>> openShift({
    required String branchId,
    required double openingCash,
  });

  /// Closes the current open shift with the counted [closingCash]. The response
  /// includes Z-report figures (the closed [CashShift]).
  Future<ApiResult<CashShift>> closeShift({required double closingCash});

  /// Returns the current open shift for [branchId], or a 404 failure if none.
  Future<ApiResult<CashShift>> currentShift({String? branchId});

  /// Books a sale. The server applies FEFO and returns the allocated [Sale]
  /// (lines may be split per batch).
  Future<ApiResult<Sale>> createSale({
    required String branchId,
    required List<CartItem> lines,
    required List<Payment> payments,
    double discount = 0,
  });

  /// Loads a single sale (with lines + payments) by id.
  Future<ApiResult<Sale>> getSale(String id);

  /// Lists sale headers, optionally scoped to a shift / date range.
  Future<ApiResult<Paged<Sale>>> listSales({
    String? shiftId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  });

  /// Returns the requested quantities of [lines] from sale [saleId]; restores
  /// stock to the same batches and refunds.
  Future<ApiResult<Sale>> returnSale({
    required String saleId,
    required List<SaleReturnLine> lines,
  });

  /// Z-report figures for a (open or closed) shift.
  Future<ApiResult<ZReport>> zReport(String shiftId);
}

/// One line of a return request (`{ saleLineId, quantity }`).
class SaleReturnLine {
  const SaleReturnLine({required this.saleLineId, required this.quantity});

  final String saleLineId;
  final double quantity;

  Map<String, dynamic> toJson() => {
    'saleLineId': saleLineId,
    'quantity': quantity,
  };
}

/// Dio-backed implementation of [PosRepository].
class PosRepositoryImpl implements PosRepository {
  PosRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<CashShift>> openShift({
    required String branchId,
    required double openingCash,
  }) {
    return _shift(
      () => _dio.post<Map<String, dynamic>>(
        '/cash-shifts/open',
        data: {'branchId': branchId, 'openingCash': openingCash},
      ),
    );
  }

  @override
  Future<ApiResult<CashShift>> closeShift({required double closingCash}) {
    return _shift(
      () => _dio.post<Map<String, dynamic>>(
        '/cash-shifts/close',
        data: {'closingCash': closingCash},
      ),
    );
  }

  @override
  Future<ApiResult<CashShift>> currentShift({String? branchId}) {
    return _shift(
      () => _dio.get<Map<String, dynamic>>(
        '/cash-shifts/current',
        queryParameters: {
          if (branchId != null && branchId.trim().isNotEmpty)
            'branchId': branchId.trim(),
        },
      ),
    );
  }

  @override
  Future<ApiResult<Sale>> createSale({
    required String branchId,
    required List<CartItem> lines,
    required List<Payment> payments,
    double discount = 0,
  }) {
    return _sale(
      () => _dio.post<Map<String, dynamic>>(
        '/sales',
        data: {
          'branchId': branchId,
          'lines': lines.map((l) => l.toRequestJson()).toList(growable: false),
          'payments': payments.map((p) => p.toJson()).toList(growable: false),
          if (discount > 0) 'discount': discount,
        },
      ),
    );
  }

  @override
  Future<ApiResult<Sale>> getSale(String id) =>
      _sale(() => _dio.get<Map<String, dynamic>>('/sales/$id'));

  @override
  Future<ApiResult<Paged<Sale>>> listSales({
    String? shiftId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sales',
        queryParameters: {
          if (shiftId != null && shiftId.trim().isNotEmpty)
            'shiftId': shiftId.trim(),
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
      return Success(Paged<Sale>.fromJson(body, Sale.fromJson));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<Sale>> returnSale({
    required String saleId,
    required List<SaleReturnLine> lines,
  }) {
    return _sale(
      () => _dio.post<Map<String, dynamic>>(
        '/sales/$saleId/return',
        data: {
          'lines': lines.map((l) => l.toJson()).toList(growable: false),
        },
      ),
    );
  }

  @override
  Future<ApiResult<ZReport>> zReport(String shiftId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/z-report/$shiftId',
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Z-ҳисобот ёфт нашуд.'));
      }
      return Success(ZReport.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  /// Runs a request that returns a single [CashShift].
  Future<ApiResult<CashShift>> _shift(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(CashShift.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  /// Runs a request that returns a single [Sale].
  Future<ApiResult<Sale>> _sale(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(Sale.fromJson(body));
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
          return const ServerFailure('Ёфт нашуд.', statusCode: 404);
        }
        if (status == 400 || status == 409) {
          // Validation / state conflict (e.g. a shift already open, stock not
          // enough). Surface the server message when present.
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

/// Provider exposing the [PosRepository] implementation.
final posRepositoryProvider = Provider<PosRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PosRepositoryImpl(dio);
});
