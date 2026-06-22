// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedProductsTable extends CachedProducts
    with TableInfo<$CachedProductsTable, CachedProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drugGroupIdMeta = const VerificationMeta(
    'drugGroupId',
  );
  @override
  late final GeneratedColumn<String> drugGroupId = GeneratedColumn<String>(
    'drug_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufacturerIdMeta = const VerificationMeta(
    'manufacturerId',
  );
  @override
  late final GeneratedColumn<String> manufacturerId = GeneratedColumn<String>(
    'manufacturer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rxRequiredMeta = const VerificationMeta(
    'rxRequired',
  );
  @override
  late final GeneratedColumn<bool> rxRequired = GeneratedColumn<bool>(
    'rx_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rx_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _minStockLevelMeta = const VerificationMeta(
    'minStockLevel',
  );
  @override
  late final GeneratedColumn<double> minStockLevel = GeneratedColumn<double>(
    'min_stock_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    barcode,
    drugGroupId,
    manufacturerId,
    unitId,
    rxRequired,
    isActive,
    minStockLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('drug_group_id')) {
      context.handle(
        _drugGroupIdMeta,
        drugGroupId.isAcceptableOrUnknown(
          data['drug_group_id']!,
          _drugGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('manufacturer_id')) {
      context.handle(
        _manufacturerIdMeta,
        manufacturerId.isAcceptableOrUnknown(
          data['manufacturer_id']!,
          _manufacturerIdMeta,
        ),
      );
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    }
    if (data.containsKey('rx_required')) {
      context.handle(
        _rxRequiredMeta,
        rxRequired.isAcceptableOrUnknown(data['rx_required']!, _rxRequiredMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('min_stock_level')) {
      context.handle(
        _minStockLevelMeta,
        minStockLevel.isAcceptableOrUnknown(
          data['min_stock_level']!,
          _minStockLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      drugGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_group_id'],
      ),
      manufacturerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer_id'],
      ),
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      ),
      rxRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rx_required'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      minStockLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_stock_level'],
      ),
    );
  }

  @override
  $CachedProductsTable createAlias(String alias) {
    return $CachedProductsTable(attachedDatabase, alias);
  }
}

