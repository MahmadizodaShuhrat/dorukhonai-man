# TZ_05 — FINALIZATION PLAN (Lead Architect synthesis)

Single prioritized plan to take Dorukhona from "builds + runs" to "complete, no hardcode, ready to test with REAL data." Synthesizes the Backend, Flutter, and Completeness audits.

- Backend: .NET 10, `c:\Users\mirqu\OneDrive\Desktop\dorukhonai man\backend`
- Flutter: `c:\Users\mirqu\OneDrive\Desktop\dorukhonai man\dorukhonai_man`
- Spec: `docs\TZ_00..TZ_04`

> Verified during this audit: only 12 backend controllers exist (Auth, CashShifts, DrugGroups, Manufacturers, Products, Receipts, Reports, Sales, Stock, Suppliers, Sync, Units). `OpenCashShiftRequest.BranchId` is a `Guid` (so the literal `'default'` cannot deserialize → 400). `AuthUserInfo` carries only Id/FullName/UserName/Role (no branch). `ReportsController` exposes only `z-report`. All MODUL 6 + Setting + AuditLog entities and DbSets exist (`AppDbContext.cs:47-63`) — no schema work needed.
> Note: spec claims of "42 backend / 191 Flutter tests" and ".NET 8" were not all verifiable; backend is .NET 10 with ~38 backend test methods. Treat test counts as approximate.

---

## 1. HARDCODE / PLACEHOLDER REMOVAL LIST (file:line → fix)

### Backend
| # | Location | Issue | Fix |
|---|---|---|---|
| H1 | `backend/src/Dorukhona.Api/Program.cs:47` | JWT key dev fallback `?? "CHANGE_ME_DEV_ONLY_..."` — silently boots with a public signing key | Remove the `??`. Throw on missing/`<32` char `Jwt:Key`. Load from env/user-secrets. |
| H2 | `backend/src/Dorukhona.Api/appsettings.json:21` | Placeholder JWT key committed | Move to env / `appsettings.Production.json` (uncommitted). Generate real 32+ char key out-of-band. |
| H3 | `backend/src/Dorukhona.Api/appsettings.json:18` | DB password baked in (`postgres/postgres@localhost`) | Move connection string to env var for real-data run. |
| H4 | `backend/src/Dorukhona.Infrastructure/Persistence/DbSeeder.cs:17-18` | Seeded `admin / Admin123!` | Read seed password from config/env; force password change on first login. |
| H5 | `DbSeeder.cs:19,83` | Central branch name + random Id hardcoded | Make name configurable; ship `/branches` so it is editable (see B6). |
| H6 | `StockController.cs:18` + `GetExpiringStockQueryHandler.cs:11` | `90` expiry threshold duplicated, hardcoded | Read from `Setting` (`expiry.alertDays`); collapse to one config-driven value (see B8). |
| H7 | `Program.cs:101-106` | CORS `AllowAnyOrigin` | Restrict origins via config before deployment. |
| H8 | `JwtOptions.cs:19` | `RefreshTokenDays` not in config (default-only) | Add `Jwt:RefreshTokenDays`. (LOW) |

