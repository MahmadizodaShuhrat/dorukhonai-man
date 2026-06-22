# ТЗ — Қисми 4: Offline-First Architecture

> Нақшаи пурраи offline: касса бояд бе интернет фурӯшад (TZ_00 §3, §5 — ҲАТМӢ).
> Алоқа: `TZ_00`, `TZ_01_BACKEND_DOTNET.md` (§4.9 sync — PLANNED, ҳоло НЕСТ),
> `TZ_02`, `TZ_03_DESKTOP_REDESIGN.md`.

**Сана:** 2026-06-22
**Стек:** Drift (SQLite) • connectivity_plus • esc_pos_utils/printing • Riverpod.
**Факти асосӣ:** `drift`/`sqlite3_flutter_libs`/`path_provider` дар `pubspec.yaml` declare
шудаанд, вале дар `lib/` **ягон DB/sync/ClientId/outbox нест** — offline тамоман greenfield.

---

## 0. Факти load-bearing (аз код тасдиқшуда)

- **Server-side FEFO** (`CreateSaleCommandHandler.cs`): `ORDER BY Batch.ExpiryDate, Batch.Id`,
  `WHERE ExpiryDate >= today` (мӯҳлат гузаштаро истисно), нарх аз `Batch.SalePrice`, **смена
  кушода** (CashShift branch+user) ҳатмӣ, decrement-и `Stock` дар транзаксия, ҳангоми
  нарасидани бақия `ValidationException` → **тамоми фурӯш rollback**.
- **JWT:** access = 15 дақиқа (`appsettings.json ExpiryMinutes:15`), refresh rotating (hash).
- **DioClient:** single-flight `401 → refresh → retry-once → forced-logout`.
- **1 филиал** = соддакунандаи асосӣ: контентсияи cross-terminal-и stock нест, терминали
  офлайн дар байни sync танҳо writer ба stock аст → local FEFO бо сервер мувофиқ мешавад.

---

## 1. Матритсаи feature → offline

| Қобилият | Ҳолат | Чаро |
|---|---|---|
| **Login (бори аввал)** | ONLINE-ONLY | Hash + JWT танҳо дар сервер. |
| **Идомаи сессия (аллакай login)** | OFFLINE | `User`+role дар secure storage кэш; UI gating аз нақши кэшшуда (на токени live). |
| **Browse catalog (products/groups/manufacturers/suppliers/units/by-barcode)** | OFFLINE | Reference оҳиста-тағйир → пурра mirror дар Drift; barcode = индекси маҳаллӣ. |
| **Browse stock/balance/expiring/low** | OFFLINE (freshness каме degraded) | Snapshot-и last-sync МИНУС фурӯшҳои queued-и ҳамин терминал (local decrement). 1 терминал → дақиқ. |
| **POS sale + FEFO + чоп** | OFFLINE | Маркази кор. Local FEFO аз batches-и кэш, local decrement, чопи ESC/POS, queue бо `ClientId`. Сервер authoritative FEFO-ро re-run мекунад. |
| **Бозгашт (возврат)** | DEGRADED | Агар фурӯши synced (serverId) → queue бо `serverSaleId`+`saleLineId`. Агар pending → фурӯши pending-ро local amend/cancel (бе конфликт). |
| **Кушодани смена** | OFFLINE | Local record бо `ClientId`; "1 смена кушода"-ро local enforce (1 терминал). |
| **Бастани смена / Z-report** | DEGRADED | Local Z аз local sales/returns; сервер authoritative баъди sync; агар фарқ → "Z пас аз sync навсозӣ шуд". |
| **Эҷод+тасдиқи Приход** | DEGRADED | Draft офлайн озод; Post офлайн provisional бо `clientBatchId` → reconcile ба server batch id. (Агар соҳиб соддагӣ хоҳад → Post ONLINE-ONLY.) |
| **Списание/Инвентаризатсия/Transfer/Возврат таъминкунанда** | ONLINE-ONLY | Кам, back-office, на критикии касса. |
| **Reports (sales/profit/stock-value)** | DEGRADED | Имрӯз local; таърихӣ "as of last sync" / ONLINE барои диапазони нав. |
| **User management / settings** | ONLINE-ONLY | Admin, на критикӣ. |

