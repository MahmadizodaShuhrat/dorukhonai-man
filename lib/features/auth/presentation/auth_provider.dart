import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_result.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

/// Authentication UI state.
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final bool isLoading;

  /// The signed-in user (available after login or session restore via
  /// `GET /auth/me`). May be `null` right after a token-only rehydrate.
  final User? user;
  final String? errorMessage;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Holds auth state and orchestrates login/logout. No business logic lives in
/// widgets (TZ §8) — the screen only dispatches to this notifier.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._tokenStorage)
    : super(const AuthState()) {
    // Let the Dio client force a logout when token refresh fails.
    setForcedLogoutHandler(_onForcedLogout);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  /// Re-hydrates auth state from secure storage at startup. If an access token
  /// is present we optimistically mark the session authenticated and try to
  /// load the user profile in the background.
  Future<void> loadSession() async {
    final token = await _tokenStorage.readAccessToken();
    final hasToken = token != null && token.isNotEmpty;
    state = state.copyWith(isAuthenticated: hasToken);
    if (hasToken) {
      final result = await _repository.me();
      if (result case Success(:final data)) {
        state = state.copyWith(user: data);
      }
      // A failure here (e.g. backend offline) keeps the cached session; an
      // actual 401 triggers the refresh/forced-logout path in DioClient.
    }
  }

  Future<bool> login(String userName, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.login(
      userName: userName,
      password: password,
    );
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: data.user,
        );
        return true;
      case Error(:final failure):
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          clearUser: true,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  /// Invoked by [DioClient] when refresh fails and the session must end.
  Future<void> _onForcedLogout() async {
    state = const AuthState();
  }

  @override
  void dispose() {
    setForcedLogoutHandler(null);
    super.dispose();
  }
}

/// Global auth provider consumed by the router redirect and the login screen.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      final tokenStorage = ref.watch(tokenStorageProvider);
      return AuthController(repository, tokenStorage);
    });
