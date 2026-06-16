import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

/// Builds and configures the application-wide [Dio] instance.
///
/// Responsibilities (TZ §4 / API contract):
///  - base URL from constants;
///  - attach `Authorization: Bearer <token>` on every request;
///  - on `401`, transparently refresh the access token via
///    `POST /auth/refresh` using the stored refresh token, then retry the
///    original request ONCE. If refresh fails (or there is no refresh token),
///    clear tokens and force a logout.
///
/// Loop guards:
///  - the refresh call itself goes through a SEPARATE bare [Dio] with no
///    interceptor, so a 401 from `/auth/refresh` can never re-trigger refresh;
///  - each request is retried at most once (`_retriedFlag` marker on the
///    request `extra`);
///  - concurrent 401s share a single in-flight refresh via [_refreshCompleter].
class DioClient {
  DioClient(this._tokenStorage, {this.onForcedLogout, HttpClientAdapter? adapter}) {
    _dio = Dio(_baseOptions());
    // Bare client used ONLY to call /auth/refresh — never carries the auth
    // interceptor, preventing infinite refresh recursion.
    _refreshDio = Dio(_baseOptions());
    _dio.interceptors.add(_authInterceptor());
    // Optional transport injection. Both the main and the refresh Dio share it
    // so tests (and any custom transport) cover the full refresh flow.
    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
      _refreshDio.httpClientAdapter = adapter;
    }
  }

  /// Invoked when refresh is impossible/failed and the session must end. Lets
  /// the auth layer reset its state and route back to login.
  final FutureOr<void> Function()? onForcedLogout;

  final TokenStorage _tokenStorage;
  late final Dio _dio;
  late final Dio _refreshDio;

  /// Marks a request that has already been retried after a refresh.
  static const String _retriedFlag = 'retried_after_refresh';

  /// Shared in-flight refresh so simultaneous 401s refresh only once. Resolves
  /// to the new access token, or `null` when refresh failed.
  Completer<String?>? _refreshCompleter;

  Dio get dio => _dio;

  BaseOptions _baseOptions() => BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    contentType: 'application/json',
  );

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final response = error.response;
        final request = error.requestOptions;

        final isUnauthorized = response?.statusCode == 401;
        final alreadyRetried = request.extra[_retriedFlag] == true;

        // Only attempt refresh on a fresh 401 that has not been retried yet.
        if (!isUnauthorized || alreadyRetried) {
          handler.next(error);
          return;
        }

        final newToken = await _refreshAccessToken();
        if (newToken == null) {
          // Refresh failed: tokens are already cleared and logout forced.
          handler.next(error);
          return;
        }

        // Retry the original request exactly once with the fresh token.
        try {
          final retried = await _retry(request, newToken);
          handler.resolve(retried);
        } on DioException catch (e) {
          handler.next(e);
        }
      },
    );
  }

  /// Refreshes the access token, deduplicating concurrent callers. Returns the
  /// new access token, or `null` if refresh was not possible.
  Future<String?> _refreshAccessToken() {
    // Join an already-running refresh.
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;
    unawaited(_doRefresh(completer));
    return completer.future;
  }

  Future<void> _doRefresh(Completer<String?> completer) async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        completer.complete(null);
        return;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      final newAccess = body?['token'] as String?;
      final newRefresh = body?['refreshToken'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        await _forceLogout();
        completer.complete(null);
        return;
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      completer.complete(newAccess);
    } catch (_) {
      await _forceLogout();
      completer.complete(null);
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions request,
    String newToken,
  ) {
    final headers = Map<String, dynamic>.from(request.headers)
      ..['Authorization'] = 'Bearer $newToken';

    return _dio.request<dynamic>(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      cancelToken: request.cancelToken,
      onSendProgress: request.onSendProgress,
      onReceiveProgress: request.onReceiveProgress,
      options: Options(
        method: request.method,
        headers: headers,
        responseType: request.responseType,
        contentType: request.contentType,
        sendTimeout: request.sendTimeout,
        receiveTimeout: request.receiveTimeout,
        followRedirects: request.followRedirects,
        // Mark so a second 401 won't loop back into refresh.
        extra: {...request.extra, _retriedFlag: true},
      ),
    );
  }

  Future<void> _forceLogout() async {
    await _tokenStorage.clear();
    await onForcedLogout?.call();
  }
}

/// Provider exposing the configured [Dio] instance to repositories.
///
/// The forced-logout callback is wired lazily via [setForcedLogoutHandler] to
/// avoid a circular dependency between the Dio client and the auth controller.
final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient(
    tokenStorage,
    onForcedLogout: () => _forcedLogoutHandler?.call(),
  );
});

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);

/// Optional global handler invoked when the Dio client forces a logout. The
/// auth controller registers itself here at construction time. Kept as a
/// top-level hook (rather than a provider dependency) to break the
/// Dio ↔ AuthController cycle.
FutureOr<void> Function()? _forcedLogoutHandler;

void setForcedLogoutHandler(FutureOr<void> Function()? handler) {
  _forcedLogoutHandler = handler;
}