**Кафолати net:** кассир метавонад **смена кушояд, scan/sell бо FEFO, нақд/корт, чеки чоп,
возврати фурӯши synced, бастани смена бо Z-report-и local** — пурра офлайн, номаҳдуд — баъд
ҳама ҳангоми васл reconcile мешавад.

---

## 2. Drift schema (SQLite) — `lib/core/storage/db/`

Ҳама entity Guid (TZ §3) → client ва server як ID-space; client Guid PK мезанад, сервер
verbatim қабул мекунад (асоси idempotency).

**Кэши server (read-mostly, бо PULL refresh):**

- `products` — `id(TEXT pk), name, barcode(idx), drugGroupId, manufacturerId, unitId,
  rxRequired(bool), isActive(bool), minStockLevel(real?), lastSalePrice(real?), updatedAt, isDeleted`
- `drugGroups` — `id, name, parentId`
- `manufacturers` — `id, name, country`
- `suppliers` — `id, name, inn, phone, address`
- `units` — `id, name`
- `batches` — `id(pk), productId(idx), seriesNumber, expiryDate(DATE idx), purchasePrice,
  salePrice, updatedAt, isDeleted` ← **ин offline FEFO-ро имконпазир мекунад** (batches, на
  танҳо aggregate)
- `stock` — `id(pk), branchId, batchId(idx), quantity(real), updatedAt`; unique `(branchId,batchId)`

**Local-only (манбаи ҳақиқати кори офлайн):**

- `localSales` — `clientId(TEXT pk Guid), serverId(TEXT?), clientShiftId, branchId, sellerId,
  createdAt, subtotal, discount, total, status(pendingPush|pushed|conflict|superseded),
  serverNumber?, conflictReason?`
- `localSaleLines` — `id, saleClientId(fk), productId, clientBatchId, quantity, unitPrice,
  lineDiscount, lineTotal`
- `localPayments` — `id, saleClientId(fk), method, amount`
- `localReturns` — `clientId(pk), serverId?, serverSaleId, clientShiftId, createdAt, status`
  + `localReturnLines(saleLineId, quantity)`
- `localShifts` — `clientId(pk), serverId?, branchId, userId, openingCash, openedAt, closedAt?,
  closingCash?, status(open|closed|pushed|conflict)`
- `localReceipts`/`localReceiptLines` — танҳо агар offline-Post фаъол; line-ҳо `clientBatchId`
- **`outbox`** — навбати command-и durable: `id(autoincr), entityType(shift_open|shift_close|
  sale|return|receipt_post), entityClientId(Guid), payloadJson, createdAt, attemptCount,
  lastAttemptAt?, lastError?, status(queued|inflight|done|failed_conflict)`. FIFO per shift.
- **`syncCursor`** — `resource(TEXT pk: 'catalog'|'stock'), sinceToken(TEXT), lastSyncAt`
- `localStockMovements` (ихтиёрӣ) — mirror-и decrement-ҳои queued барои ledger-и дақиқи local

**Cached (PULL):** products, groups, manufacturers, suppliers, units, batches, base stock,
last sale price, settings (markup, expiry-days).
**Computed local:** FEFO allocation, line totals/subtotal/total, on-hand =
`stock.quantity − Σ(queued line qty барои batch)`, Z-report-и имрӯз, expiry/low flags.

---

## 3. FEFO офлайн + reconciliation

**Client метавонад FEFO-ро local ҳисоб кунад — ва бояд, чун `batches` кэш аст.** Алгоритм
айнан мисли сервер:

```
candidates = batches барои productId
   JOIN stock(branchId,batchId) WHERE effectiveQty > 0
   WHERE expiryDate >= today          // истиснои гузашта — ҳамон қоидаи сервер
   ORDER BY expiryDate ASC, batchId ASC   // ҳамон FEFO + tie-break
effectiveQty(batch) = stock.quantity − Σ(queued, not-yet-pushed line qty барои batch)
allocate greedily то qty пур шавад; агар Σ effectiveQty < requested → блок ("бақия нарасид")
нарх аз batch.salePrice (кэш); total = Σ
```

