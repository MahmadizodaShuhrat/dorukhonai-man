import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';

/// Server-side app settings (TZ_05 FW6 / NEW-ENDPOINT CONTRACT).
/// `GET /settings -> { markupPercent, expiryAlertDays, ... }`;
/// `PUT /settings { markupPercent?, expiryAlertDays? }`. Persisted server-side
/// in the existing Setting (key/value) table so the expiry job + receipt
/// markup read the same values.
class ServerSettings {
  const ServerSettings({this.markupPercent, this.expiryAlertDays});

  final double? markupPercent;
  final int? expiryAlertDays;

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return ServerSettings(
      markupPercent: (json['markupPercent'] as num?)?.toDouble(),
      expiryAlertDays: (json['expiryAlertDays'] as num?)?.toInt(),
    );
  }
}

/// Read/write access to `/settings`.
abstract interface class SettingsRepository {
  Future<ApiResult<ServerSettings>> get();

  Future<ApiResult<ServerSettings>> update({
    double? markupPercent,
    int? expiryAlertDays,
  });
}

/// Dio-backed implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<ServerSettings>> get() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/settings');
      final body = response.data;
      if (body == null) {
        return const Error(ServerFailure('Ҷавоби холӣ аз сервер.'));
      }
      return Success(ServerSettings.fromJson(body));
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<ApiResult<ServerSettings>> update({
    double? markupPercent,
    int? expiryAlertDays,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/settings',
        data: {
          'markupPercent': ?markupPercent,
          'expiryAlertDays': ?expiryAlertDays,
        },
      );
      final body = response.data;
      return Success(
        body == null
            ? ServerSettings(
                markupPercent: markupPercent,
                expiryAlertDays: expiryAlertDays,
              )
            : ServerSettings.fromJson(body),
      );
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

/// Provider exposing the [SettingsRepository] implementation.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SettingsRepositoryImpl(dio);
});
