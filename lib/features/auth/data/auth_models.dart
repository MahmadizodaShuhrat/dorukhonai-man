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
/// Contract: `{ "id": guid, "fullName": string, "userName": string, "role": ...,
/// "branchId": guid? }`. `branchId` is the user's primary branch (the central
/// branch for a single-branch deployment); used to seed the POS/stock branch
/// context (TZ_05 FW1) without any hardcoded id.
class User {
  const User({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.role,
    this.branchId,
  });

  final String id;
  final String fullName;
  final String userName;
  final UserRole role;

  /// Primary branch GUID, when the backend supplies it. `null`/empty falls back
  /// to a `GET /branches` lookup.
  final String? branchId;

  factory User.fromJson(Map<String, dynamic> json) {
    final rawBranch = json['branchId'] as String?;
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      role: UserRole.fromWire(json['role'] as String?),
      branchId: (rawBranch == null || rawBranch.isEmpty) ? null : rawBranch,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'userName': userName,
    'role': role.wire,
    if (branchId != null) 'branchId': branchId,
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