Order key, истиснои гузашта, нархи per-batch, қоидаи shortfall — **ҳамон константҳои
`CreateSaleCommandHandler`** → терминали офлайни 1-гона дар аксар маврид ҳамон allocation-ро
медиҳад. Local decrement фавран → фурӯшҳои пайдарпайи офлайн дуруст chain мешаванд.

**Сервер манбаи ҳақиқат — reconciliation дар PUSH.** Client фурӯшро ҳамчун
**product + quantity + ClientId** (НА batch split) мефиристад. Сервер batch-и client-ро
нодида гирифта, FEFO-и худро re-run мекунад. Се натиҷа:

1. **`ok`** — сервер allocate кард; `serverId`+`number`+server lines бармегардонад. Client:
   `status=pushed`, `serverId` нигоҳ, local lines-ро бо server lines иваз (то возврати оянда
   `saleLineId`-и воқеӣ реф кунад), local stock-ро ба allocation-и сервер reconcile.
2. **`conflict_price`** — нарх баъди PULL дар сервер тағйир ёфт. Сиёсат: сервер барои чеки
   аллакай чопшуда **нархи snapshot-и client-ро қабул мекунад** (`clientUnitPrice` фиристода
   мешавад) + audit-и price-variance. (Чек дар дасти муштарист.)
3. **`conflict_stock`** — сервер пур карда наметавонад (stock-и воқеӣ камтар; масалан receipt
   reversed/write-off дар сервер). Дар 1 филиал/1 терминал қариб ғайриимкон, вале:
   - Сервер **қисман post намекунад**; `conflict_stock` + `available` per product бармегардонад.
   - Client task-и conflict ба менеҷер: "Фурӯши S-… book нашуд: X дархост N, мавҷуд M".
     Имкон: (a) **force-post** (менеҷер adjustment-и компенсаторӣ иҷозат), (b) **void + cash
     refund**. То ҳал — `conflict`, аз total-ҳои synced истисно.
   - Idempotency → retry ҳеҷ гоҳ double-book намекунад.

**Қоидаи асосӣ:** client ҳеҷ гоҳ ба batch id-и худаш барои record-и сервер бовар намекунад.
`clientBatchId` танҳо барои on-hand ва чеки provisional. Баъди `ok` — server lines authoritative.

---

## 4. Sync protocol

### PULL (delta down)
```
GET /api/v1/sync/catalog?since={cursor}
  → { products[], drugGroups[], manufacturers[], suppliers[], units[], batches[],
      deletes[], cursor }
GET /api/v1/sync/stock?since={cursor}&branchId={id}
  → { stock:[{branchId,batchId,quantity,updatedAt}], cursor }
```
`since` аз `syncCursor.sinceToken`; сервер танҳо `UpdatedAt > since` + tombstones; client upsert
+ cursor atomic. Run-и аввал = snapshot пурра (`since` холӣ).

### PUSH (outbox FIFO)
```
POST /api/v1/sync/shifts        { shifts:[{ clientId, branchId, openingCash, openedAt, closedAt?, closingCash? }] }
POST /api/v1/sync/sales         { sales:[{ clientId, clientShiftId, branchId, createdAt,
                                           lines:[{productId, quantity, lineDiscount, clientUnitPrice}],
                                           payments:[{method, amount}], discount }] }
POST /api/v1/sync/sale-returns  { returns:[{ clientId, serverSaleId, lines:[{saleLineId, quantity}] }] }
POST /api/v1/sync/receipts      { receipts:[{ clientId, supplierId, branchId, date, number,
                                              lines:[{productId, clientBatchId, seriesNumber, expiryDate,
                                                      purchasePrice, salePrice, quantity}] }] }  // агар offline-post
```
Ҳар item: `{ clientId, serverId, status: ok|conflict_stock|conflict_price|duplicate,
serverNumber?, lines?, available? }`.