class CachedProduct extends DataClass implements Insertable<CachedProduct> {
  final String id;
  final String name;
  final String? barcode;
  final String? drugGroupId;
  final String? manufacturerId;
  final String? unitId;
  final bool rxRequired;
  final bool isActive;
  final double? minStockLevel;
  const CachedProduct({
    required this.id,
    required this.name,
    this.barcode,
    this.drugGroupId,
    this.manufacturerId,
    this.unitId,
    required this.rxRequired,
    required this.isActive,
    this.minStockLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || drugGroupId != null) {
      map['drug_group_id'] = Variable<String>(drugGroupId);
    }
    if (!nullToAbsent || manufacturerId != null) {
      map['manufacturer_id'] = Variable<String>(manufacturerId);
    }
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    map['rx_required'] = Variable<bool>(rxRequired);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || minStockLevel != null) {
      map['min_stock_level'] = Variable<double>(minStockLevel);
    }
    return map;
  }

  CachedProductsCompanion toCompanion(bool nullToAbsent) {
    return CachedProductsCompanion(
      id: Value(id),
      name: Value(name),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      drugGroupId: drugGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(drugGroupId),
      manufacturerId: manufacturerId == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturerId),
      unitId: unitId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitId),
      rxRequired: Value(rxRequired),
      isActive: Value(isActive),
      minStockLevel: minStockLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(minStockLevel),
    );
  }

  factory CachedProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProduct(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      drugGroupId: serializer.fromJson<String?>(json['drugGroupId']),
      manufacturerId: serializer.fromJson<String?>(json['manufacturerId']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      rxRequired: serializer.fromJson<bool>(json['rxRequired']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      minStockLevel: serializer.fromJson<double?>(json['minStockLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String?>(barcode),
      'drugGroupId': serializer.toJson<String?>(drugGroupId),
      'manufacturerId': serializer.toJson<String?>(manufacturerId),
      'unitId': serializer.toJson<String?>(unitId),
      'rxRequired': serializer.toJson<bool>(rxRequired),
      'isActive': serializer.toJson<bool>(isActive),
      'minStockLevel': serializer.toJson<double?>(minStockLevel),
    };
  }

  CachedProduct copyWith({
    String? id,
    String? name,
    Value<String?> barcode = const Value.absent(),
    Value<String?> drugGroupId = const Value.absent(),
    Value<String?> manufacturerId = const Value.absent(),
    Value<String?> unitId = const Value.absent(),
    bool? rxRequired,
    bool? isActive,
    Value<double?> minStockLevel = const Value.absent(),
  }) => CachedProduct(
    id: id ?? this.id,
    name: name ?? this.name,
    barcode: barcode.present ? barcode.value : this.barcode,
    drugGroupId: drugGroupId.present ? drugGroupId.value : this.drugGroupId,
    manufacturerId: manufacturerId.present
        ? manufacturerId.value
        : this.manufacturerId,
    unitId: unitId.present ? unitId.value : this.unitId,
    rxRequired: rxRequired ?? this.rxRequired,
    isActive: isActive ?? this.isActive,
    minStockLevel: minStockLevel.present
        ? minStockLevel.value
        : this.minStockLevel,
  );
  CachedProduct copyWithCompanion(CachedProductsCompanion data) {
    return CachedProduct(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      drugGroupId: data.drugGroupId.present
          ? data.drugGroupId.value
          : this.drugGroupId,
      manufacturerId: data.manufacturerId.present
          ? data.manufacturerId.value
          : this.manufacturerId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      rxRequired: data.rxRequired.present
          ? data.rxRequired.value
          : this.rxRequired,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      minStockLevel: data.minStockLevel.present
          ? data.minStockLevel.value
          : this.minStockLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProduct(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('drugGroupId: $drugGroupId, ')
          ..write('manufacturerId: $manufacturerId, ')
          ..write('unitId: $unitId, ')
          ..write('rxRequired: $rxRequired, ')
          ..write('isActive: $isActive, ')
          ..write('minStockLevel: $minStockLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    barcode,
    drugGroupId,
    manufacturerId,
    unitId,
    rxRequired,
    isActive,
    minStockLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProduct &&
          other.id == this.id &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.drugGroupId == this.drugGroupId &&
          other.manufacturerId == this.manufacturerId &&
          other.unitId == this.unitId &&
          other.rxRequired == this.rxRequired &&
          other.isActive == this.isActive &&
          other.minStockLevel == this.minStockLevel);
}

class CachedProductsCompanion extends UpdateCompanion<CachedProduct> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> barcode;
  final Value<String?> drugGroupId;
  final Value<String?> manufacturerId;
  final Value<String?> unitId;
  final Value<bool> rxRequired;
  final Value<bool> isActive;
  final Value<double?> minStockLevel;
  final Value<int> rowid;
  const CachedProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.drugGroupId = const Value.absent(),
    this.manufacturerId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.rxRequired = const Value.absent(),
    this.isActive = const Value.absent(),
    this.minStockLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProductsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.drugGroupId = const Value.absent(),
    this.manufacturerId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.rxRequired = const Value.absent(),
    this.isActive = const Value.absent(),
    this.minStockLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedProduct> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<String>? drugGroupId,
    Expression<String>? manufacturerId,
    Expression<String>? unitId,
    Expression<bool>? rxRequired,
    Expression<bool>? isActive,
    Expression<double>? minStockLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (drugGroupId != null) 'drug_group_id': drugGroupId,
      if (manufacturerId != null) 'manufacturer_id': manufacturerId,
      if (unitId != null) 'unit_id': unitId,
      if (rxRequired != null) 'rx_required': rxRequired,
      if (isActive != null) 'is_active': isActive,
      if (minStockLevel != null) 'min_stock_level': minStockLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? barcode,
    Value<String?>? drugGroupId,
    Value<String?>? manufacturerId,
    Value<String?>? unitId,
    Value<bool>? rxRequired,
    Value<bool>? isActive,
    Value<double?>? minStockLevel,
    Value<int>? rowid,
  }) {
    return CachedProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      drugGroupId: drugGroupId ?? this.drugGroupId,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      unitId: unitId ?? this.unitId,
      rxRequired: rxRequired ?? this.rxRequired,
      isActive: isActive ?? this.isActive,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (drugGroupId.present) {
      map['drug_group_id'] = Variable<String>(drugGroupId.value);
    }
    if (manufacturerId.present) {
      map['manufacturer_id'] = Variable<String>(manufacturerId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (rxRequired.present) {
      map['rx_required'] = Variable<bool>(rxRequired.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (minStockLevel.present) {
      map['min_stock_level'] = Variable<double>(minStockLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('drugGroupId: $drugGroupId, ')
          ..write('manufacturerId: $manufacturerId, ')
          ..write('unitId: $unitId, ')
          ..write('rxRequired: $rxRequired, ')
          ..write('isActive: $isActive, ')
          ..write('minStockLevel: $minStockLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedDrugGroupsTable extends CachedDrugGroups
    with TableInfo<$CachedDrugGroupsTable, CachedDrugGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDrugGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_drug_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDrugGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDrugGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDrugGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $CachedDrugGroupsTable createAlias(String alias) {
    return $CachedDrugGroupsTable(attachedDatabase, alias);
  }
}

class CachedDrugGroup extends DataClass implements Insertable<CachedDrugGroup> {
  final String id;
  final String name;
  final String? parentId;
  const CachedDrugGroup({required this.id, required this.name, this.parentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  CachedDrugGroupsCompanion toCompanion(bool nullToAbsent) {
    return CachedDrugGroupsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory CachedDrugGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDrugGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  CachedDrugGroup copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
  }) => CachedDrugGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  CachedDrugGroup copyWithCompanion(CachedDrugGroupsCompanion data) {
    return CachedDrugGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDrugGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDrugGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId);
}

class CachedDrugGroupsCompanion extends UpdateCompanion<CachedDrugGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> rowid;
  const CachedDrugGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedDrugGroupsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedDrugGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedDrugGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return CachedDrugGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDrugGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedManufacturersTable extends CachedManufacturers
    with TableInfo<$CachedManufacturersTable, CachedManufacturer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedManufacturersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, country];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_manufacturers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedManufacturer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedManufacturer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedManufacturer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
    );
  }

  @override
  $CachedManufacturersTable createAlias(String alias) {
    return $CachedManufacturersTable(attachedDatabase, alias);
  }
}

class CachedManufacturer extends DataClass
    implements Insertable<CachedManufacturer> {
  final String id;
  final String name;
  final String? country;
  const CachedManufacturer({
    required this.id,
    required this.name,
    this.country,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    return map;
  }

  CachedManufacturersCompanion toCompanion(bool nullToAbsent) {
    return CachedManufacturersCompanion(
      id: Value(id),
      name: Value(name),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
    );
  }

  factory CachedManufacturer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedManufacturer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      country: serializer.fromJson<String?>(json['country']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'country': serializer.toJson<String?>(country),
    };
  }

  CachedManufacturer copyWith({
    String? id,
    String? name,
    Value<String?> country = const Value.absent(),
  }) => CachedManufacturer(
    id: id ?? this.id,
    name: name ?? this.name,
    country: country.present ? country.value : this.country,
  );
  CachedManufacturer copyWithCompanion(CachedManufacturersCompanion data) {
    return CachedManufacturer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      country: data.country.present ? data.country.value : this.country,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedManufacturer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, country);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedManufacturer &&
          other.id == this.id &&
          other.name == this.name &&
          other.country == this.country);
}

class CachedManufacturersCompanion extends UpdateCompanion<CachedManufacturer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> country;
  final Value<int> rowid;
  const CachedManufacturersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.country = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedManufacturersCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.country = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedManufacturer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? country,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (country != null) 'country': country,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedManufacturersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? country,
    Value<int>? rowid,
  }) {
    return CachedManufacturersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedManufacturersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedUnitsTable extends CachedUnits
    with TableInfo<$CachedUnitsTable, CachedUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUnit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedUnitsTable createAlias(String alias) {
    return $CachedUnitsTable(attachedDatabase, alias);
  }
}

class CachedUnit extends DataClass implements Insertable<CachedUnit> {
  final String id;
  final String name;
  const CachedUnit({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedUnitsCompanion toCompanion(bool nullToAbsent) {
    return CachedUnitsCompanion(id: Value(id), name: Value(name));
  }

  factory CachedUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUnit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedUnit copyWith({String? id, String? name}) =>
      CachedUnit(id: id ?? this.id, name: name ?? this.name);
  CachedUnit copyWithCompanion(CachedUnitsCompanion data) {
    return CachedUnit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUnit(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUnit && other.id == this.id && other.name == this.name);
}

class CachedUnitsCompanion extends UpdateCompanion<CachedUnit> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CachedUnitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUnitsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedUnit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CachedUnitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUnitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSuppliersTable extends CachedSuppliers
    with TableInfo<$CachedSuppliersTable, CachedSupplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _innMeta = const VerificationMeta('inn');
  @override
  late final GeneratedColumn<String> inn = GeneratedColumn<String>(
    'inn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, inn, phone, address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSupplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('inn')) {
      context.handle(
        _innMeta,
        inn.isAcceptableOrUnknown(data['inn']!, _innMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSupplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSupplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      inn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inn'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $CachedSuppliersTable createAlias(String alias) {
    return $CachedSuppliersTable(attachedDatabase, alias);
  }
}

class CachedSupplier extends DataClass implements Insertable<CachedSupplier> {
  final String id;
  final String name;
  final String? inn;
  final String? phone;
  final String? address;
  const CachedSupplier({
    required this.id,
    required this.name,
    this.inn,
    this.phone,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || inn != null) {
      map['inn'] = Variable<String>(inn);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  CachedSuppliersCompanion toCompanion(bool nullToAbsent) {
    return CachedSuppliersCompanion(
      id: Value(id),
      name: Value(name),
      inn: inn == null && nullToAbsent ? const Value.absent() : Value(inn),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory CachedSupplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSupplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      inn: serializer.fromJson<String?>(json['inn']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'inn': serializer.toJson<String?>(inn),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
    };
  }

  CachedSupplier copyWith({
    String? id,
    String? name,
    Value<String?> inn = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => CachedSupplier(
    id: id ?? this.id,
    name: name ?? this.name,
    inn: inn.present ? inn.value : this.inn,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
  );
  CachedSupplier copyWithCompanion(CachedSuppliersCompanion data) {
    return CachedSupplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      inn: data.inn.present ? data.inn.value : this.inn,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSupplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('inn: $inn, ')
          ..write('phone: $phone, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, inn, phone, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSupplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.inn == this.inn &&
          other.phone == this.phone &&
          other.address == this.address);
}

class CachedSuppliersCompanion extends UpdateCompanion<CachedSupplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> inn;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<int> rowid;
  const CachedSuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.inn = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSuppliersCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.inn = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedSupplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? inn,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (inn != null) 'inn': inn,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? inn,
    Value<String?>? phone,
    Value<String?>? address,
    Value<int>? rowid,
  }) {
    return CachedSuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      inn: inn ?? this.inn,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (inn.present) {
      map['inn'] = Variable<String>(inn.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('inn: $inn, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBatchesTable extends CachedBatches
    with TableInfo<$CachedBatchesTable, CachedBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesNumberMeta = const VerificationMeta(
    'seriesNumber',
  );
  @override
  late final GeneratedColumn<String> seriesNumber = GeneratedColumn<String>(
    'series_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    seriesNumber,
    expiryDate,
    salePrice,
    purchasePrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('series_number')) {
      context.handle(
        _seriesNumberMeta,
        seriesNumber.isAcceptableOrUnknown(
          data['series_number']!,
          _seriesNumberMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBatche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      seriesNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_number'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_price'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
    );
  }

  @override
  $CachedBatchesTable createAlias(String alias) {
    return $CachedBatchesTable(attachedDatabase, alias);
  }
}

class CachedBatche extends DataClass implements Insertable<CachedBatche> {
  final String id;
  final String productId;
  final String seriesNumber;
  final DateTime expiryDate;
  final double salePrice;
  final double purchasePrice;
  const CachedBatche({
    required this.id,
    required this.productId,
    required this.seriesNumber,
    required this.expiryDate,
    required this.salePrice,
    required this.purchasePrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['series_number'] = Variable<String>(seriesNumber);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['sale_price'] = Variable<double>(salePrice);
    map['purchase_price'] = Variable<double>(purchasePrice);
    return map;
  }

  CachedBatchesCompanion toCompanion(bool nullToAbsent) {
    return CachedBatchesCompanion(
      id: Value(id),
      productId: Value(productId),
      seriesNumber: Value(seriesNumber),
      expiryDate: Value(expiryDate),
      salePrice: Value(salePrice),
      purchasePrice: Value(purchasePrice),
    );
  }

  factory CachedBatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBatche(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      seriesNumber: serializer.fromJson<String>(json['seriesNumber']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'seriesNumber': serializer.toJson<String>(seriesNumber),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'salePrice': serializer.toJson<double>(salePrice),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
    };
  }

  CachedBatche copyWith({
    String? id,
    String? productId,
    String? seriesNumber,
    DateTime? expiryDate,
    double? salePrice,
    double? purchasePrice,
  }) => CachedBatche(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    seriesNumber: seriesNumber ?? this.seriesNumber,
    expiryDate: expiryDate ?? this.expiryDate,
    salePrice: salePrice ?? this.salePrice,
    purchasePrice: purchasePrice ?? this.purchasePrice,
  );
  CachedBatche copyWithCompanion(CachedBatchesCompanion data) {
    return CachedBatche(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      seriesNumber: data.seriesNumber.present
          ? data.seriesNumber.value
          : this.seriesNumber,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBatche(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('seriesNumber: $seriesNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('salePrice: $salePrice, ')
          ..write('purchasePrice: $purchasePrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    seriesNumber,
    expiryDate,
    salePrice,
    purchasePrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBatche &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.seriesNumber == this.seriesNumber &&
          other.expiryDate == this.expiryDate &&
          other.salePrice == this.salePrice &&
          other.purchasePrice == this.purchasePrice);
}

class CachedBatchesCompanion extends UpdateCompanion<CachedBatche> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> seriesNumber;
  final Value<DateTime> expiryDate;
  final Value<double> salePrice;
  final Value<double> purchasePrice;
  final Value<int> rowid;
  const CachedBatchesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.seriesNumber = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBatchesCompanion.insert({
    required String id,
    required String productId,
    this.seriesNumber = const Value.absent(),
    required DateTime expiryDate,
    this.salePrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       expiryDate = Value(expiryDate);
  static Insertable<CachedBatche> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? seriesNumber,
    Expression<DateTime>? expiryDate,
    Expression<double>? salePrice,
    Expression<double>? purchasePrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (seriesNumber != null) 'series_number': seriesNumber,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (salePrice != null) 'sale_price': salePrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? seriesNumber,
    Value<DateTime>? expiryDate,
    Value<double>? salePrice,
    Value<double>? purchasePrice,
    Value<int>? rowid,
  }) {
    return CachedBatchesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      seriesNumber: seriesNumber ?? this.seriesNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (seriesNumber.present) {
      map['series_number'] = Variable<String>(seriesNumber.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBatchesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('seriesNumber: $seriesNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('salePrice: $salePrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedStockTable extends CachedStock
    with TableInfo<$CachedStockTable, CachedStockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    branchId,
    batchId,
    productId,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_stock';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedStockData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {branchId, batchId};
  @override
  CachedStockData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedStockData(
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $CachedStockTable createAlias(String alias) {
    return $CachedStockTable(attachedDatabase, alias);
  }
}

class CachedStockData extends DataClass implements Insertable<CachedStockData> {
  final String branchId;
  final String batchId;
  final String productId;
  final double quantity;
  const CachedStockData({
    required this.branchId,
    required this.batchId,
    required this.productId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['branch_id'] = Variable<String>(branchId);
    map['batch_id'] = Variable<String>(batchId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  CachedStockCompanion toCompanion(bool nullToAbsent) {
    return CachedStockCompanion(
      branchId: Value(branchId),
      batchId: Value(batchId),
      productId: Value(productId),
      quantity: Value(quantity),
    );
  }

  factory CachedStockData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedStockData(
      branchId: serializer.fromJson<String>(json['branchId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'branchId': serializer.toJson<String>(branchId),
      'batchId': serializer.toJson<String>(batchId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  CachedStockData copyWith({
    String? branchId,
    String? batchId,
    String? productId,
    double? quantity,
  }) => CachedStockData(
    branchId: branchId ?? this.branchId,
    batchId: batchId ?? this.batchId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
  );
  CachedStockData copyWithCompanion(CachedStockCompanion data) {
    return CachedStockData(
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedStockData(')
          ..write('branchId: $branchId, ')
          ..write('batchId: $batchId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(branchId, batchId, productId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedStockData &&
          other.branchId == this.branchId &&
          other.batchId == this.batchId &&
          other.productId == this.productId &&
          other.quantity == this.quantity);
}

class CachedStockCompanion extends UpdateCompanion<CachedStockData> {
  final Value<String> branchId;
  final Value<String> batchId;
  final Value<String> productId;
  final Value<double> quantity;
  final Value<int> rowid;
  const CachedStockCompanion({
    this.branchId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedStockCompanion.insert({
    required String branchId,
    required String batchId,
    required String productId,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : branchId = Value(branchId),
       batchId = Value(batchId),
       productId = Value(productId);
  static Insertable<CachedStockData> custom({
    Expression<String>? branchId,
    Expression<String>? batchId,
    Expression<String>? productId,
    Expression<double>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (branchId != null) 'branch_id': branchId,
      if (batchId != null) 'batch_id': batchId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedStockCompanion copyWith({
    Value<String>? branchId,
    Value<String>? batchId,
    Value<String>? productId,
    Value<double>? quantity,
    Value<int>? rowid,
  }) {
    return CachedStockCompanion(
      branchId: branchId ?? this.branchId,
      batchId: batchId ?? this.batchId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedStockCompanion(')
          ..write('branchId: $branchId, ')
          ..write('batchId: $batchId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxSalesTable extends OutboxSales
    with TableInfo<$OutboxSalesTable, OutboxSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(outboxStatusQueued),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSaleIdMeta = const VerificationMeta(
    'serverSaleId',
  );
  @override
  late final GeneratedColumn<String> serverSaleId = GeneratedColumn<String>(
    'server_sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictMessageMeta = const VerificationMeta(
    'conflictMessage',
  );
  @override
  late final GeneratedColumn<String> conflictMessage = GeneratedColumn<String>(
    'conflict_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    clientId,
    branchId,
    payloadJson,
    status,
    createdAt,
    attemptCount,
    lastAttemptAt,
    serverSaleId,
    conflictMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxSale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('server_sale_id')) {
      context.handle(
        _serverSaleIdMeta,
        serverSaleId.isAcceptableOrUnknown(
          data['server_sale_id']!,
          _serverSaleIdMeta,
        ),
      );
    }
    if (data.containsKey('conflict_message')) {
      context.handle(
        _conflictMessageMeta,
        conflictMessage.isAcceptableOrUnknown(
          data['conflict_message']!,
          _conflictMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxSale(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      serverSaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_sale_id'],
      ),
      conflictMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_message'],
      ),
    );
  }

  @override
  $OutboxSalesTable createAlias(String alias) {
    return $OutboxSalesTable(attachedDatabase, alias);
  }
}

class OutboxSale extends DataClass implements Insertable<OutboxSale> {
  /// Auto-increment guarantees FIFO drain order.
  final int seq;

  /// Client-generated Guid; the server idempotency key.
  final String clientId;
  final String branchId;

  /// Full sale payload (lines, payments, discount, createdAt) as JSON.
  final String payloadJson;

  /// `queued` | `pushed` | `conflict`. `pushed`/`duplicate` rows are deleted;
  /// `conflict` rows are kept for the reconciliation surface.
  final String status;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? lastAttemptAt;

  /// Server-assigned sale id once accepted (for display / future returns).
  final String? serverSaleId;

  /// Human-readable reason when [status] is `conflict`.
  final String? conflictMessage;
  const OutboxSale({
    required this.seq,
    required this.clientId,
    required this.branchId,
    required this.payloadJson,
    required this.status,
    required this.createdAt,
    required this.attemptCount,
    this.lastAttemptAt,
    this.serverSaleId,
    this.conflictMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['client_id'] = Variable<String>(clientId);
    map['branch_id'] = Variable<String>(branchId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || serverSaleId != null) {
      map['server_sale_id'] = Variable<String>(serverSaleId);
    }
    if (!nullToAbsent || conflictMessage != null) {
      map['conflict_message'] = Variable<String>(conflictMessage);
    }
    return map;
  }

  OutboxSalesCompanion toCompanion(bool nullToAbsent) {
    return OutboxSalesCompanion(
      seq: Value(seq),
      clientId: Value(clientId),
      branchId: Value(branchId),
      payloadJson: Value(payloadJson),
      status: Value(status),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      serverSaleId: serverSaleId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSaleId),
      conflictMessage: conflictMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictMessage),
    );
  }

  factory OutboxSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxSale(
      seq: serializer.fromJson<int>(json['seq']),
      clientId: serializer.fromJson<String>(json['clientId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      serverSaleId: serializer.fromJson<String?>(json['serverSaleId']),
      conflictMessage: serializer.fromJson<String?>(json['conflictMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'clientId': serializer.toJson<String>(clientId),
      'branchId': serializer.toJson<String>(branchId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'serverSaleId': serializer.toJson<String?>(serverSaleId),
      'conflictMessage': serializer.toJson<String?>(conflictMessage),
    };
  }

  OutboxSale copyWith({
    int? seq,
    String? clientId,
    String? branchId,
    String? payloadJson,
    String? status,
    DateTime? createdAt,
    int? attemptCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> serverSaleId = const Value.absent(),
    Value<String?> conflictMessage = const Value.absent(),
  }) => OutboxSale(
    seq: seq ?? this.seq,
    clientId: clientId ?? this.clientId,
    branchId: branchId ?? this.branchId,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    serverSaleId: serverSaleId.present ? serverSaleId.value : this.serverSaleId,
    conflictMessage: conflictMessage.present
        ? conflictMessage.value
        : this.conflictMessage,
  );
  OutboxSale copyWithCompanion(OutboxSalesCompanion data) {
    return OutboxSale(
      seq: data.seq.present ? data.seq.value : this.seq,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      serverSaleId: data.serverSaleId.present
          ? data.serverSaleId.value
          : this.serverSaleId,
      conflictMessage: data.conflictMessage.present
          ? data.conflictMessage.value
          : this.conflictMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxSale(')
          ..write('seq: $seq, ')
          ..write('clientId: $clientId, ')
          ..write('branchId: $branchId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('serverSaleId: $serverSaleId, ')
          ..write('conflictMessage: $conflictMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    clientId,
    branchId,
    payloadJson,
    status,
    createdAt,
    attemptCount,
    lastAttemptAt,
    serverSaleId,
    conflictMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxSale &&
          other.seq == this.seq &&
          other.clientId == this.clientId &&
          other.branchId == this.branchId &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.serverSaleId == this.serverSaleId &&
          other.conflictMessage == this.conflictMessage);
}

class OutboxSalesCompanion extends UpdateCompanion<OutboxSale> {
  final Value<int> seq;
  final Value<String> clientId;
  final Value<String> branchId;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> serverSaleId;
  final Value<String?> conflictMessage;
  const OutboxSalesCompanion({
    this.seq = const Value.absent(),
    this.clientId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.serverSaleId = const Value.absent(),
    this.conflictMessage = const Value.absent(),
  });
  OutboxSalesCompanion.insert({
    this.seq = const Value.absent(),
    required String clientId,
    required String branchId,
    required String payloadJson,
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.serverSaleId = const Value.absent(),
    this.conflictMessage = const Value.absent(),
  }) : clientId = Value(clientId),
       branchId = Value(branchId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxSale> custom({
    Expression<int>? seq,
    Expression<String>? clientId,
    Expression<String>? branchId,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? serverSaleId,
    Expression<String>? conflictMessage,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (clientId != null) 'client_id': clientId,
      if (branchId != null) 'branch_id': branchId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (serverSaleId != null) 'server_sale_id': serverSaleId,
      if (conflictMessage != null) 'conflict_message': conflictMessage,
    });
  }

  OutboxSalesCompanion copyWith({
    Value<int>? seq,
    Value<String>? clientId,
    Value<String>? branchId,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? serverSaleId,
    Value<String?>? conflictMessage,
  }) {
    return OutboxSalesCompanion(
      seq: seq ?? this.seq,
      clientId: clientId ?? this.clientId,
      branchId: branchId ?? this.branchId,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      serverSaleId: serverSaleId ?? this.serverSaleId,
      conflictMessage: conflictMessage ?? this.conflictMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (serverSaleId.present) {
      map['server_sale_id'] = Variable<String>(serverSaleId.value);
    }
    if (conflictMessage.present) {
      map['conflict_message'] = Variable<String>(conflictMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxSalesCompanion(')
          ..write('seq: $seq, ')
          ..write('clientId: $clientId, ')
          ..write('branchId: $branchId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('serverSaleId: $serverSaleId, ')
          ..write('conflictMessage: $conflictMessage')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceMeta = const VerificationMeta(
    'resource',
  );
  @override
  late final GeneratedColumn<String> resource = GeneratedColumn<String>(
    'resource',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sinceTokenMeta = const VerificationMeta(
    'sinceToken',
  );
  @override
  late final GeneratedColumn<String> sinceToken = GeneratedColumn<String>(
    'since_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [resource, sinceToken, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource')) {
      context.handle(
        _resourceMeta,
        resource.isAcceptableOrUnknown(data['resource']!, _resourceMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceMeta);
    }
    if (data.containsKey('since_token')) {
      context.handle(
        _sinceTokenMeta,
        sinceToken.isAcceptableOrUnknown(data['since_token']!, _sinceTokenMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resource};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      resource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource'],
      )!,
      sinceToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}since_token'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String resource;
  final String? sinceToken;
  final DateTime? lastSyncAt;
  const SyncCursor({required this.resource, this.sinceToken, this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource'] = Variable<String>(resource);
    if (!nullToAbsent || sinceToken != null) {
      map['since_token'] = Variable<String>(sinceToken);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      resource: Value(resource),
      sinceToken: sinceToken == null && nullToAbsent
          ? const Value.absent()
          : Value(sinceToken),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      resource: serializer.fromJson<String>(json['resource']),
      sinceToken: serializer.fromJson<String?>(json['sinceToken']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resource': serializer.toJson<String>(resource),
      'sinceToken': serializer.toJson<String?>(sinceToken),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  SyncCursor copyWith({
    String? resource,
    Value<String?> sinceToken = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
  }) => SyncCursor(
    resource: resource ?? this.resource,
    sinceToken: sinceToken.present ? sinceToken.value : this.sinceToken,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      resource: data.resource.present ? data.resource.value : this.resource,
      sinceToken: data.sinceToken.present
          ? data.sinceToken.value
          : this.sinceToken,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('resource: $resource, ')
          ..write('sinceToken: $sinceToken, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(resource, sinceToken, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.resource == this.resource &&
          other.sinceToken == this.sinceToken &&
          other.lastSyncAt == this.lastSyncAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> resource;
  final Value<String?> sinceToken;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.resource = const Value.absent(),
    this.sinceToken = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String resource,
    this.sinceToken = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : resource = Value(resource);
  static Insertable<SyncCursor> custom({
    Expression<String>? resource,
    Expression<String>? sinceToken,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resource != null) 'resource': resource,
      if (sinceToken != null) 'since_token': sinceToken,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? resource,
    Value<String?>? sinceToken,
    Value<DateTime?>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      resource: resource ?? this.resource,
      sinceToken: sinceToken ?? this.sinceToken,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resource.present) {
      map['resource'] = Variable<String>(resource.value);
    }
    if (sinceToken.present) {
      map['since_token'] = Variable<String>(sinceToken.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('resource: $resource, ')
          ..write('sinceToken: $sinceToken, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProductsTable cachedProducts = $CachedProductsTable(this);
  late final $CachedDrugGroupsTable cachedDrugGroups = $CachedDrugGroupsTable(
    this,
  );
  late final $CachedManufacturersTable cachedManufacturers =
      $CachedManufacturersTable(this);
  late final $CachedUnitsTable cachedUnits = $CachedUnitsTable(this);
  late final $CachedSuppliersTable cachedSuppliers = $CachedSuppliersTable(
    this,
  );
  late final $CachedBatchesTable cachedBatches = $CachedBatchesTable(this);
  late final $CachedStockTable cachedStock = $CachedStockTable(this);
  late final $OutboxSalesTable outboxSales = $OutboxSalesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedProducts,
    cachedDrugGroups,
    cachedManufacturers,
    cachedUnits,
    cachedSuppliers,
    cachedBatches,
    cachedStock,
    outboxSales,
    syncCursors,
  ];
}

typedef $$CachedProductsTableCreateCompanionBuilder =
    CachedProductsCompanion Function({
      required String id,
      Value<String> name,
      Value<String?> barcode,
      Value<String?> drugGroupId,
      Value<String?> manufacturerId,
      Value<String?> unitId,
      Value<bool> rxRequired,
      Value<bool> isActive,
      Value<double?> minStockLevel,
      Value<int> rowid,
    });
typedef $$CachedProductsTableUpdateCompanionBuilder =
    CachedProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> barcode,
      Value<String?> drugGroupId,
      Value<String?> manufacturerId,
      Value<String?> unitId,
      Value<bool> rxRequired,
      Value<bool> isActive,
      Value<double?> minStockLevel,
      Value<int> rowid,
    });

class $$CachedProductsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProductsTable> {
  $$CachedProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugGroupId => $composableBuilder(
    column: $table.drugGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturerId => $composableBuilder(
    column: $table.manufacturerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rxRequired => $composableBuilder(
    column: $table.rxRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minStockLevel => $composableBuilder(
    column: $table.minStockLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProductsTable> {
  $$CachedProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugGroupId => $composableBuilder(
    column: $table.drugGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturerId => $composableBuilder(
    column: $table.manufacturerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitId => $composableBuilder(
    column: $table.unitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rxRequired => $composableBuilder(
    column: $table.rxRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minStockLevel => $composableBuilder(
    column: $table.minStockLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProductsTable> {
  $$CachedProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get drugGroupId => $composableBuilder(
    column: $table.drugGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manufacturerId => $composableBuilder(
    column: $table.manufacturerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<bool> get rxRequired => $composableBuilder(
    column: $table.rxRequired,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<double> get minStockLevel => $composableBuilder(
    column: $table.minStockLevel,
    builder: (column) => column,
  );
}

class $$CachedProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedProductsTable,
          CachedProduct,
          $$CachedProductsTableFilterComposer,
          $$CachedProductsTableOrderingComposer,
          $$CachedProductsTableAnnotationComposer,
          $$CachedProductsTableCreateCompanionBuilder,
          $$CachedProductsTableUpdateCompanionBuilder,
          (
            CachedProduct,
            BaseReferences<_$AppDatabase, $CachedProductsTable, CachedProduct>,
          ),
          CachedProduct,
          PrefetchHooks Function()
        > {
  $$CachedProductsTableTableManager(
    _$AppDatabase db,
    $CachedProductsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> drugGroupId = const Value.absent(),
                Value<String?> manufacturerId = const Value.absent(),
                Value<String?> unitId = const Value.absent(),
                Value<bool> rxRequired = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<double?> minStockLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProductsCompanion(
                id: id,
                name: name,
                barcode: barcode,
                drugGroupId: drugGroupId,
                manufacturerId: manufacturerId,
                unitId: unitId,
                rxRequired: rxRequired,
                isActive: isActive,
                minStockLevel: minStockLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> drugGroupId = const Value.absent(),
                Value<String?> manufacturerId = const Value.absent(),
                Value<String?> unitId = const Value.absent(),
                Value<bool> rxRequired = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<double?> minStockLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProductsCompanion.insert(
                id: id,
                name: name,
                barcode: barcode,
                drugGroupId: drugGroupId,
                manufacturerId: manufacturerId,
                unitId: unitId,
                rxRequired: rxRequired,
                isActive: isActive,
                minStockLevel: minStockLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedProductsTable,
      CachedProduct,
      $$CachedProductsTableFilterComposer,
      $$CachedProductsTableOrderingComposer,
      $$CachedProductsTableAnnotationComposer,
      $$CachedProductsTableCreateCompanionBuilder,
      $$CachedProductsTableUpdateCompanionBuilder,
      (
        CachedProduct,
        BaseReferences<_$AppDatabase, $CachedProductsTable, CachedProduct>,
      ),
      CachedProduct,
      PrefetchHooks Function()
    >;
typedef $$CachedDrugGroupsTableCreateCompanionBuilder =
    CachedDrugGroupsCompanion Function({
      required String id,
      Value<String> name,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$CachedDrugGroupsTableUpdateCompanionBuilder =
    CachedDrugGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<int> rowid,
    });

class $$CachedDrugGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedDrugGroupsTable> {
  $$CachedDrugGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedDrugGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedDrugGroupsTable> {
  $$CachedDrugGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedDrugGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedDrugGroupsTable> {
  $$CachedDrugGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$CachedDrugGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedDrugGroupsTable,
          CachedDrugGroup,
          $$CachedDrugGroupsTableFilterComposer,
          $$CachedDrugGroupsTableOrderingComposer,
          $$CachedDrugGroupsTableAnnotationComposer,
          $$CachedDrugGroupsTableCreateCompanionBuilder,
          $$CachedDrugGroupsTableUpdateCompanionBuilder,
          (
            CachedDrugGroup,
            BaseReferences<
              _$AppDatabase,
              $CachedDrugGroupsTable,
              CachedDrugGroup
            >,
          ),
          CachedDrugGroup,
          PrefetchHooks Function()
        > {
  $$CachedDrugGroupsTableTableManager(
    _$AppDatabase db,
    $CachedDrugGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDrugGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDrugGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDrugGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedDrugGroupsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedDrugGroupsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedDrugGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedDrugGroupsTable,
      CachedDrugGroup,
      $$CachedDrugGroupsTableFilterComposer,
      $$CachedDrugGroupsTableOrderingComposer,
      $$CachedDrugGroupsTableAnnotationComposer,
      $$CachedDrugGroupsTableCreateCompanionBuilder,
      $$CachedDrugGroupsTableUpdateCompanionBuilder,
      (
        CachedDrugGroup,
        BaseReferences<_$AppDatabase, $CachedDrugGroupsTable, CachedDrugGroup>,
      ),
      CachedDrugGroup,
      PrefetchHooks Function()
    >;
typedef $$CachedManufacturersTableCreateCompanionBuilder =
    CachedManufacturersCompanion Function({
      required String id,
      Value<String> name,
      Value<String?> country,
      Value<int> rowid,
    });
typedef $$CachedManufacturersTableUpdateCompanionBuilder =
    CachedManufacturersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> country,
      Value<int> rowid,
    });

class $$CachedManufacturersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedManufacturersTable> {
  $$CachedManufacturersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedManufacturersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedManufacturersTable> {
  $$CachedManufacturersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedManufacturersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedManufacturersTable> {
  $$CachedManufacturersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);
}

class $$CachedManufacturersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedManufacturersTable,
          CachedManufacturer,
          $$CachedManufacturersTableFilterComposer,
          $$CachedManufacturersTableOrderingComposer,
          $$CachedManufacturersTableAnnotationComposer,
          $$CachedManufacturersTableCreateCompanionBuilder,
          $$CachedManufacturersTableUpdateCompanionBuilder,
          (
            CachedManufacturer,
            BaseReferences<
              _$AppDatabase,
              $CachedManufacturersTable,
              CachedManufacturer
            >,
          ),
          CachedManufacturer,
          PrefetchHooks Function()
        > {
  $$CachedManufacturersTableTableManager(
    _$AppDatabase db,
    $CachedManufacturersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedManufacturersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedManufacturersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedManufacturersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedManufacturersCompanion(
                id: id,
                name: name,
                country: country,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedManufacturersCompanion.insert(
                id: id,
                name: name,
                country: country,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedManufacturersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedManufacturersTable,
      CachedManufacturer,
      $$CachedManufacturersTableFilterComposer,
      $$CachedManufacturersTableOrderingComposer,
      $$CachedManufacturersTableAnnotationComposer,
      $$CachedManufacturersTableCreateCompanionBuilder,
      $$CachedManufacturersTableUpdateCompanionBuilder,
      (
        CachedManufacturer,
        BaseReferences<
          _$AppDatabase,
          $CachedManufacturersTable,
          CachedManufacturer
        >,
      ),
      CachedManufacturer,
      PrefetchHooks Function()
    >;
typedef $$CachedUnitsTableCreateCompanionBuilder =
    CachedUnitsCompanion Function({
      required String id,
      Value<String> name,
      Value<int> rowid,
    });
typedef $$CachedUnitsTableUpdateCompanionBuilder =
    CachedUnitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$CachedUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedUnitsTable,
          CachedUnit,
          $$CachedUnitsTableFilterComposer,
          $$CachedUnitsTableOrderingComposer,
          $$CachedUnitsTableAnnotationComposer,
          $$CachedUnitsTableCreateCompanionBuilder,
          $$CachedUnitsTableUpdateCompanionBuilder,
          (
            CachedUnit,
            BaseReferences<_$AppDatabase, $CachedUnitsTable, CachedUnit>,
          ),
          CachedUnit,
          PrefetchHooks Function()
        > {
  $$CachedUnitsTableTableManager(_$AppDatabase db, $CachedUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUnitsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  CachedUnitsCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedUnitsTable,
      CachedUnit,
      $$CachedUnitsTableFilterComposer,
      $$CachedUnitsTableOrderingComposer,
      $$CachedUnitsTableAnnotationComposer,
      $$CachedUnitsTableCreateCompanionBuilder,
      $$CachedUnitsTableUpdateCompanionBuilder,
      (
        CachedUnit,
        BaseReferences<_$AppDatabase, $CachedUnitsTable, CachedUnit>,
      ),
      CachedUnit,
      PrefetchHooks Function()
    >;
typedef $$CachedSuppliersTableCreateCompanionBuilder =
    CachedSuppliersCompanion Function({
      required String id,
      Value<String> name,
      Value<String?> inn,
      Value<String?> phone,
      Value<String?> address,
      Value<int> rowid,
    });
typedef $$CachedSuppliersTableUpdateCompanionBuilder =
    CachedSuppliersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> inn,
      Value<String?> phone,
      Value<String?> address,
      Value<int> rowid,
    });

class $$CachedSuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSuppliersTable> {
  $$CachedSuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inn => $composableBuilder(
    column: $table.inn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSuppliersTable> {
  $$CachedSuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inn => $composableBuilder(
    column: $table.inn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSuppliersTable> {
  $$CachedSuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get inn =>
      $composableBuilder(column: $table.inn, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$CachedSuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSuppliersTable,
          CachedSupplier,
          $$CachedSuppliersTableFilterComposer,
          $$CachedSuppliersTableOrderingComposer,
          $$CachedSuppliersTableAnnotationComposer,
          $$CachedSuppliersTableCreateCompanionBuilder,
          $$CachedSuppliersTableUpdateCompanionBuilder,
          (
            CachedSupplier,
            BaseReferences<
              _$AppDatabase,
              $CachedSuppliersTable,
              CachedSupplier
            >,
          ),
          CachedSupplier,
          PrefetchHooks Function()
        > {
  $$CachedSuppliersTableTableManager(
    _$AppDatabase db,
    $CachedSuppliersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> inn = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSuppliersCompanion(
                id: id,
                name: name,
                inn: inn,
                phone: phone,
                address: address,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String?> inn = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSuppliersCompanion.insert(
                id: id,
                name: name,
                inn: inn,
                phone: phone,
                address: address,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSuppliersTable,
      CachedSupplier,
      $$CachedSuppliersTableFilterComposer,
      $$CachedSuppliersTableOrderingComposer,
      $$CachedSuppliersTableAnnotationComposer,
      $$CachedSuppliersTableCreateCompanionBuilder,
      $$CachedSuppliersTableUpdateCompanionBuilder,
      (
        CachedSupplier,
        BaseReferences<_$AppDatabase, $CachedSuppliersTable, CachedSupplier>,
      ),
      CachedSupplier,
      PrefetchHooks Function()
    >;
typedef $$CachedBatchesTableCreateCompanionBuilder =
    CachedBatchesCompanion Function({
      required String id,
      required String productId,
      Value<String> seriesNumber,
      required DateTime expiryDate,
      Value<double> salePrice,
      Value<double> purchasePrice,
      Value<int> rowid,
    });
typedef $$CachedBatchesTableUpdateCompanionBuilder =
    CachedBatchesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> seriesNumber,
      Value<DateTime> expiryDate,
      Value<double> salePrice,
      Value<double> purchasePrice,
      Value<int> rowid,
    });

class $$CachedBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBatchesTable> {
  $$CachedBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesNumber => $composableBuilder(
    column: $table.seriesNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBatchesTable> {
  $$CachedBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesNumber => $composableBuilder(
    column: $table.seriesNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBatchesTable> {
  $$CachedBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get seriesNumber => $composableBuilder(
    column: $table.seriesNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );
}

class $$CachedBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedBatchesTable,
          CachedBatche,
          $$CachedBatchesTableFilterComposer,
          $$CachedBatchesTableOrderingComposer,
          $$CachedBatchesTableAnnotationComposer,
          $$CachedBatchesTableCreateCompanionBuilder,
          $$CachedBatchesTableUpdateCompanionBuilder,
          (
            CachedBatche,
            BaseReferences<_$AppDatabase, $CachedBatchesTable, CachedBatche>,
          ),
          CachedBatche,
          PrefetchHooks Function()
        > {
  $$CachedBatchesTableTableManager(_$AppDatabase db, $CachedBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> seriesNumber = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<double> salePrice = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBatchesCompanion(
                id: id,
                productId: productId,
                seriesNumber: seriesNumber,
                expiryDate: expiryDate,
                salePrice: salePrice,
                purchasePrice: purchasePrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                Value<String> seriesNumber = const Value.absent(),
                required DateTime expiryDate,
                Value<double> salePrice = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBatchesCompanion.insert(
                id: id,
                productId: productId,
                seriesNumber: seriesNumber,
                expiryDate: expiryDate,
                salePrice: salePrice,
                purchasePrice: purchasePrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedBatchesTable,
      CachedBatche,
      $$CachedBatchesTableFilterComposer,
      $$CachedBatchesTableOrderingComposer,
      $$CachedBatchesTableAnnotationComposer,
      $$CachedBatchesTableCreateCompanionBuilder,
      $$CachedBatchesTableUpdateCompanionBuilder,
      (
        CachedBatche,
        BaseReferences<_$AppDatabase, $CachedBatchesTable, CachedBatche>,
      ),
      CachedBatche,
      PrefetchHooks Function()
    >;
typedef $$CachedStockTableCreateCompanionBuilder =
    CachedStockCompanion Function({
      required String branchId,
      required String batchId,
      required String productId,
      Value<double> quantity,
      Value<int> rowid,
    });
typedef $$CachedStockTableUpdateCompanionBuilder =
    CachedStockCompanion Function({
      Value<String> branchId,
      Value<String> batchId,
      Value<String> productId,
      Value<double> quantity,
      Value<int> rowid,
    });

class $$CachedStockTableFilterComposer
    extends Composer<_$AppDatabase, $CachedStockTable> {
  $$CachedStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedStockTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedStockTable> {
  $$CachedStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedStockTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedStockTable> {
  $$CachedStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$CachedStockTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedStockTable,
          CachedStockData,
          $$CachedStockTableFilterComposer,
          $$CachedStockTableOrderingComposer,
          $$CachedStockTableAnnotationComposer,
          $$CachedStockTableCreateCompanionBuilder,
          $$CachedStockTableUpdateCompanionBuilder,
          (
            CachedStockData,
            BaseReferences<_$AppDatabase, $CachedStockTable, CachedStockData>,
          ),
          CachedStockData,
          PrefetchHooks Function()
        > {
  $$CachedStockTableTableManager(_$AppDatabase db, $CachedStockTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> branchId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedStockCompanion(
                branchId: branchId,
                batchId: batchId,
                productId: productId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String branchId,
                required String batchId,
                required String productId,
                Value<double> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedStockCompanion.insert(
                branchId: branchId,
                batchId: batchId,
                productId: productId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedStockTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedStockTable,
      CachedStockData,
      $$CachedStockTableFilterComposer,
      $$CachedStockTableOrderingComposer,
      $$CachedStockTableAnnotationComposer,
      $$CachedStockTableCreateCompanionBuilder,
      $$CachedStockTableUpdateCompanionBuilder,
      (
        CachedStockData,
        BaseReferences<_$AppDatabase, $CachedStockTable, CachedStockData>,
      ),
      CachedStockData,
      PrefetchHooks Function()
    >;
typedef $$OutboxSalesTableCreateCompanionBuilder =
    OutboxSalesCompanion Function({
      Value<int> seq,
      required String clientId,
      required String branchId,
      required String payloadJson,
      Value<String> status,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<DateTime?> lastAttemptAt,
      Value<String?> serverSaleId,
      Value<String?> conflictMessage,
    });
typedef $$OutboxSalesTableUpdateCompanionBuilder =
    OutboxSalesCompanion Function({
      Value<int> seq,
      Value<String> clientId,
      Value<String> branchId,
      Value<String> payloadJson,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<DateTime?> lastAttemptAt,
      Value<String?> serverSaleId,
      Value<String?> conflictMessage,
    });

class $$OutboxSalesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxSalesTable> {
  $$OutboxSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverSaleId => $composableBuilder(
    column: $table.serverSaleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictMessage => $composableBuilder(
    column: $table.conflictMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxSalesTable> {
  $$OutboxSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverSaleId => $composableBuilder(
    column: $table.serverSaleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictMessage => $composableBuilder(
    column: $table.conflictMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxSalesTable> {
  $$OutboxSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverSaleId => $composableBuilder(
    column: $table.serverSaleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictMessage => $composableBuilder(
    column: $table.conflictMessage,
    builder: (column) => column,
  );
}

class $$OutboxSalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxSalesTable,
          OutboxSale,
          $$OutboxSalesTableFilterComposer,
          $$OutboxSalesTableOrderingComposer,
          $$OutboxSalesTableAnnotationComposer,
          $$OutboxSalesTableCreateCompanionBuilder,
          $$OutboxSalesTableUpdateCompanionBuilder,
          (
            OutboxSale,
            BaseReferences<_$AppDatabase, $OutboxSalesTable, OutboxSale>,
          ),
          OutboxSale,
          PrefetchHooks Function()
        > {
  $$OutboxSalesTableTableManager(_$AppDatabase db, $OutboxSalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> serverSaleId = const Value.absent(),
                Value<String?> conflictMessage = const Value.absent(),
              }) => OutboxSalesCompanion(
                seq: seq,
                clientId: clientId,
                branchId: branchId,
                payloadJson: payloadJson,
                status: status,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastAttemptAt: lastAttemptAt,
                serverSaleId: serverSaleId,
                conflictMessage: conflictMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String clientId,
                required String branchId,
                required String payloadJson,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> serverSaleId = const Value.absent(),
                Value<String?> conflictMessage = const Value.absent(),
              }) => OutboxSalesCompanion.insert(
                seq: seq,
                clientId: clientId,
                branchId: branchId,
                payloadJson: payloadJson,
                status: status,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastAttemptAt: lastAttemptAt,
                serverSaleId: serverSaleId,
                conflictMessage: conflictMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxSalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxSalesTable,
      OutboxSale,
      $$OutboxSalesTableFilterComposer,
      $$OutboxSalesTableOrderingComposer,
      $$OutboxSalesTableAnnotationComposer,
      $$OutboxSalesTableCreateCompanionBuilder,
      $$OutboxSalesTableUpdateCompanionBuilder,
      (
        OutboxSale,
        BaseReferences<_$AppDatabase, $OutboxSalesTable, OutboxSale>,
      ),
      OutboxSale,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String resource,
      Value<String?> sinceToken,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> resource,
      Value<String?> sinceToken,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sinceToken => $composableBuilder(
    column: $table.sinceToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sinceToken => $composableBuilder(
    column: $table.sinceToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get resource =>
      $composableBuilder(column: $table.resource, builder: (column) => column);

  GeneratedColumn<String> get sinceToken => $composableBuilder(
    column: $table.sinceToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> resource = const Value.absent(),
                Value<String?> sinceToken = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                resource: resource,
                sinceToken: sinceToken,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String resource,
                Value<String?> sinceToken = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                resource: resource,
                sinceToken: sinceToken,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProductsTableTableManager get cachedProducts =>
      $$CachedProductsTableTableManager(_db, _db.cachedProducts);
  $$CachedDrugGroupsTableTableManager get cachedDrugGroups =>
      $$CachedDrugGroupsTableTableManager(_db, _db.cachedDrugGroups);
  $$CachedManufacturersTableTableManager get cachedManufacturers =>
      $$CachedManufacturersTableTableManager(_db, _db.cachedManufacturers);
  $$CachedUnitsTableTableManager get cachedUnits =>
      $$CachedUnitsTableTableManager(_db, _db.cachedUnits);
  $$CachedSuppliersTableTableManager get cachedSuppliers =>
      $$CachedSuppliersTableTableManager(_db, _db.cachedSuppliers);
  $$CachedBatchesTableTableManager get cachedBatches =>
      $$CachedBatchesTableTableManager(_db, _db.cachedBatches);
  $$CachedStockTableTableManager get cachedStock =>
      $$CachedStockTableTableManager(_db, _db.cachedStock);
  $$OutboxSalesTableTableManager get outboxSales =>
      $$OutboxSalesTableTableManager(_db, _db.outboxSales);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
