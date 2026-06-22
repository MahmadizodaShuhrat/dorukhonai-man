/// Feature-local test doubles for the Reports + Settings tracks. Kept separate
/// from the shared `test/support/fakes.dart` (which other tracks edit) per the
/// track rules. Import the shared file too where its builders are useful.
library;

import 'package:dorukhonai_man/core/api/api_result.dart';
import 'package:dorukhonai_man/features/auth/data/auth_models.dart';
import 'package:dorukhonai_man/features/pos/data/pos_models.dart';
import 'package:dorukhonai_man/features/reports/data/report_models.dart';
import 'package:dorukhonai_man/features/reports/data/reports_repository.dart';
import 'package:dorukhonai_man/features/settings/data/settings_repository.dart';
import 'package:dorukhonai_man/features/settings/data/users_repository.dart';
import 'package:dorukhonai_man/features/stock/data/stock_models.dart';

/// Fake [ReportsRepository] with canned outcomes per report.
class FakeReportsRepository implements ReportsRepository {
  FakeReportsRepository({
    this.salesResult,
    this.profitResult,
    this.stockValueResult,
    this.expiringResult,
    this.zReportResult,
  });

  ApiResult<List<SalesReportRow>>? salesResult;
  ApiResult<ProfitReport>? profitResult;
  ApiResult<List<StockValueRow>>? stockValueResult;
  ApiResult<List<StockItem>>? expiringResult;
  ApiResult<ZReport>? zReportResult;

  int salesCalls = 0;
  int profitCalls = 0;
  int stockValueCalls = 0;
  int expiringCalls = 0;
  int zReportCalls = 0;

  DateTime? lastFrom;
  DateTime? lastTo;
  SalesGroupBy? lastGroupBy;
  String? lastShiftId;

  @override
  Future<ApiResult<List<SalesReportRow>>> sales({
    required DateTime from,
    required DateTime to,
    SalesGroupBy groupBy = SalesGroupBy.day,
    String? branchId,
  }) async {
    salesCalls++;
    lastFrom = from;
    lastTo = to;
    lastGroupBy = groupBy;
    return salesResult ?? const Success(<SalesReportRow>[]);
  }

  @override
  Future<ApiResult<ProfitReport>> profit({
    required DateTime from,
    required DateTime to,
  }) async {
    profitCalls++;
    lastFrom = from;
    lastTo = to;
    return profitResult ??
        const Success(
          ProfitReport(revenue: 0, cost: 0, profit: 0, margin: 0),
        );
  }

  @override
  Future<ApiResult<List<StockValueRow>>> stockValue({String? branchId}) async {
    stockValueCalls++;
    return stockValueResult ?? const Success(<StockValueRow>[]);
  }

  @override
  Future<ApiResult<List<StockItem>>> expiring() async {
    expiringCalls++;
    return expiringResult ?? const Success(<StockItem>[]);
  }

  @override
  Future<ApiResult<ZReport>> zReport(String shiftId) async {
    zReportCalls++;
    lastShiftId = shiftId;
    return zReportResult ?? const Error(UnknownFailure());
  }
}

/// Fake [UsersRepository] for the Admin user-list section.
class FakeUsersRepository implements UsersRepository {
  FakeUsersRepository({
    this.listResult,
    this.deactivateResult,
    this.createResult,
    this.updateResult,
  });

  ApiResult<List<User>>? listResult;
  ApiResult<void>? deactivateResult;
  ApiResult<User>? createResult;
  ApiResult<User>? updateResult;

  int listCalls = 0;
  int deactivateCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  String? lastDeactivatedId;
  String? lastCreatedUserName;
  String? lastUpdatedId;

  @override
  Future<ApiResult<List<User>>> list() async {
    listCalls++;
    return listResult ?? const Success(<User>[]);
  }

  @override
  Future<ApiResult<User>> create({
    required String fullName,
    required String userName,
    required String password,
    required UserRole role,
  }) async {
    createCalls++;
    lastCreatedUserName = userName;
    return createResult ??
        Success(
          User(id: 'new', fullName: fullName, userName: userName, role: role),
        );
  }

  @override
  Future<ApiResult<User>> update({
    required String id,
    required String fullName,
    required UserRole role,
    bool? isActive,
  }) async {
    updateCalls++;
    lastUpdatedId = id;
    return updateResult ??
        Success(User(id: id, fullName: fullName, userName: '', role: role));
  }

  @override
  Future<ApiResult<void>> deactivate(String id) async {
    deactivateCalls++;
    lastDeactivatedId = id;
    return deactivateResult ?? const Success(null);
  }
}

/// Fake [SettingsRepository] for the Settings track. Defaults to canned values
/// so the controller's init load is network-free and deterministic.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({this.getResult, this.updateResult});

  ApiResult<ServerSettings>? getResult;
  ApiResult<ServerSettings>? updateResult;

  int getCalls = 0;
  int updateCalls = 0;
  double? lastMarkup;
  int? lastAlertDays;

  @override
  Future<ApiResult<ServerSettings>> get() async {
    getCalls++;
    return getResult ?? const Success(ServerSettings());
  }

  @override
  Future<ApiResult<ServerSettings>> update({
    double? markupPercent,
    int? expiryAlertDays,
  }) async {
    updateCalls++;
    lastMarkup = markupPercent;
    lastAlertDays = expiryAlertDays;
    return updateResult ??
        Success(
          ServerSettings(
            markupPercent: markupPercent,
            expiryAlertDays: expiryAlertDays,
          ),
        );
  }
}

/// Sample builders.
SalesReportRow sampleSalesRow({
  String label = '2026-06-20',
  int salesCount = 3,
  double quantity = 10,
  double subtotal = 100,
  double discount = 5,
  double total = 95,
  DateTime? date,
}) => SalesReportRow(
  label: label,
  salesCount: salesCount,
  quantity: quantity,
  subtotal: subtotal,
  discount: discount,
  total: total,
  date: date ?? DateTime(2026, 6, 20),
);
