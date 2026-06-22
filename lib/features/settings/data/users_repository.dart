import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/paged.dart';
import '../../auth/data/auth_models.dart';

/// Read access to the user directory for the Settings → Корбарон section
/// (TZ_01 §4.8, Admin only). The full CRUD lives server-side; the desktop
/// client lists users and can deactivate them.
///
/// Endpoints (NEW-ENDPOINT CONTRACT, Admin-only):
///   GET  /users                      -> [{ id, fullName, userName, role, isActive }]
///   POST /users                      { fullName, userName, password, role }
///   PUT  /users/{id}                 { fullName, role, isActive? }
///   POST /users/{id}/deactivate
/// Reuses the [User] model from the auth feature.
abstract interface class UsersRepository {
  /// Lists users (tolerates a paged envelope or a bare array).
  Future<ApiResult<List<User>>> list();

  /// Creates a user. `POST /users { fullName, userName, password, role }`.
  Future<ApiResult<User>> create({
    required String fullName,
    required String userName,
    required String password,
    required UserRole role,
  });

  /// Edits a user. `PUT /users/{id} { fullName, role, isActive? }`.
  Future<ApiResult<User>> update({
    required String id,
    required String fullName,
    required UserRole role,
    bool? isActive,
  });

  /// Deactivates a user (soft-disable).
  Future<ApiResult<void>> deactivate(String id);
}

/// Dio-backed implementation of [UsersRepository].
class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<List<User>>> list() async {
    try {
      final response = await _dio.get<dynamic>('/users');
      final body = _unwrap(response.data);
      if (body is List) {
        return Success(
          body
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList(growable: false),
        );
      }
      if (body is Map<String, dynamic> && body['items'] is List) {
        return Success(Paged<User>.fromJson(body, User.fromJson).items);
      }
      return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<User>> create({
    required String fullName,
    required String userName,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/users',
        data: {
          'fullName': fullName,
          'userName': userName,
          'password': password,
          'role': role.wire,
        },
      );
      return _decodeUser(response.data, fullName, userName, role);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<User>> update({
    required String id,
    required String fullName,
    required UserRole role,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/users/$id',
        data: {
          'fullName': fullName,
          'role': role.wire,
          'isActive': ?isActive,
        },
      );
      return _decodeUser(response.data, fullName, '', role, id: id);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  /// Decodes the returned user when the server echoes one, otherwise builds a
  /// best-effort [User] from the request (some endpoints return 204).
  ApiResult<User> _decodeUser(
    dynamic data,
    String fullName,
    String userName,
    UserRole role, {
    String? id,
  }) {
    final body = _unwrap(data);
    if (body is Map<String, dynamic> && body['id'] != null) {
      return Success(User.fromJson(body));
    }
    return Success(
      User(
        id: id ?? '',
        fullName: fullName,
        userName: userName,
        role: role,
      ),
    );
  }

  @override
  Future<ApiResult<void>> deactivate(String id) async {
    try {
      await _dio.post<void>('/users/$id/deactivate');
      return const Success(null);
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

/// Provider exposing the [UsersRepository] implementation.
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersRepositoryImpl(dio);
});

/// Loads the user list for the Admin Settings section. Throws the [Failure]
/// for `AsyncValue.error` rendering.
final usersListProvider = FutureProvider<List<User>>((ref) async {
  final repo = ref.watch(usersRepositoryProvider);
  final result = await repo.list();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw failure,
  };
});
