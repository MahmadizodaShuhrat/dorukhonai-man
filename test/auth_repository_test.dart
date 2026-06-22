import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/constants/app_constants.dart';
import 'package:dorukhonai_man/core/storage/token_storage.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal scripted adapter returning a single canned response, recording the
/// request body so contract field names can be asserted.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.response);

  final ResponseBody Function(RequestOptions options) response;
  Object? lastBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastBody = options.data;
    return response(options);
  }
}

ResponseBody _json(Map<String, dynamic> body, int status) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureData;

  setUp(() {
    secureData = <String, String>{};
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform(secureData);
  });

  test('login sends userName (contract) and persists token + refreshToken',
      () async {
    final adapter = _Adapter(
      (_) => _json({
        'token': 'access-xyz',
        'refreshToken': 'refresh-xyz',
        'user': {
          'id': 'u1',
          'fullName': 'Админ Админ',
          'userName': 'admin',
          'role': 'Admin',
        },
      }, 200),
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api/v1'))
      ..httpClientAdapter = adapter;
    final repo = AuthRepositoryImpl(dio, TokenStorage());

    final result = await repo.login(userName: 'admin', password: 'Admin123!');

    expect(result, isA<Success<dynamic>>());
    // Contract: request body uses "userName" (not "username").
    final body = adapter.lastBody as Map<String, dynamic>;
    expect(body.containsKey('userName'), isTrue);
    expect(body['userName'], 'admin');
    expect(body['password'], 'Admin123!');
    // Tokens persisted to secure storage.
    expect(secureData[AppConstants.accessTokenKey], 'access-xyz');
    expect(secureData[AppConstants.refreshTokenKey], 'refresh-xyz');
  });

  test('401 maps to AuthFailure with the credential message', () async {
    final adapter = _Adapter((_) => _json({'message': 'bad'}, 401));
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api/v1'))
      ..httpClientAdapter = adapter;
    final repo = AuthRepositoryImpl(dio, TokenStorage());

    final result = await repo.login(userName: 'admin', password: 'wrong');

    expect(result, isA<Error<dynamic>>());
    final failure = (result as Error).failure;
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Логин ё парол нодуруст аст.');
    expect(secureData[AppConstants.accessTokenKey], isNull);
  });

  test('logout clears tokens even when the server call fails', () async {
    secureData[AppConstants.accessTokenKey] = 'a';
    secureData[AppConstants.refreshTokenKey] = 'r';
    final adapter = _Adapter((_) => _json({'message': 'err'}, 500));
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api/v1'))
      ..httpClientAdapter = adapter;
    final repo = AuthRepositoryImpl(dio, TokenStorage());

    await repo.logout();

    expect(secureData[AppConstants.accessTokenKey], isNull);
    expect(secureData[AppConstants.refreshTokenKey], isNull);
  });
}