### Flutter
| # | Location | Issue | Fix |
|---|---|---|---|
| H9 | `lib/features/pos/presentation/pos_screen.dart:47,67-70` | `defaultBranchId = 'default'` — invalid GUID, breaks open-shift (P0) | Resolve real branch GUID from `/auth/me` (after B5b) or `GET /branches` (B6); seed `setBranchId` with it; delete the literal. |
| H10 | `lib/app/app_shell.dart:475-479` | Top-bar branch name `'Дорухонаи марказӣ'` hardcoded | Bind to `branchProvider` from `/branches` or `/auth/me`. |
| H11 | `lib/app/app_shell.dart:481-487` | Shift chip `'Смена баста'` static placeholder | Watch `cashShiftControllerProvider` / `/cash-shifts/current`; render open/closed + time; onTap → POS. |
| H12 | `lib/app/app_shell.dart:86-91,138,493-497` | Command palette (Ctrl+K) + search button = toast "ба зудӣ" | Implement real `CommandPalette` overlay (reuse `EntityPicker` search-dialog pattern). |
| H13 | `lib/features/settings/presentation/settings_screen.dart:287-374`; `settings_provider.dart:21,51` | Markup % placeholder, SharedPreferences-only | Wire to `GET/PUT /settings`, or gate as "future" until pricing module exists. |
| H14 | `settings_screen.dart:377-403` | Printer section is static text | Add printer selection via `Printing.listPrinters()`, or gate as "future". |
| H15 | `settings_provider.dart:43-49` | Alert-days persists locally only, never reaches backend | Wire to `GET/PUT /settings` so server expiry job uses it. |
| H16 | `lib/shared/placeholder_screen.dart` | Dead code, not routed | Delete once MODUL 6 screens land. (POLISH) |

Clean (no action): `api_config.dart` host resolution, top-bar user name (from session `app_shell.dart:466,499`), no mock/fake data in production widgets, no routes point at `PlaceholderScreen`.

---

## 2. REMAINING-WORK LIST (Backend / Flutter)

### BACKEND

**BW1 — Branch resolution (P0).** Add `GET /branches` (`BranchesController`) and include the branch in the auth payload: extend `AuthUserInfo` (`backend/src/Dorukhona.Application/Auth/Dtos/AuthUserInfo.cs`) with `BranchId` (+ name) sourced via `UserBranch`.
- Reuse: `Branch`, `UserBranch` entities; `IdentityService.GetUserInfo`.
- Acceptance: login response and `/auth/me` carry the real branch GUID; `GET /branches` returns the seeded branch; POS can open a shift with that GUID (no 400).

**BW2 — Reports endpoints (P0).** Implement `GET /reports/sales?groupBy=&from=&to=`, `/reports/profit?from=&to=`, `/reports/stock-value`, `/reports/expiring` in `ReportsController` + Application queries/handlers.
- Reuse: existing Sales/SaleLine/StockMovement/Stock data; mirror `GetZReport` handler pattern.
- Contract: match the (tolerant) Flutter parsers in `report_models.dart` — `sales` rows `{ label|key|date|productName|sellerName, salesCount|count, quantity, subtotal?, discount?, total }`; `profit` `{ revenue, cost, profit, margin? }`; `stock-value` rows `{ productName?, quantity, purchaseValue|costValue, saleValue|retailValue }`.
- Acceptance: all 4 Reports tabs render real data, no 404.

**BW3 — Users CRUD (P0).** `UsersController`: `GET /users`, `POST /users`, `PUT /users/{id}`, `POST /users/{id}/deactivate`. `[Authorize(Roles="Admin")]`.
- Reuse: `AppUser` (Role/IsActive/FullName), `UserManager<AppUser>`; deactivate = `IsActive=false` (auth already honors it, `IdentityService.cs:24,38,63`).
- Acceptance: Settings → Корбарон lists/creates/edits/deactivates real users.

**BW4 — MODUL 6: WriteOff / Inventory / SupplierReturn (P1).** Application commands+handlers+validators + controllers: `POST /write-offs`, `POST /inventory`, `POST /supplier-returns`. Each adjusts Stock + writes `StockMovement` in one transaction.
- Reuse (no schema change): `WriteOff/WriteOffLine` + `WriteOffReason`; `Inventory/InventoryLine` (Expected/Actual/Difference → adjustment); `SupplierReturn/SupplierReturnLine`; `MovementType.WriteOff/Inventory/SupplierReturn`; mirror `PostReceiptCommandHandler` transaction pattern.
- Acceptance: posting each doc changes Stock correctly and appears in `GET /stock/movements` with the right `MovementType`. (Transfer + MODUL 8 deferred per TZ_00 §5.)

