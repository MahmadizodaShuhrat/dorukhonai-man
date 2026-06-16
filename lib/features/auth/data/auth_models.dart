/// Auth domain models — plain Dart with hand-written `fromJson`/`toJson`
/// (no codegen, per project rules). Field names match the API contract EXACTLY.
library;

/// User roles defined by the API contract.
enum UserRole {
  admin('Admin'),
  manager('Manager'),
  seller('Seller'),
  storekeeper('Storekeeper');

  const UserRole(this.wire);

  /// The exact string the API uses on the wire.
  final String wire;

  /// Parses the contract role string; unknown values fall back to [seller]
  /// (the least-privileged role) so the app fails safe.
  static UserRole fromWire(String? value) {
    for (final role in UserRole.values) {
      if (role.wire == value) return role;
    }
    return UserRole.seller;
  }
}

/// Authenticated user.
/// Contract: `{ "id": guid, "fullName": string, "userName": string, "role": ... }`.
class User {
  const User({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.role,
  });

  final String id;
  final String fullName;
  final String userName;
  final UserRole role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      role: UserRole.fromWire(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'userName': userName,
    'role': role.wire,
  };
}

/// Response of `POST /auth/login`.
/// Contract: `{ "token", "refreshToken", "user": { ... } }`.
class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  final String token;
  final String refreshToken;
  final User user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };
}

/// Response of `POST /auth/refresh`.
/// Contract: `{ "token", "refreshToken" }`.
class RefreshResponse {
  const RefreshResponse({required this.token, required this.refreshToken});

  final String token;
  final String refreshToken;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
  };
}