**Ordering (критикӣ):** outbox-ро **per shift, дар ин тартиб** drain кун: `shift_open` →
`sale`/`return`/`receipt_post` бо `createdAt` → `shift_close`. Сервер sale-и shift-и
синхроннашударо қабул накунад (`412 shift_not_synced`, retryable). Client тартибро бо
`outbox.id` (autoincr) кафолат медиҳад.

**Retry:** backoff экспоненсиалӣ (2s, 8s, 30s, 2m, cap 5m) дар network/5xx; ҳеҷ гоҳ drop
накунад. Event-и connectivity-restored → drain-и фаврӣ.

**Idempotency:** `ClientId` (Guid) калиди idempotency дар ҳар entity. Re-push → `duplicate` +
`serverId`-и аслӣ (бе double-book). Client `duplicate` = `ok`.

---

## 5. Auth офлайн (нуқтаи тез)

- **Login аввал:** ONLINE-ONLY; баъди муваффақият `User`(id,role,fullName) дар secure storage.
- **Кор бо JWT-и valid:** оддӣ.
- **JWT дар офлайн expire (15 дақ кӯтоҳ!):** DioClient-и ҳозира `401 → refresh fail → forced
  logout` — дар миёнаи смена ғайриқобили қабул. **Тағйир (Flutter):** forced-logout-ро ба
  connectivity gate кун. Дар офлайн (ё refresh бо network error, на 401) **токенро тоза накун,
  logout накун**; offline-session аз `User`/role-и кэшшуда authorise. Local POS бе ягон
  server call кор мекунад → access token офлайн bemaъно.
- **Reconnect:** пеш аз drain → `/auth/refresh`. Агар refresh token expire → re-login лозим,
  вале **outbox гум намешавад** (push баъди re-auth). Refresh lifetime-ро дароз кун (рӯз/ҳафта).
- 401-и воқеиро аз network error фарқ кун — танҳо 401-и refresh-rejected logout мекунад.

---

## 6. Offline UX

- **Индикатори connectivity** дар top bar: сабз "Онлайн" / зард "Офлайн — фурӯш кор мекунад"
  (`connectivityProvider` + last-successful timestamp).
- **Pending-sync badge:** counter-и outbox `status != done` → click → **Sync queue panel**
  (ҳар item: статус, attemptCount, lastError, "Sync now").
- **Per-receipt status chip** дар рӯйхати фурӯш: Pending / Synced / Conflict.
- **Conflict:** banner барҷаста + **Conflict resolution screen** (manager-gated) бо `available`
  + ду амал (force-post / void+refund); то ҳал visually flagged, аз total-и settled истисно.
- **Stale hint:** stock/reports → "Маълумот то: {lastSyncAt}" дар офлайн.
- **Z-report офлайн:** "Пешакӣ (то синхрон)"; баъди sync навсозӣ; агар тағйир → "Z пас аз
  синхрон навсозӣ шуд".

---

## 7. BACKEND (.NET) work list — sequenced (TZ_01 §4.9, ҳоло НЕСТ)

1. **Index-ҳои delta:** covering index ба `Product.UpdatedAt`, `Batch.UpdatedAt`,
   `Stock.UpdatedAt` (UpdatedAt аллакай дар audit fields ҳаст). Cursor = UTC timestamp
   (ё opaque string).
2. **`SyncController`** бо 6 endpoint (2 PULL, 4 PUSH).
3. **`ClientId (Guid, unique, nullable)`** ба `Sale`, `SaleReturn`, `CashShift` (+`Receipt`
   агар offline-post) + migration + unique index → idempotency дар сатҳи DB.
4. **`CreateSaleCommandHandler`-ро refactor кун** то бо `ClientId`, resolution-и
   `clientShiftId→serverShiftId`, ва `createdAt` backdating даъват шавад. Body-и FEFO verbatim;
   танҳо wrap → map shift + short-circuit дар duplicate `ClientId`.
