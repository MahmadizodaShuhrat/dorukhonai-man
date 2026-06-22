/// Test doubles for the MODUL 6 (Амалиёти анбор) track.
library;

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/api/paged.dart';
import 'package:dorukhonai_man/features/operations/data/operations_models.dart';
import 'package:dorukhonai_man/features/operations/data/operations_repository.dart';

/// Fake [OperationsRepository] recording the last posted request per document.
class FakeOperationsRepository implements OperationsRepository {
  FakeOperationsRepository({
    this.writeOffResult,
    this.inventoryResult,
    this.supplierReturnResult,
    Paged<WriteOff>? writeOffList,
    Paged<InventoryDoc>? inventoryList,
    Paged<SupplierReturn>? supplierReturnList,
  })  : writeOffList = writeOffList ?? Paged<WriteOff>.empty(),
        inventoryList = inventoryList ?? Paged<InventoryDoc>.empty(),
        supplierReturnList =
            supplierReturnList ?? Paged<SupplierReturn>.empty();

  ApiResult<WriteOff>? writeOffResult;
  ApiResult<InventoryResult>? inventoryResult;
  ApiResult<SupplierReturn>? supplierReturnResult;
  Paged<WriteOff> writeOffList;
  Paged<InventoryDoc> inventoryList;
  Paged<SupplierReturn> supplierReturnList;

  int createWriteOffCalls = 0;
  int createInventoryCalls = 0;
  int createSupplierReturnCalls = 0;

  String? lastBranchId;
  String? lastSupplierId;
  WriteOffReason? lastReason;
  List<WriteOffLineRequest>? lastWriteOffLines;
  List<InventoryLineRequest>? lastInventoryLines;
  List<SupplierReturnLineRequest>? lastSupplierReturnLines;

  @override
  Future<ApiResult<WriteOff>> createWriteOff({
    required String branchId,
    required WriteOffReason reason,
    String? note,
    required List<WriteOffLineRequest> lines,
  }) async {
    createWriteOffCalls++;
    lastBranchId = branchId;
    lastReason = reason;
    lastWriteOffLines = lines;
    return writeOffResult ??
        Success(
          WriteOff(id: 'wo-1', reason: reason, createdAt: DateTime(2026, 6, 22)),
        );
  }

  @override
  Future<ApiResult<Paged<WriteOff>>> listWriteOffs({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async => Success(writeOffList);

  @override
  Future<ApiResult<InventoryResult>> createInventory({
    required String branchId,
    String? note,
    required List<InventoryLineRequest> lines,
  }) async {
    createInventoryCalls++;
    lastBranchId = branchId;
    lastInventoryLines = lines;
    return inventoryResult ?? const Success(InventoryResult(id: 'inv-1'));
  }

  @override
  Future<ApiResult<Paged<InventoryDoc>>> listInventory({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async => Success(inventoryList);

  @override
  Future<ApiResult<SupplierReturn>> createSupplierReturn({
    required String supplierId,
    required String branchId,
    String? note,
    required List<SupplierReturnLineRequest> lines,
  }) async {
    createSupplierReturnCalls++;
    lastSupplierId = supplierId;
    lastBranchId = branchId;
    lastSupplierReturnLines = lines;
    return supplierReturnResult ??
        Success(
          SupplierReturn(
            id: 'sr-1',
            supplierId: supplierId,
            createdAt: DateTime(2026, 6, 22),
          ),
        );
  }

  @override
  Future<ApiResult<Paged<SupplierReturn>>> listSupplierReturns({
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async => Success(supplierReturnList);
}
