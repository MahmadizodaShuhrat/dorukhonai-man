import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_models.dart';

/// Auth repository contract (TZ §4: Repository interface → Dio data source).
abstract interface class AuthRepository {
  /// Logs in with username/password. On success the tokens are persisted in
  /// secure storage and the parsed [LoginResponse] (including the [User]) is
  /// returned.
  Future<ApiResult<LoginResponse>> login({
    required String userName,
    required String password,
  });

  /// Calls `GET /auth/me` (Bearer) to fetch the current user.
  Future<ApiResult<User>> me();

  /// Calls `POST /auth/logout` (Bearer) then clears stored tokens. Token
  /// removal happens even if the network call fails.
  Future<void> logout();
}

/// Dio-backed implementation hitting the `/auth/*` endpoints (API contract).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  @override
  Future<ApiResult<LoginResponse>> login({
    required String userName,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        // Contract field names: { "userName", "password" }.
        data: {'userName': userName, 'password': password},
      );

      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }

      final login = LoginResponse.fromJson(body);
      await _tokenStorage.saveTokens(
        accessToken: login.token,
        refreshToken: login.refreshToken,
      );
      return Success(login);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<User>> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(User.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } on DioException catch (_) {
      // Best-effort server logout; local tokens are cleared regardless.
    } finally {
      await _tokenStorage.clear();
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
          return const AuthFailure('Логин ё парол нодуруст аст.');
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

/// Provider exposing the [AuthRepository] implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(dio, tokenStorage);
});