**BW5 — Audit log write + query (P1).** Add a MediatR `IPipelineBehavior` (or expand `AuditSaveChangesInterceptor`, which today only stamps Created/Updated fields) to insert `AuditLog` rows (UserId, Action, Entity, EntityId, Details) on every mutating command. Add `GET /audit-logs?userId=&from=&to=`.
- Reuse: `AuditLog` entity (`AppDbContext.cs:62`), `ICurrentUser`.
- Acceptance: each mutating command produces an `AuditLog` row; query returns filtered rows.

**BW6 — Settings + markup (P1).** `GET/PUT /settings` over the `Setting` table; seed defaults (`expiry.alertDays`=90/30, `markup.percent`, low-stock behavior). Wire `GetExpiringStock` to read `expiry.alertDays`. Add markup logic to `PostReceiptCommandHandler` (currently copies SalePrice verbatim, `:60-69`).
- Reuse: `Setting` entity (`AppDbContext.cs:63`), `ReferenceConfigurations.cs:84`.
- Acceptance: changing alert-days in Settings changes `/stock/expiring`; markup applied on receipt posting.

**BW7 — Expiry alert HostedService (P1).** Daily background near-expiry check using `expiry.alertDays` (TZ_01 §5.5). Acceptance: runs daily, surfaces expiring batches.

**BW8 — Leftovers (P3).** `GET /drug-reference` (МНН, MODUL 2); automated backup job; confirm Transfer/MODUL 8 deferred.

### FLUTTER

**FW1 — Branch wiring (P0).** Consume `branchId`/branch from login (after BW1); add `branchProvider`; seed POS `setBranchId` with the real GUID; remove `defaultBranchId`. Acceptance: shift opens against real branch end-to-end.

**FW2 — MODUL 6 screens (P1).** Three operation screens + routes + repositories/providers for Списание / Инвентаризатсия / Бозгашт ба таъминкунанда; sidebar group "Амалиёти анбор" near Анбор.
- Reuse: `AppScaffold`, `AppDataTable`, `ProductPickerDialog.show()`, `EntityPicker` (supplier), `EmptyState`/`LoadingState`, `movementTypeLabel` (`stock_detail_panel.dart:256`); mirror `stock_repository` offline-first decorator + `router.dart`/`app_shell.dart` `_NavItem` wiring.
- Acceptance: each screen posts to its endpoint and shows the resulting movement.

**FW3 — Users admin actions (P1).** Add create/edit/deactivate to `_UsersAdminSection` (`settings_screen.dart:470`) on top of `users_repository` (deactivate already exists).

**FW4 — Top bar + Ctrl+K (P2).** Implement command palette (H12); bind branch name (H10) + shift chip (H11).

**FW5 — Reports CSV save dialog (P2).** Add `file_selector` to `pubspec.yaml`; use `getSaveLocation()` in `report_export.dart:61-72` (`saveCsv`) — PDF already uses the OS dialog.

**FW6 — Settings finish (P2/Polish).** Wire markup + alert-days to `/settings` (H13/H15), printer selection (H14), delete `placeholder_screen.dart` (H16).

---

## 3. UI-WITHOUT-BACKEND MISMATCHES (MUST-FIX before real data)

| Flutter caller | Endpoint | Backend status | Effect | Fix |
|---|---|---|---|---|
| `users_repository.dart:32,55` | `GET /users`, `POST /users/{id}/deactivate` | MISSING | Корбарон section always errors | BW3 |
| `reports_repository.dart:61,80,98,110` | `/reports/sales,profit,stock-value,expiring` | MISSING (only z-report) | 4 of 5 report tabs 404 | BW2 |
| `pos_screen.dart` → open shift | `POST /cash-shifts/open` with `branchId='default'` | `BranchId` is `Guid` + `BranchExists` validator | 400 / unknown branch; whole POS chain blocked | BW1 + FW1 |
| `pos_repository.dart:110` | `GET /cash-shifts/current?branchId=` (empty) | binds `Guid.Empty` → 404 | Dashboard "current shift" KPI never shows open | Pass real branch GUID (after BW1) |
| Settings markup/alert-days | (no `/settings`) | MISSING | Local-only; never affects server | BW6 |

