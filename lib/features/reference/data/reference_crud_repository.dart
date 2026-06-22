import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../products/data/product_models.dart';

/// Write access (create / update / delete) for the four editable reference
/// entities — drug-groups, manufacturers, suppliers, units (TZ_03 §C.5,
/// TZ_01 §4.2 `GET/POST/PUT/DELETE`).
///
/// Kept SEPARATE from the read-only `ReferenceRepository` (which feeds the
/// [EntityPicker]) on purpose: the shared test fake implements only the
/// read interface, so adding mutations there would break it. This mirrors the
/// `ProductsRepository` CRUD pattern (Dio + `ApiResult`).
abstract interface class ReferenceCrudRepository {
  // Drug groups — contract: { id, name, parentId? }.
  Future<ApiResult<DrugGroup>> createDrugGroup(DrugGroup value);
  Future<ApiResult<DrugGroup>> updateDrugGroup(DrugGroup value);
  Future<ApiResult<void>> deleteDrugGroup(String id);

  // Manufacturers — contract: { id, name, country? }.
  Future<ApiResult<Manufacturer>> createManufacturer(Manufacturer value);
  Future<ApiResult<Manufacturer>> updateManufacturer(Manufacturer value);
  Future<ApiResult<void>> deleteManufacturer(String id);

  // Suppliers — contract: { id, name, inn?, phone?, address? }.
  Future<ApiResult<Supplier>> createSupplier(Supplier value);
  Future<ApiResult<Supplier>> updateSupplier(Supplier value);
  Future<ApiResult<void>> deleteSupplier(String id);

  // Units — contract: { id, name }.
  Future<ApiResult<Unit>> createUnit(Unit value);
  Future<ApiResult<Unit>> updateUnit(Unit value);
  Future<ApiResult<void>> deleteUnit(String id);
}

/// Dio-backed implementation of [ReferenceCrudRepository].
class ReferenceCrudRepositoryImpl implements ReferenceCrudRepository {
  ReferenceCrudRepositoryImpl(this._dio);

  final Dio _dio;

  // --- drug-groups ---------------------------------------------------------

  @override
  Future<ApiResult<DrugGroup>> createDrugGroup(DrugGroup value) =>
      _create('/drug-groups', value.toJson(), DrugGroup.fromJson);

  @override
  Future<ApiResult<DrugGroup>> updateDrugGroup(DrugGroup value) => _update(
    '/drug-groups/${value.id}',
    value.toJson(),
    DrugGroup.fromJson,
    value,
  );

  @override
  Future<ApiResult<void>> deleteDrugGroup(String id) =>
      _delete('/drug-groups/$id');

  // --- manufacturers -------------------------------------------------------

  @override
  Future<ApiResult<Manufacturer>> createManufacturer(Manufacturer value) =>
      _create('/manufacturers', value.toJson(), Manufacturer.fromJson);

  @override
  Future<ApiResult<Manufacturer>> updateManufacturer(Manufacturer value) =>
      _update(
        '/manufacturers/${value.id}',
        value.toJson(),
        Manufacturer.fromJson,
        value,
      );

  @override
  Future<ApiResult<void>> deleteManufacturer(String id) =>
      _delete('/manufacturers/$id');

  // --- suppliers -----------------------------------------------------------

  @override
  Future<ApiResult<Supplier>> createSupplier(Supplier value) =>
      _create('/suppliers', value.toJson(), Supplier.fromJson);

  @override
  Future<ApiResult<Supplier>> updateSupplier(Supplier value) => _update(
    '/suppliers/${value.id}',
    value.toJson(),
    Supplier.fromJson,
    value,
  );

  @override
  Future<ApiResult<void>> deleteSupplier(String id) =>
      _delete('/suppliers/$id');

  // --- units ---------------------------------------------------------------

  @override
  Future<ApiResult<Unit>> createUnit(Unit value) =>
      _create('/units', value.toJson(), Unit.fromJson);

  @override
  Future<ApiResult<Unit>> updateUnit(Unit value) =>
      _update('/units/${value.id}', value.toJson(), Unit.fromJson, value);

  @override
  Future<ApiResult<void>> deleteUnit(String id) => _delete('/units/$id');

  // --- shared helpers ------------------------------------------------------

  Future<ApiResult<T>> _create<T>(
    String path,
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final payload = Map<String, dynamic>.from(json)..remove('id');
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: payload,
      );
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

  Future<ApiResult<T>> _update<T>(
    String path,
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
    T fallback,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: json);
      final body = response.data;
      // Some APIs return 204/empty on PUT; fall back to the sent model.
      if (body == null) return Success(fallback);
      return Success(fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  Future<ApiResult<void>> _delete(String path) async {
    try {
      await _dio.delete<void>(path);
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
        if (status == 401 || status == 403) return const AuthFailure();
        if (status == 404) {
          return const ServerFailure('Сабт ёфт нашуд.', statusCode: 404);
        }
        if (status == 409) {
          return const ServerFailure(
            'Ин сабт истифода мешавад ва ҳазф намешавад.',
            statusCode: 409,
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
}

/// Provider exposing the [ReferenceCrudRepository] implementation.
final referenceCrudRepositoryProvider = Provider<ReferenceCrudRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ReferenceCrudRepositoryImpl(dio);
});
