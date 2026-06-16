/// Error/result types for the data layer.
///
/// Repositories convert Dio errors into a [Failure] so the UI can show a
/// single, consistent message (TZ §4, §8).
library;

/// Base type for all domain failures surfaced to the UI.
sealed class Failure {
  const Failure(this.message);

  /// Human-readable message suitable for a snackbar/dialog.
  final String message;

  @override
  String toString() => 'Failure(message: $message)';
}

/// Network connectivity / timeout problem.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Хатои шабака. Пайвастро санҷед.']);
}

/// Server returned a non-2xx response.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Authentication/authorization problem (401/403).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Иҷозат рад шуд. Дубора ворид шавед.']);
}

/// Anything not covered by the cases above.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Хатои номаълум рух дод.']);
}

/// A simple sealed result type: either [Success] data or a [Failure].
sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends ApiResult<T> {
  const Error(this.failure);
  final Failure failure;
}
