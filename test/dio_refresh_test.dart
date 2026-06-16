import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dorukhonai_man/core/api/dio_client.dart';
import 'package:dorukhonai_man/core/constants/app_constants.dart';
import 'package:dorukhonai_man/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scriptable [HttpClientAdapter]: each entry is a function that, given the
/// request, returns the canned [ResponseBody]. Records every request path.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<String> requestedPaths = [];
  final List<Map<String, dynamic>> requestedBodies = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
    final data = options.data;
    if (data is Map<String, dynamic>) requestedBodies.add(data);
    return handler(options);
  }
}

ResponseBody _json(Map<String, dynamic> body, int status) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureData;

  setUp(() {
    secureData = <String, String>{};
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform(secureData);
  });

  test('401 then successful refresh retries the original request once',
      () async {
    secureData[AppConstants.accessTokenKey] = 'old-access';
    secureData[AppConstants.refreshTokenKey] = 'good-refresh';

    var protectedHits = 0;
    final adapter = ScriptedAdapter((options) {
      if (options.path == '/auth/refresh') {
        return _json({'token': 'new-access', 'refreshToken': 'new-refresh'},
            200);
      }
      if (options.path == '/products') {
        protectedHits++;
        // First hit (old token) → 401; the retried hit → 200.
        final auth = options.headers['Authorization'];
        if (auth == 'Bearer new-access') {
          return _json({'items': [], 'total': 0, 'page': 1, 'size': 20}, 200);
        }
        return _json({'message': 'unauthorized'}, 401);
      }
      return _json({}, 200);
    });

    final client = DioClient(TokenStorage(), adapter: adapter);

    final response = await client.dio.get<Map<String, dynamic>>('/products');

    expect(response.statusCode, 200);
    // Original + retry = 2 protected hits.
    expect(protectedHits, 2);
    // Tokens were rotated by the refresh.
    expect(secureData[AppConstants.accessTokenKey], 'new-access');
    expect(secureData[AppConstants.refreshTokenKey], 'new-refresh');
  });

  test('refresh failure forces logout and clears tokens', () async {
    secureData[AppConstants.accessTokenKey] = 'old-access';
    secureData[AppConstants.refreshTokenKey] = 'bad-refresh';

    var loggedOut = false;
    final adapter = ScriptedAdapter((options) {
      if (options.path == '/auth/refresh') {
        return _json({'message': 'invalid refresh'}, 401);
      }
      // protected endpoint always 401.
      return _json({'message': 'unauthorized'}, 401);
    });

    final client = DioClient(
      TokenStorage(),
      onForcedLogout: () => loggedOut = true,
      adapter: adapter,
    );

    await expectLater(
      client.dio.get<Map<String, dynamic>>('/products'),
      throwsA(isA<DioException>()),
    );

    expect(loggedOut, isTrue);
    expect(secureData[AppConstants.accessTokenKey], isNull);
    expect(secureData[AppConstants.refreshTokenKey], isNull);
  });

  test('no refresh token → immediate forced logout, no refresh attempt',
      () async {
    secureData[AppConstants.accessTokenKey] = 'old-access';
    // No refresh token stored.

    var loggedOut = false;
    final adapter = ScriptedAdapter((options) {
      return _json({'message': 'unauthorized'}, 401);
    });

    final client = DioClient(
      TokenStorage(),
      onForcedLogout: () => loggedOut = true,
      adapter: adapter,
    );

    await expectLater(
      client.dio.get<Map<String, dynamic>>('/products'),
      throwsA(isA<DioException>()),
    );

    expect(loggedOut, isTrue);
    // No /auth/refresh call was made.
    expect(adapter.requestedPaths.contains('/auth/refresh'), isFalse);
  });
}
