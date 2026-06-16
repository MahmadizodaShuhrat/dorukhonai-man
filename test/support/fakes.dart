/// Shared test doubles: in-memory token storage and fake repositories that
/// never touch the network. Used to override Riverpod providers in tests.
library;

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/core/api/paged.dart';
import 'package:dorukhonai_man/features/auth/data/auth_models.dart';
import 'package:dorukhonai_man/features/auth/data/auth_repository.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/pos/data/pos_repository.dart';
import 'package:dorukhonai_man/features/products/data/product_models.dart';
import 'package:dorukhonai_man/features/products/data/products_repository.dart';
import 'package:dorukhonai_man/features/receipts/data/receipt_models.dart';
import 'package:dorukhonai_man/features/receipts/data/receipts_repository.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';
import 'package:dorukhonai_man/features/stock/data/stock_repository.dart';

/// In-memory replacement for [TokenStorage] semantics used by tests that need
/// to assert tokens were persisted. (The real auth flow persists inside the
/// repository, so [FakeAuthRepository] records tokens here directly.)
class InMemoryTokenStore {
  String? accessToken;
  String? refreshToken;

  void save(String access, String refresh) {
    accessToken = access;
    refreshToken = refresh;
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
  }
}

/// Fake [AuthRepository] driven by canned outcomes.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.loginResult,
    this.meResult,
    this.tokenStore,
  });

  /// Outcome returned by [login]. Defaults to a generic failure when null.
  ApiResult<LoginResponse>? loginResult;

  /// Outcome returned by [me].
  ApiResult<User>? meResult;

  /// Optional store updated on a successful login (to assert persistence).
  final InMemoryTokenStore? tokenStore;

  int loginCalls = 0;
  int meCalls = 0;
  int logoutCalls = 0;
  String? lastUserName;
  String? lastPassword;

  @override
  Future<ApiResult<LoginResponse>> login({
    required String userName,
    required String password,
  }) async {
    loginCalls++;
    lastUserName = userName;
    lastPassword = password;
    final result =
        loginResult ?? const Error<LoginResponse>(UnknownFailure());
    if (result case Success<LoginResponse>(:final data)) {
      tokenStore?.save(data.token, data.refreshToken);
    }
    return result;
  }

  @override
  Future<ApiResult<User>> me() async {
    meCalls++;
    return meResult ?? const Error<User>(UnknownFailure());
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    tokenStore?.clear();
  }
}

/// Fake [ProductsRepository] with canned list/create/update/delete outcomes.
class FakeProductsRepository implements ProductsRepository {
  FakeProductsRepository({
    ApiResult<Paged<Product>>? listResult,
    this.getByIdResult,
    this.getByBarcodeResult,
    this.createResult,
    this.updateResult,
    this.deleteResult,
  }) : listResult = listResult ?? Success(Paged<Product>.empty());

  ApiResult<Paged<Product>> listResult;
  ApiResult<Product>? getByIdResult;
  ApiResult<Product>? getByBarcodeResult;
  ApiResult<Product>? createResult;
  ApiResult<Product>? updateResult;
  ApiResult<void>? deleteResult;

  int listCalls = 0;
  int getByIdCalls = 0;
  int getByBarcodeCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  Product? lastCreated;
  Product? lastUpdated;
  String? lastSearch;
  String? lastBarcode;
  int? lastPage;

