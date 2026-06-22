/// Feature-local test doubles for the Products + Reference-data screens.
///
/// Kept SEPARATE from `test/support/fakes.dart` (which other tracks edit
/// concurrently): this file holds the [ReferenceCrudRepository] fake used by
/// the reference list/editor tests.
library;

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/reference/data/reference_crud_repository.dart';

/// Records every create/update/delete call and returns canned outcomes
/// (defaulting to echoing the input as [Success]).
class FakeReferenceCrudRepository implements ReferenceCrudRepository {
  // Call counters.
  int createDrugGroupCalls = 0;
  int updateDrugGroupCalls = 0;
  int deleteDrugGroupCalls = 0;
  int createManufacturerCalls = 0;
  int updateManufacturerCalls = 0;
  int deleteManufacturerCalls = 0;
  int createSupplierCalls = 0;
  int updateSupplierCalls = 0;
  int deleteSupplierCalls = 0;
  int createUnitCalls = 0;
  int updateUnitCalls = 0;
  int deleteUnitCalls = 0;

  // Last-seen payloads.
  DrugGroup? lastDrugGroup;
  Manufacturer? lastManufacturer;
  Supplier? lastSupplier;
  Unit? lastUnit;
  String? lastDeletedId;

  // Optional canned failures (null → echo Success).
  Failure? createFailure;
  Failure? deleteFailure;

  @override
  Future<ApiResult<DrugGroup>> createDrugGroup(DrugGroup value) async {
    createDrugGroupCalls++;
    lastDrugGroup = value;
    return createFailure != null ? Error(createFailure!) : Success(value);
  }

  @override
  Future<ApiResult<DrugGroup>> updateDrugGroup(DrugGroup value) async {
    updateDrugGroupCalls++;
    lastDrugGroup = value;
    return Success(value);
  }

  @override
  Future<ApiResult<void>> deleteDrugGroup(String id) async {
    deleteDrugGroupCalls++;
    lastDeletedId = id;
    return deleteFailure != null
        ? Error(deleteFailure!)
        : const Success(null);
  }

  @override
  Future<ApiResult<Manufacturer>> createManufacturer(Manufacturer value) async {
    createManufacturerCalls++;
    lastManufacturer = value;
    return createFailure != null ? Error(createFailure!) : Success(value);
  }

  @override
  Future<ApiResult<Manufacturer>> updateManufacturer(Manufacturer value) async {
    updateManufacturerCalls++;
    lastManufacturer = value;
    return Success(value);
  }

  @override
  Future<ApiResult<void>> deleteManufacturer(String id) async {
    deleteManufacturerCalls++;
    lastDeletedId = id;
    return const Success(null);
  }

  @override
  Future<ApiResult<Supplier>> createSupplier(Supplier value) async {
    createSupplierCalls++;
    lastSupplier = value;
    return createFailure != null ? Error(createFailure!) : Success(value);
  }

  @override
  Future<ApiResult<Supplier>> updateSupplier(Supplier value) async {
    updateSupplierCalls++;
    lastSupplier = value;
    return Success(value);
  }

  @override
  Future<ApiResult<void>> deleteSupplier(String id) async {
    deleteSupplierCalls++;
    lastDeletedId = id;
    return const Success(null);
  }

  @override
  Future<ApiResult<Unit>> createUnit(Unit value) async {
    createUnitCalls++;
    lastUnit = value;
    return createFailure != null ? Error(createFailure!) : Success(value);
  }

  @override
  Future<ApiResult<Unit>> updateUnit(Unit value) async {
    updateUnitCalls++;
    lastUnit = value;
    return Success(value);
  }

  @override
  Future<ApiResult<void>> deleteUnit(String id) async {
    deleteUnitCalls++;
    lastDeletedId = id;
    return const Success(null);
  }
}
