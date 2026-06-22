import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../products/data/product_models.dart';
import 'sync_models.dart';

/// The decoded `GET /sync/catalog` snapshot/delta.
class CatalogSyncResponse {
  const CatalogSyncResponse({
    required this.serverTime,
    required this.products,
    required this.drugGroups,
    required this.manufacturers,
    required this.units,
    required this.suppliers,
    required this.batches,
    required this.stock,
  });

  /// Stored as the next `since` cursor.
  final String serverTime;
  final List<Product> products;
  final List<DrugGroup> drugGroups;
  final List<Manufacturer> manufacturers;
  final List<Unit> units;
  final List<Supplier> suppliers;
  final List<SyncBatchRow> batches;
  final List<SyncStockRow> stock;

  factory CatalogSyncResponse.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = (json[key] as List<dynamic>?) ?? const [];
      return raw
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }

    return CatalogSyncResponse(
      serverTime: json['serverTime'] as String? ?? '',
      products: list('products', Product.fromJson),
      drugGroups: list('drugGroups', DrugGroup.fromJson),
      manufacturers: list('manufacturers', Manufacturer.fromJson),
      units: list('units', Unit.fromJson),
      suppliers: list('suppliers', Supplier.fromJson),
      batches: list('batches', SyncBatchRow.fromJson),
      stock: list('stock', SyncStockRow.fromJson),
    );
  }
}

/// Sync transport contract (TZ_04 §4 / SHARED SYNC CONTRACT).
///   GET  /sync/catalog?since=`<iso|empty>`
///   POST /sync/sales { sales: [...] }
///   plus a lightweight connectivity probe.
abstract interface class SyncRepository {
  /// PULL the catalog + stock. Empty/null [since] requests a full snapshot.
  Future<ApiResult<CatalogSyncResponse>> pullCatalog({String? since});

  /// PUSH queued offline sales. [sales] are the raw per-sale JSON payloads
  /// (already shaped to the contract). Returns one result per sale.
  Future<ApiResult<List<SalePushResult>>> pushSales(
    List<Map<String, dynamic>> sales,
  );

  /// Lightweight reachability probe; `true` when the server answers.
  Future<bool> ping();
}

/// Dio-backed implementation of [SyncRepository].
class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<CatalogSyncResponse>> pullCatalog({String? since}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sync/catalog',
        queryParameters: {'since': since ?? ''},
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(CatalogSyncResponse.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<List<SalePushResult>>> pushSales(
    List<Map<String, dynamic>> sales,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/sync/sales',
        data: {'sales': sales},
      );
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      final raw = (body['results'] as List<dynamic>?) ?? const [];
      final results = raw
          .map((e) => SalePushResult.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      return Success(results);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<bool> ping() async {
    try {
      // A cheap, auth-cheap GET; any HTTP answer (even 401) proves the server
      // is reachable. Short timeout so the UI flips quickly.
      await _dio.get<dynamic>(
        '/sync/catalog',
        queryParameters: {'since': DateTime.now().toUtc().toIso8601String()},
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      return true;
    } on DioException catch (e) {
      // Connection-level failures mean offline; an HTTP status means online.
      return e.response != null;
    } catch (_) {
      return false;
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

/// Provider exposing the [SyncRepository] implementation.
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SyncRepositoryImpl(dio);
});
