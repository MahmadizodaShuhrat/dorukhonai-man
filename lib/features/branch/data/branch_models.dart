/// Branch (Филиал) models — plain Dart with hand-written `fromJson` (no
/// codegen). Field names match the API contract EXACTLY (camelCase).
library;

/// A pharmacy branch.
///
/// Contract: `{ id, name, address?, phone?, isCentral, isActive }`.
class Branch {
  const Branch({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.isCentral = false,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? address;
  final String? phone;
  final bool isCentral;
  final bool isActive;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isCentral: json['isCentral'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