Contract risk: when BW2 is built, JSON must match `report_models.dart` keys (parsers are tolerant but expect the listed aliases). When BW3 is built, match `users_repository` shapes.

---

## 4. REAL-DATA SEED PLAN (believable end-to-end test)

Goal: a dataset that exercises FEFO, expiry alerts, low-stock, receipts→stock→sale→return→Z-report→reports, and MODUL 6.

1. **Branch + users (after BW1/BW3):** 1 branch "Дорухонаи марказӣ" (real GUID exposed via `/auth/me`). Users: 1 Admin, 1 Manager, 2 Sellers, 1 Storekeeper — real names; admin password set at seed via env, force-change on first login.
2. **Reference data:** ~10 manufacturers (mix local/import), ~6 drug-groups (Антибиотикҳо, Анальгетикҳо, Витаминҳо, Дилу рагҳо, Меъдаю рӯда, Гормоналӣ), units (дона, мг, мл, упаковка), ~8 suppliers with real contact fields.
3. **Products:** ~60-80 realistic SKUs (e.g. Парацетамол 500мг, Амоксициллин 500мг, Ибупрофен 200мг, Аспирин, Омепразол, Метформин, витамин C) spanning groups, with barcodes, units, drug-group + manufacturer links.
4. **Receipts (Приход):** 8-12 posted receipts across suppliers, creating **multiple batches per product** with **different expiry dates** (critical for FEFO) and varying purchase prices. Set sale prices (or via markup after BW6).
5. **Expiry/low-stock spread:** ensure several batches expire within 30 and 90 days (drive expiry alerts), a few already expired (write-off candidates), and several products below low-stock threshold.
6. **Settings (after BW6):** seed `expiry.alertDays`=90 (and 30), `markup.percent`, low-stock threshold.
7. **POS activity:** open a shift, ring ~20-30 sales across sellers (mix cash/card, some discounts) over a few days → verify FEFO consumes earliest-expiry batch first; do 2-3 returns; close shift → Z-report.
8. **MODUL 6 (after BW4):** 1-2 write-offs (Expired/Damaged), 1 inventory count with a deliberate discrepancy (Expected≠Actual → adjustment), 1 supplier-return.
9. **Audit (after BW5):** confirm the above mutations produced `AuditLog` rows queryable by user/date.
10. **Reports check (after BW2):** sales (by day/product/seller), profit (revenue/cost/margin sane), stock-value, expiring — all populated and internally consistent.

---

## 5. PHASED IMPLEMENTATION ORDER

**Phase 0 — Secrets / config hardening (fast, unblocks safe real-data run):** H1-H7 (JWT key fail-fast, move secrets to env, seed admin from env + force change, CORS restrict).

**Phase 1 — P0 real-data blockers (nothing works end-to-end without these):**
- BW1 branch resolution + FW1 branch wiring (remove `'default'`).
- BW3 users CRUD (unblocks Корбарон).
- BW2 reports endpoints (unblocks 4 report tabs).

**Phase 2 — P1 required modules:**
- BW4 MODUL 6 backend + FW2 MODUL 6 screens; FW3 user admin actions.
- BW6 settings + markup; BW5 audit write/query; BW7 expiry job.

**Phase 3 — De-hardcode / finish redesign (P2):** H10/H11 top bar, H12 Ctrl+K palette (FW4), FW5 CSV save dialog, H13/H14/H15 settings wiring, H16 delete placeholder.

**Phase 4 — Leftovers (P3):** BW8 drug-reference (МНН), automated backup; confirm Transfer/MODUL 8 stay deferred.

**Phase 5 — Real-data dry run:** execute §4 seed plan against a fresh migrated DB with real secrets; walk the full receipt→stock→FEFO sale→return→Z-report→reports + MODUL 6 + audit flow; fix any contract mismatches.