5. **`POST /sync/shifts`** (idempotent open/close бо ClientId).
6. **`POST /sync/sales`** — wrap-и FEFO бо idempotency, `clientShiftId` resolution, backdating,
   натиҷаи structured `conflict_stock`/`conflict_price`, honour `clientUnitPrice`.
7. **`POST /sync/sale-returns`** (idempotent, реф `serverSaleId`).
8. (Ихтиёрӣ) **`POST /sync/receipts`** + map-и `clientBatchId→serverBatchId`; client reф-ҳои
   кэшро rewrite мекунад.
9. **Refresh-token lifetime-ро дароз кун**; мутмаин шав `GET /reports/z-report/{shiftId}` барои
   shift-и sync-created кор мекунад.

---

## 8. FLUTTER work list — sequenced

1. **Deps:** `connectivity_plus`; (drift/sqlite3_flutter_libs/path_provider аллакай ҳаст).
   Drift codegen бо `drift_dev`/`build_runner`.
2. **Drift schema (§2):** cached tables, local operational tables, `outbox`, `syncCursor`; DAOs.
3. **DioClient/TokenStorage fix (§5):** forced-logout-ро дар network failure suppress кун;
   `User` кэш; offline-session gating аз role; proactive refresh дар reconnect; 401-ро аз
   network фарқ кун.
4. **PULL service:** snapshot-и пурра дар run-и аввал, delta баъдан; upsert ба Drift; cursor
   advance.
5. **Offline-first read repos** (products/stock): хондан аз Drift, write-through дар онлайн.
6. **Offline POS path:** local FEFO allocator (mirror-и константҳои сервер), local stock
   decrement, local shift open/close, local Z-report, чопи ESC/POS офлайн.
7. **Outbox + sync engine:** drain-и FIFO-per-shift, push-и idempotent бо `ClientId`,
   retry/backoff, drain-и connectivity-triggered.
8. **Reconciliation:** apply-и `ok`/`duplicate`/`conflict`; local lines → server lines; state advance.
9. **UX:** connectivity indicator, pending-sync badge + queue panel, per-sale status chips,
   conflict resolution screen (manager-gated), staleness labels.

---

## 9. ОГОҲИИ муҳим ба соҳиб (build dependency)

`/sync/catalog` ва `/sync/sales` **PLANNED, ҳоло implement нашудаанд** (TZ_01 §4.9, roadmap
step 6). Сатҳи реалии offline:

- **Имрӯз (бе sync API):** кассир тамоман офлайн рафта наметавонад — ҳар фурӯш API-и live-ро
  даъват мекунад. Ягона "offline"-и имрӯзӣ = graceful failure (banner "интернет нест" дар
  header-и нав).
- **Баъди Drift + `/sync/catalog`:** scan/search/browse/build-cart пурра офлайн (нарх аз кэш).
- **Баъди `/sync/sales` (idempotent бо ClientId):** checkout-и пурраи офлайн — TZ_00 target.

**Хулоса:** UI-и offline (badge, queue, conflict) ҳозир бар зидди Drift сохта мешавад, вале
**offline-и бехатари воқеӣ аввал ду endpoint-и sync-ро мехоҳад.** Ин ягона gap-и backend аст,
ки feature-и асосии "бе интернет кор мекунад"-ро блок мекунад → бояд аввал сохта шавад.

**Файлҳои реф:** FEFO/idempotency anchor
`backend/src/Dorukhona.Application/Sales/Commands/CreateSale/CreateSaleCommandHandler.cs` +
`…/Sales/Dtos/CreateSaleRequest.cs`; token
`backend/src/Dorukhona.Api/appsettings.json` (`Jwt.ExpiryMinutes:15`) +
`…/Auth/Commands/Refresh/RefreshCommandHandler.cs`; client
`dorukhonai_man/lib/core/api/dio_client.dart`, `…/lib/core/storage/token_storage.dart`,
`…/lib/features/pos/data/pos_repository.dart`, `…/lib/features/stock/data/stock_models.dart`,
`…/lib/features/products/data/product_models.dart`. `/sync` controller дар backend ҳоло НЕСТ.
