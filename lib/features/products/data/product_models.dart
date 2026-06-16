/// Reference-data models — plain Dart with hand-written `fromJson`/`toJson`
/// (no codegen). Field names match the API contract EXACTLY.
library;

/// Drug product card.
/// Contract: `{ id, name, barcode?, drugGroupId?, manufacturerId?, unitId?,
/// rxRequired: bool, isActive: bool, minStockLevel?: decimal }`.
class Product {
  const Product({
    required this.id,
    required this.name,
    this.barcode,
    this.drugGroupId,
    this.manufacturerId,
    this.unitId,
    this.rxRequired = false,
    this.isActive = true,
    this.minStockLevel,
  });

  final String id;
  final String name;
  final String? barcode;
  final String? drugGroupId;
  final String? manufacturerId;
  final String? unitId;
  final bool rxRequired;
  final bool isActive;

  /// Optional reorder threshold; when total stock falls below this the product
  /// is reported by `GET /stock/low`. `null` means "not tracked".
  final double? minStockLevel;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      barcode: json['barcode'] as String?,
      drugGroupId: json['drugGroupId'] as String?,
      manufacturerId: json['manufacturerId'] as String?,
      unitId: json['unitId'] as String?,
      rxRequired: json['rxRequired'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble(),
    );
  }

  /// Payload for create/update. `id` is omitted on create (the server assigns
  /// it) — see [ProductsRepository].
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'barcode': barcode,
    'drugGroupId': drugGroupId,
    'manufacturerId': manufacturerId,
    'unitId': unitId,
    'rxRequired': rxRequired,
    'isActive': isActive,
    'minStockLevel': minStockLevel,
  };

  Product copyWith({
    String? id,
    String? name,
    String? Function()? barcode,
    String? Function()? drugGroupId,
    String? Function()? manufacturerId,
    String? Function()? unitId,
    bool? rxRequired,
    bool? isActive,
    double? Function()? minStockLevel,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode != null ? barcode() : this.barcode,
      drugGroupId: drugGroupId != null ? drugGroupId() : this.drugGroupId,
      manufacturerId:
          manufacturerId != null ? manufacturerId() : this.manufacturerId,
      unitId: unitId != null ? unitId() : this.unitId,
      rxRequired: rxRequired ?? this.rxRequired,
      isActive: isActive ?? this.isActive,
      minStockLevel:
          minStockLevel != null ? minStockLevel() : this.minStockLevel,
    );
  }
}

/// Drug group. Contract: `{ id, name, parentId? }`.
class DrugGroup {
  const DrugGroup({required this.id, required this.name, this.parentId});

  final String id;
  final String name;
  final String? parentId;

  factory DrugGroup.fromJson(Map<String, dynamic> json) {
    return DrugGroup(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parentId': parentId,
  };
}

/// Manufacturer. Contract: `{ id, name, country? }`.
class Manufacturer {
  const Manufacturer({required this.id, required this.name, this.country});

  final String id;
  final String name;
  final String? country;

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
  };
}

/// Supplier. Contract: `{ id, name, inn?, phone?, address? }`.
class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.inn,
    this.phone,
    this.address,
  });

  final String id;
  final String name;
  final String? inn;
  final String? phone;
  final String? address;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      inn: json['inn'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'inn': inn,
    'phone': phone,
    'address': address,
  };
}

/// Unit of measure. Contract: `{ id, name }`.
class Unit {
  const Unit({required this.id, required this.name});

  final String id;
  final String name;

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