  @override
  Future<ApiResult<Paged<Product>>> list({
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    listCalls++;
    lastSearch = search;
    lastPage = page;
    return listResult;
  }

  @override
  Future<ApiResult<Product>> getById(String id) async {
    getByIdCalls++;
    return getByIdResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<Product>> getByBarcode(String barcode) async {
    getByBarcodeCalls++;
    lastBarcode = barcode;
    return getByBarcodeResult ??
        const Error(ServerFailure('Ёфт нашуд.', statusCode: 404));
  }

  @override
  Future<ApiResult<Product>> create(Product product) async {
    createCalls++;
    lastCreated = product;
    return createResult ?? Success(product);
  }

  @override
  Future<ApiResult<Product>> update(Product product) async {
    updateCalls++;
    lastUpdated = product;
    return updateResult ?? Success(product);
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    deleteCalls++;
    return deleteResult ?? const Success(null);
  }
}

/// Fake [ReceiptsRepository] with canned list/detail/mutation outcomes.
class FakeReceiptsRepository implements ReceiptsRepository {
  FakeReceiptsRepository({
    ApiResult<Paged<Receipt>>? listResult,
    this.getByIdResult,
    this.createResult,
    this.updateResult,
    this.postResult,
    this.cancelResult,
  }) : listResult = listResult ?? Success(Paged<Receipt>.empty());

  ApiResult<Paged<Receipt>> listResult;
  ApiResult<Receipt>? getByIdResult;
  ApiResult<Receipt>? createResult;
  ApiResult<Receipt>? updateResult;
  ApiResult<Receipt>? postResult;
  ApiResult<Receipt>? cancelResult;

  int listCalls = 0;
  int getByIdCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int postCalls = 0;
  int cancelCalls = 0;

  ReceiptStatus? lastStatusFilter;
  String? lastSupplierFilter;
  DateTime? lastFrom;
  DateTime? lastTo;
  int? lastPage;
  Receipt? lastCreated;
  Receipt? lastUpdated;
  String? lastPostedId;
  String? lastCancelledId;

  @override
  Future<ApiResult<Paged<Receipt>>> list({
    DateTime? from,
    DateTime? to,
    String? supplierId,
    ReceiptStatus? status,
    int page = 1,
    int size = 20,
  }) async {
    listCalls++;
    lastFrom = from;
    lastTo = to;
    lastSupplierFilter = supplierId;
    lastStatusFilter = status;
    lastPage = page;
    return listResult;
  }

  @override
  Future<ApiResult<Receipt>> getById(String id) async {
    getByIdCalls++;
    return getByIdResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<Receipt>> create(Receipt receipt) async {
    createCalls++;
    lastCreated = receipt;
    return createResult ?? Success(receipt);
  }

  @override
  Future<ApiResult<Receipt>> update(Receipt receipt) async {
    updateCalls++;
    lastUpdated = receipt;
    return updateResult ?? Success(receipt);
  }

  @override
  Future<ApiResult<Receipt>> post(String id) async {
    postCalls++;
    lastPostedId = id;
    return postResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<Receipt>> cancel(String id) async {
    cancelCalls++;
    lastCancelledId = id;
    return cancelResult ?? const Error(UnknownFailure());
  }
}

/// Fake [StockRepository] with canned outcomes for each tab + movements.
class FakeStockRepository implements StockRepository {
  FakeStockRepository({
    ApiResult<Paged<StockItem>>? listResult,
    ApiResult<Paged<StockItem>>? expiringResult,
    ApiResult<Paged<LowStockItem>>? lowResult,
    ApiResult<Paged<StockMovement>>? movementsResult,
  }) : listResult = listResult ?? Success(Paged<StockItem>.empty()),
       expiringResult = expiringResult ?? Success(Paged<StockItem>.empty()),
       lowResult = lowResult ?? Success(Paged<LowStockItem>.empty()),
       movementsResult =
           movementsResult ?? Success(Paged<StockMovement>.empty());

  ApiResult<Paged<StockItem>> listResult;
  ApiResult<Paged<StockItem>> expiringResult;
  ApiResult<Paged<LowStockItem>> lowResult;
  ApiResult<Paged<StockMovement>> movementsResult;

  int listCalls = 0;
  int expiringCalls = 0;
  int lowCalls = 0;
  int movementsCalls = 0;

  String? lastSearch;
  int? lastExpiringDays;
  int? lastListPage;
  String? lastMovementsProductId;

  @override
  Future<ApiResult<Paged<StockItem>>> list({
    String? branchId,
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    listCalls++;
    lastSearch = search;
    lastListPage = page;
    return listResult;
  }

  @override
  Future<ApiResult<Paged<StockItem>>> expiring({
    int days = 90,
    String? branchId,
    int page = 1,
    int size = 20,
  }) async {
    expiringCalls++;
    lastExpiringDays = days;
    return expiringResult;
  }

  @override
  Future<ApiResult<Paged<LowStockItem>>> low({
    String? branchId,
    int page = 1,
    int size = 20,
  }) async {
    lowCalls++;
    return lowResult;
  }

  @override
  Future<ApiResult<Paged<StockMovement>>> movements({
    required String productId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async {
    movementsCalls++;
    lastMovementsProductId = productId;
    return movementsResult;
  }
}

/// Fake [PosRepository] with canned shift/sale/return/z-report outcomes.
class FakePosRepository implements PosRepository {
  FakePosRepository({
    this.openShiftResult,
    this.closeShiftResult,
    this.currentShiftResult,
    this.createSaleResult,
    this.getSaleResult,
    ApiResult<Paged<Sale>>? listSalesResult,
    this.returnSaleResult,
    this.zReportResult,
  }) : listSalesResult = listSalesResult ?? Success(Paged<Sale>.empty());

  ApiResult<CashShift>? openShiftResult;
  ApiResult<CashShift>? closeShiftResult;
  ApiResult<CashShift>? currentShiftResult;
  ApiResult<Sale>? createSaleResult;
  ApiResult<Sale>? getSaleResult;
  ApiResult<Paged<Sale>> listSalesResult;
  ApiResult<Sale>? returnSaleResult;
  ApiResult<ZReport>? zReportResult;

  int openShiftCalls = 0;
  int closeShiftCalls = 0;
  int currentShiftCalls = 0;
  int createSaleCalls = 0;
  int returnSaleCalls = 0;

  String? lastBranchId;
  double? lastOpeningCash;
  double? lastClosingCash;
  List<CartItem>? lastSaleLines;
  List<Payment>? lastSalePayments;
  double? lastSaleDiscount;
  String? lastReturnSaleId;
  List<SaleReturnLine>? lastReturnLines;

  @override
  Future<ApiResult<CashShift>> openShift({
    required String branchId,
    required double openingCash,
  }) async {
    openShiftCalls++;
    lastBranchId = branchId;
    lastOpeningCash = openingCash;
    return openShiftResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<CashShift>> closeShift({required double closingCash}) async {
    closeShiftCalls++;
    lastClosingCash = closingCash;
    return closeShiftResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<CashShift>> currentShift({String? branchId}) async {
    currentShiftCalls++;
    lastBranchId = branchId;
    return currentShiftResult ??
        const Error(ServerFailure('Смена ёфт нашуд.', statusCode: 404));
  }

  @override
  Future<ApiResult<Sale>> createSale({
    required String branchId,
    required List<CartItem> lines,
    required List<Payment> payments,
    double discount = 0,
  }) async {
    createSaleCalls++;
    lastBranchId = branchId;
    lastSaleLines = lines;
    lastSalePayments = payments;
    lastSaleDiscount = discount;
    return createSaleResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<Sale>> getSale(String id) async =>
      getSaleResult ?? const Error(UnknownFailure());

  @override
  Future<ApiResult<Paged<Sale>>> listSales({
    String? shiftId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int size = 20,
  }) async {
    return listSalesResult;
  }

  @override
  Future<ApiResult<Sale>> returnSale({
    required String saleId,
    required List<SaleReturnLine> lines,
  }) async {
    returnSaleCalls++;
    lastReturnSaleId = saleId;
    lastReturnLines = lines;
    return returnSaleResult ?? const Error(UnknownFailure());
  }

  @override
  Future<ApiResult<ZReport>> zReport(String shiftId) async =>
      zReportResult ?? const Error(UnknownFailure());
}

/// Convenience builders.
CashShift sampleShift({
  String id = 'shift-1',
  String branchId = 'br-1',
  String userId = 'u1',
  double openingCash = 100,
  double? closingCash,
  double totalSales = 0,
  ShiftStatus status = ShiftStatus.open,
  DateTime? openedAt,
  DateTime? closedAt,
}) => CashShift(
  id: id,
  branchId: branchId,
  userId: userId,
  openedAt: openedAt ?? DateTime(2026, 6, 16, 9),
  closedAt: closedAt,
  openingCash: openingCash,
  closingCash: closingCash,
  totalSales: totalSales,
  status: status,
);

SaleLine sampleSaleLine({
  String id = 'sl-1',
  String productId = 'p1',
  String? productName = 'Аспирин',
  String batchId = 'b1',
  String? series = 'S-1',
  double quantity = 2,
  double unitPrice = 15,
  double lineDiscount = 0,
  double? lineTotal,
}) => SaleLine(
  id: id,
  productId: productId,
  productName: productName,
  batchId: batchId,
  seriesNumber: series,
  quantity: quantity,
  unitPrice: unitPrice,
  lineDiscount: lineDiscount,
  lineTotal: lineTotal ?? (quantity * unitPrice - lineDiscount),
);

Sale sampleSale({
  String id = 'sale-1',
  String number = 'S-001',
  String branchId = 'br-1',
  String shiftId = 'shift-1',
  String userId = 'u1',
  List<SaleLine>? lines,
  List<Payment>? payments,
  double subtotal = 30,
  double discount = 0,
  double total = 30,
  DateTime? createdAt,
}) => Sale(
  id: id,
  number: number,
  branchId: branchId,
  shiftId: shiftId,
  userId: userId,
  createdAt: createdAt ?? DateTime(2026, 6, 16, 10),
  lines: lines ?? [sampleSaleLine()],
  payments: payments ?? const [Payment(method: PaymentMethod.cash, amount: 30)],
  subtotal: subtotal,
  discount: discount,
  total: total,
);

LoginResponse sampleLoginResponse({String role = 'Admin'}) => LoginResponse(
  token: 'access-123',
  refreshToken: 'refresh-456',
  user: User(
    id: 'u1',
    fullName: 'Админ Админ',
    userName: 'admin',
    role: UserRole.fromWire(role),
  ),
);

Product sampleProduct(String id, String name) => Product(id: id, name: name);

Paged<Product> pagedProducts(List<Product> items, {int total = 0}) => Paged(
  items: items,
  total: total == 0 ? items.length : total,
  page: 1,
  size: 20,
);

/// Builds a generic [Paged] envelope for any element type.
Paged<T> paged<T>(List<T> items, {int? total, int page = 1, int size = 20}) =>
    Paged<T>(items: items, total: total ?? items.length, page: page, size: size);

ReceiptLine sampleLine({
  String productId = 'p1',
  String? productName = 'Аспирин',
  double quantity = 2,
  String series = 'S-1',
  double purchasePrice = 10,
  double salePrice = 15,
  DateTime? expiry,
}) => ReceiptLine(
  productId: productId,
  productName: productName,
  quantity: quantity,
  seriesNumber: series,
  expiryDate: expiry ?? DateTime(2027, 1, 1),
  purchasePrice: purchasePrice,
  salePrice: salePrice,
);

Receipt sampleReceipt({
  String id = 'r1',
  String number = 'PR-001',
  String supplierId = 'sup-1',
  String branchId = 'br-1',
  ReceiptStatus status = ReceiptStatus.draft,
  List<ReceiptLine>? lines,
  double total = 0,
  DateTime? date,
}) => Receipt(
  id: id,
  number: number,
  supplierId: supplierId,
  branchId: branchId,
  date: date ?? DateTime(2026, 6, 1),
  status: status,
  lines: lines ?? const [],
  total: total,
);

StockItem sampleStockItem({
  String productId = 'p1',
  String productName = 'Аспирин',
  String? barcode = '4600000000001',
  String series = 'S-1',
  DateTime? expiry,
  double quantity = 5,
  double salePrice = 15,
}) => StockItem(
  productId: productId,
  productName: productName,
  barcode: barcode,
  batchId: 'b-$productId',
  seriesNumber: series,
  expiryDate: expiry ?? DateTime(2027, 1, 1),
  quantity: quantity,
  salePrice: salePrice,
  branchId: 'br-1',
);

LowStockItem sampleLowItem({
  String productId = 'p1',
  String productName = 'Аспирин',
  double totalQuantity = 3,
  double minStockLevel = 10,
}) => LowStockItem(
  productId: productId,
  productName: productName,
  totalQuantity: totalQuantity,
  minStockLevel: minStockLevel,
);

StockMovement sampleMovement({
  String id = 'm1',
  String productId = 'p1',
  String type = 'Receipt',
  double quantity = 5,
  String? documentType = 'Приход',
  DateTime? createdAt,
}) => StockMovement(
  id: id,
  productId: productId,
  batchId: 'b1',
  type: type,
  quantity: quantity,
  createdAt: createdAt ?? DateTime(2026, 6, 1, 10, 30),
  documentType: documentType,
);
