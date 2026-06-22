import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import '../../pos/data/pos_models.dart';
import '../../stock/data/stock_models.dart';
import 'report_models.dart';

/// Reports (Ҳисоботҳо) repository contract (TZ_01 §4.7, TZ_03 §C.6).
///
/// Endpoints (API contract, base `/api/v1`):
///   GET /reports/sales?from=&to=&branchId=&groupBy=day|product|seller
///   GET /reports/stock-value?branchId=
///   GET /reports/profit?from=&to=
///   GET /reports/expiring
///   GET /reports/z-report/{shiftId}
///
/// Read-only; mirrors the `StockRepository`/`PosRepository` Dio + `ApiResult`
/// pattern. Z-report reuses the existing [ZReport] model from the POS feature.
abstract interface class ReportsRepository {
  /// Grouped sales totals for a date window.
  Future<ApiResult<List<SalesReportRow>>> sales({
    required DateTime from,
    required DateTime to,
    SalesGroupBy groupBy = SalesGroupBy.day,
    String? branchId,
  });

  /// Aggregate profit (revenue/cost/profit) for a date window.
  Future<ApiResult<ProfitReport>> profit({
    required DateTime from,
    required DateTime to,
  });

  /// Current stock value (per-product rows + implicit grand total).
  Future<ApiResult<List<StockValueRow>>> stockValue({String? branchId});

  /// Products expiring soon (reuses the [StockItem] projection).
  Future<ApiResult<List<StockItem>>> expiring();

  /// Z-report figures for a closed/open shift.
  Future<ApiResult<ZReport>> zReport(String shiftId);
}

/// Dio-backed implementation of [ReportsRepository].
class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<List<SalesReportRow>>> sales({
    required DateTime from,
    required DateTime to,
    SalesGroupBy groupBy = SalesGroupBy.day,
    String? branchId,
  }) {
    return _listGet(
      '/reports/sales',
      SalesReportRow.fromJson,
      queryParameters: {
        'from': _dateParam(from),
        'to': _dateParam(to),
        'groupBy': groupBy.wire,
        if (branchId != null && branchId.trim().isNotEmpty)
          'branchId': branchId.trim(),
      },
    );
  }

  @override
  Future<ApiResult<ProfitReport>> profit({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/reports/profit',
        queryParameters: {'from': _dateParam(from), 'to': _dateParam(to)},
      );
      final body = _unwrap(response.data);
      if (body is Map<String, dynamic>) {
        return Success(ProfitReport.fromJson(body));
      }
      return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<List<StockValueRow>>> stockValue({String? branchId}) {
    return _listGet(
      '/reports/stock-value',
      StockValueRow.fromJson,
      queryParameters: {
        if (branchId != null && branchId.trim().isNotEmpty)
          'branchId': branchId.trim(),
      },
    );
  }

  @override
  Future<ApiResult<List<StockItem>>> expiring() {
    return _listGet(
      '/reports/expiring',
      StockItem.fromJson,
      queryParameters: const {},
    );
  }

  @override
  Future<ApiResult<ZReport>> zReport(String shiftId) async {
    try {
      final response = await _dio.get<dynamic>('/reports/z-report/$shiftId');
      final body = _unwrap(response.data);
      if (body is Map<String, dynamic>) {
        return Success(ZReport.fromJson(body));
      }
      return const Error(ServerFailure('Ҳисобот ёфт нашуд.'));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  /// GET → `List<T>`, tolerating either a bare array, a paged envelope
  /// (`{items,...}`), or a `{data: ...}` wrapper.
  Future<ApiResult<List<T>>> _listGet<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return Success(
          body
              .map((e) => fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
      }
      if (body is Map<String, dynamic>) {
        // Paged envelope.
        if (body['items'] is List) {
          return Success(Paged<T>.fromJson(body, fromJson).items);
        }
        // Single aggregate object → one-row list.
        return Success([fromJson(body)]);
      }
      return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  /// Unwraps the standard `{ "data": ..., "error": null }` envelope when
  /// present (TZ_01 §4), otherwise returns the body unchanged.
  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('data') &&
        data.containsKey('error')) {
      return data['data'];
    }
    return data;
  }

  /// Reports take date-only `from`/`to`; send an ISO date (no time component)
  /// so the server includes whole days inclusively.
  String _dateParam(DateTime d) {
    final local = DateTime(d.year, d.month, d.day);
    return local.toIso8601String().split('T').first;
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

/// Provider exposing the [ReportsRepository] implementation.
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportsRepositoryImpl(dio);
});
