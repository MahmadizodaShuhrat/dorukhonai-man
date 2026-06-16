# ТЗ — Қисми 1: Backend (.NET / ASP.NET Core)

> Техническое задание барои сервер. Дастур (developer) аз рӯи ин қадам ба қадам кор мекунад.
> Алоқа: `TZ_00_TAHLILI_ILOVAGI.md` (қоидаҳо), `TZ_02_FRONTEND_FLUTTER.md` (мизоҷ).

**Стек:** .NET 8 LTS • ASP.NET Core Web API • EF Core • PostgreSQL • JWT
**Архитектура:** Clean Architecture (4 қабат)

---

## 1. Сохтори лоиҳа (Project structure)

```
Dorukhona.sln
├── src/
│   ├── Dorukhona.Domain/            # Entities, enums, қоидаҳои core (бе вобастагӣ)
│   ├── Dorukhona.Application/       # Use-cases, DTO, interface, validation (CQRS/MediatR)
│   ├── Dorukhona.Infrastructure/    # EF Core, DbContext, repository, JWT, файл, email
│   └── Dorukhona.Api/               # Controllers, middleware, DI, Program.cs, Swagger
└── tests/
    ├── Dorukhona.UnitTests/
    └── Dorukhona.IntegrationTests/
```

**Қоидаи вобастагӣ:** `Api → Application → Domain`, `Infrastructure → Application/Domain`.
Domain ба ҳеҷ чиз вобаста нест. Application танҳо ба interface (на ба EF).

---

## 2. Пакетҳои NuGet (асосӣ)

| Пакет | Барои чӣ |
|-------|----------|
| `Microsoft.EntityFrameworkCore` + `Npgsql.EntityFrameworkCore.PostgreSQL` | ORM + PostgreSQL |
| `MediatR` | CQRS (Command/Query) |
| `FluentValidation.AspNetCore` | Валидатсия |
| `AutoMapper` | Entity ↔ DTO |
| `Microsoft.AspNetCore.Authentication.JwtBearer` | JWT |
| `Microsoft.AspNetCore.Identity.EntityFrameworkCore` | Корбарон/парол |
| `Serilog.AspNetCore` | Лог |
| `Swashbuckle.AspNetCore` | Swagger |
| `Microsoft.AspNetCore.SignalR` (дилхоҳ) | Real-time |

---

## 3. Тарҳи маълумотгоҳ (Database / Entities)

> Тамоми ID = `Guid` (барои синхрони шабака осон). Ҳама ҷадвал майдонҳои аудит доранд:
> `CreatedAt, CreatedBy, UpdatedAt, UpdatedBy, IsDeleted` (soft-delete).

### 3.1. Феҳристи ҷадвалҳо (entities)

**Корбарон ва дастрасӣ**
- `Branch` — филиал: `Id, Name, Address, Phone, IsCentral, IsActive`
- `User` (Identity) — `Id, FullName, UserName, PasswordHash, Role, IsActive`
- `UserBranch` — кадом корбар ба кадом филиал (many-to-many)

**Справочникҳо**
- `DrugReference` — эталон: `Id, Inn, TradeName, Form, Dosage, ManufacturerId, RxRequired`
- `Product` — корти дору (номенклатура): `Id, Name, Barcode, DrugReferenceId?, GroupId, ManufacturerId, UnitId, RxRequired, IsActive`
- `DrugGroup` — `Id, Name, ParentId?`
- `Manufacturer` — `Id, Name, Country`
- `Supplier` — `Id, Name, Inn, Phone, Address`
- `Unit` — `Id, Name (дона/упаковка)`

**Партия ва бақия (қалби система)**
- `Batch` (партия/серия) — `Id, ProductId, SeriesNumber, ExpiryDate, PurchasePrice, SalePrice`
- `Stock` (бақия) — `Id, BranchId, BatchId, Quantity` *(бақия ҳамеша аз рӯи партия + филиал)*
- `StockMovement` (ҳаракат) — `Id, BranchId, BatchId, Type(enum), Quantity(+/-), DocumentId, DocumentType, CreatedAt` *(таърихи ҳама ҳаракат)*

**Ҳуҷҷатҳои амалиётӣ (ҳар кадом Header + Lines)**
- `Receipt` / `ReceiptLine` — қабули мол (приход)
- `Sale` / `SaleLine` — фурӯш
- `SaleReturn` / `SaleReturnLine` — бозгашти фурӯш
- `WriteOff` / `WriteOffLine` — списание
- `Inventory` / `InventoryLine` — инвентаризатсия
- `Transfer` / `TransferLine` — перемещение байни филиалҳо
- `SupplierReturn` / `SupplierReturnLine` — бозгашт ба таъминкунанда

**Касса**
- `CashShift` (смена) — `Id, BranchId, UserId, OpenedAt, ClosedAt?, OpeningCash, ClosingCash, TotalSales, Status`
- `Payment` — `Id, SaleId, Method(enum: Cash/Card/Credit), Amount`

**Системавӣ**
- `PriceHistory` — `Id, ProductId, OldPrice, NewPrice, ChangedAt, ChangedBy`
- `AuditLog` — `Id, UserId, Action, Entity, EntityId, Details(json), CreatedAt`
- `Setting` — `Key, Value` (наценка, рӯзҳои огоҳӣ ва ғ.)

### 3.2. Enums асосӣ
```
MovementType: Receipt, Sale, SaleReturn, WriteOff, TransferOut, TransferIn, Inventory, SupplierReturn
PaymentMethod: Cash, Card, Credit, Mixed
DocStatus: Draft, Posted, Cancelled
UserRole: Admin, Manager, Seller, Storekeeper
WriteOffReason: Expired, Damaged, Lost, Other
```

### 3.3. Қоидаҳои муҳими база
- `Stock.Quantity >= 0` ҳамеша (check constraint).
- `Batch.ExpiryDate` ҳатмӣ барои дору.
- Индекс: `Product.Barcode`, `Batch.ExpiryDate`, `Stock(BranchId, BatchId)`.
- Ҳама амалиёти бақия дар **транзаксия** (ACID).

---

## 4. API Endpoints (контракти асосӣ)

> Префикс: `/api/v1`. Ҳама ҷавоб — JSON. Ҳама (ҷуз login) — JWT талаб мекунад.
> Формати ҷавоб: `{ "data": ..., "error": null }` ё хато бо HTTP-код.

### 4.1. Auth
```
POST   /auth/login            → { token, refreshToken, user }
POST   /auth/refresh
POST   /auth/logout
GET    /auth/me
```

### 4.2. Справочникҳо
```
GET    /products?search=&groupId=&page=&size=
GET    /products/{id}
GET    /products/by-barcode/{barcode}      ← касса инро истифода мебарад
POST   /products
PUT    /products/{id}
DELETE /products/{id}                       (soft delete)

GET/POST/PUT/DELETE  /drug-groups
GET/POST/PUT/DELETE  /manufacturers
GET/POST/PUT/DELETE  /suppliers
GET/POST/PUT/DELETE  /units
GET    /drug-reference?search=              ← справочники МНН
```

### 4.3. Приход (Қабули мол)
```
GET    /receipts?from=&to=&supplierId=&status=
GET    /receipts/{id}
POST   /receipts                 (Draft эҷод)
PUT    /receipts/{id}
POST   /receipts/{id}/post       ← тасдиқ: Batch+Stock сохта/зиёд мешавад
POST   /receipts/{id}/cancel
```

### 4.4. Анбор
```
GET    /stock?branchId=&search=&page=
GET    /stock/expiring?days=90&branchId=     ← мӯҳлати наздик
GET    /stock/low?branchId=                  ← зери минимум
GET    /stock/movements?productId=&from=&to=
```

### 4.5. Касса (POS)
```
POST   /cash-shifts/open         { branchId, openingCash }
POST   /cash-shifts/close        { closingCash } → Z-отчёт
GET    /cash-shifts/current

POST   /sales                    { branchId, lines[], payments[] }  ← FEFO дар сервер
GET    /sales/{id}
GET    /sales?shiftId=&from=&to=
POST   /sales/{id}/return        { lines[] }   ← возврат
POST   /sales/{id}/print         (ё чек дар клиент)
```

### 4.6. Амалиёти анборӣ
```
POST   /write-offs               { branchId, reason, lines[] }
POST   /inventory                { branchId, lines[ actual qty ] } → коррексия
POST   /transfers                { fromBranch, toBranch, lines[] }
POST   /transfers/{id}/accept    (қабул дар филиали мақсад)
POST   /supplier-returns         { supplierId, lines[] }
```

### 4.7. Ҳисоботҳо
```
GET    /reports/sales?from=&to=&branchId=&groupBy=day|product|seller
GET    /reports/stock-value?branchId=
GET    /reports/profit?from=&to=
GET    /reports/expiring
GET    /reports/z-report/{shiftId}
```

### 4.8. Системавӣ
```
GET    /users        POST /users   PUT /users/{id}   POST /users/{id}/deactivate
GET    /branches     POST /branches  ...
GET    /audit-logs?userId=&from=&to=
GET/PUT /settings
```

### 4.9. Синхронизатсия (Offline — ҲАТМӢ, касса бе интернет)
> Касса offline мефурӯшад, баъд маълумотро ба сервер мефиристад. Ду самт:
```
# PULL — клиент кэши справочник/нарх/бақияро мегирад (delta аз рӯи вақт)
GET    /sync/catalog?since={timestamp}     → доруҳо, нарх, бақияи тағйирёфта

# PUSH — фурӯшҳои offline-сохташуда ба сервер фиристода мешаванд
POST   /sync/sales                         { sales[] бо ClientId-и ягона }
   → сервер FEFO-ро аз нав ҳисоб, бақияро кам мекунад;
   → idempotent: ClientId такрорӣ → дубора сабт намешавад;
   → ҷавоб: барои ҳар фурӯш { clientId, serverId, status: ok|conflict }
```
**Қоидаҳои sync:**
- Ҳар фурӯши offline `ClientId` (Guid дар клиент) дорад → дубликат пешгирӣ.
- Сервер манбаи ҳақиқати бақия аст; ҳангоми камии бақия → `conflict` бармегардонад.
- Клиент пас аз `ok` фурӯшро аз навбати pending тоза мекунад.

---

## 5. Мантиқи муҳими бизнес (дар сервер, на дар клиент!)

1. **Фурӯш (POST /sales):** дар як транзаксия:
   - барои ҳар сатр → партияҳоро аз рӯи **FEFO** (мӯҳлат наздиктар аввал) интихоб кун;
   - агар бақия нарасад → хато (`400 Insufficient stock`);
   - агар партияи мӯҳлаташ гузашта → манъ;
   - `Stock` кам, `StockMovement` сабт, нарх қайд мешавад;
   - `Payment` сабт; ба `CashShift` ҷамъ илова.
2. **Приход post:** `Batch` эҷод/ёфт, `Stock` зиёд, `StockMovement(+)`.
3. **Бозгашт:** `Stock` зиёд, пул баргардонида, `StockMovement(SaleReturn)`.
4. **Списание/Инвентаризатсия:** коррексияи `Stock` бо `StockMovement`.
5. **Огоҳии мӯҳлат:** background job (Hangfire/HostedService) ҳаррӯза тафтиш.
6. **Audit log:** ҳар Command-и тағйирдиҳанда автоматӣ сабт (MediatR behavior).

---

## 6. Бехатарӣ
- JWT (access ~15 дақ + refresh). Парол — ASP.NET Identity (hash).
- Авторизатсия аз рӯи нақш: `[Authorize(Roles="Admin,Manager")]`.
- HTTPS ҳатмӣ. CORS барои клиенти Flutter.
- Rate limiting ба `/auth/login`.
- Ҳама input → FluentValidation.

---

## 7. Қадам ба қадам (Roadmap барои developer)

> Ҳар қадам = як sprint. Дар охири ҳар қадам: тест + commit + Swagger нав.

| Қадам | Кор | Натиҷа (Definition of Done) |
|-------|-----|------------------------------|
| **0. Setup** | Solution, 4 проект, Git, EF, PostgreSQL, Serilog, Swagger | Проект меравад, Swagger кушода мешавад |
| **1. Auth** | Identity, JWT, login/refresh/me, нақшҳо | Воридшавӣ кор мекунад, токен меояд |
| **2. Справочникҳо** | Product, Group, Manufacturer, Supplier, Unit — CRUD | CRUD-и ҳама справочник + миграция |
| **3. Приход** | Receipt+Lines, Batch, Stock, post/cancel | Приход тасдиқ → бақия зиёд мешавад |
| **4. Анбор** | Stock query, expiring, low, movements | Рӯйхати бақия ва мӯҳлат кор мекунад |
| **5. Касса** | CashShift, Sale (FEFO), Payment, Return | Фурӯш бақияро кам мекунад, FEFO дуруст |
| **6. Sync (offline)** | `/sync/catalog`, `/sync/sales` (idempotent) | Фурӯши offline дубора бе хато қабул мешавад |
| **7. Амалиёти анборӣ** | WriteOff, Inventory, SupplierReturn | Ҳар амалиёт `StockMovement` месозад |
| **8. Ҳисоботҳо** | Sales, profit, stock-value, z-report | Ҳисоботҳо рақамҳои дуруст медиҳанд |
| **9. Корбарон/ҳуқуқ** | User CRUD, role-based authorization, audit log | Ҳуқуқ кор мекунад, лог сабт мешавад |
| **10. Стабилизатсия** | Тестҳо, backup, Docker, деплой | Тест сабз, backup автоматӣ, деплой |
| **11. Шабака ⏸️** | Transfer, анбори марказӣ, ҳисоботи умумӣ (баъди 1-уми филиал) | Бисёрфилиалӣ — фазаи минбаъда |

> **Эзоҳ (қарорҳои ТЗ_00):** маркировка/фискалӣ нест → бе мантиқи МДЛП ва драйвери фискалӣ.
> 1 филиал дар оғоз → `Transfer` ва модули шабака ба қадами 11 (баъди MVP) гузашт.

---

## 8. Стандартҳои код
- C# nullable enabled, `async/await` ҳама ҷо, CancellationToken.
- Як Controller = як модул, борик; мантиқ дар Application (Handler).
- DTO ↔ Entity бо AutoMapper; ҳеҷ гоҳ Entity-ро рост бармагардон.
- Миграцияҳои EF дар Git. Seed-и аввала: Admin, филиали 1, воҳидҳо.
- Тест: ҳадди ақал мантиқи бақия ва FEFO unit-test шавад.

---

## 9. Definition of Done (умумӣ барои MVP сервер)
- [ ] Login + нақшҳо кор мекунад.
- [ ] Приход → бақия зиёд; фурӯш → бақия кам (FEFO).
- [ ] Мӯҳлати гузашта намефурӯшад; бақия манфӣ намешавад.
- [ ] Z-отчёти смена дуруст.
- [ ] Swagger пурра ва санҷидашуда.
- [ ] Backup ҳаррӯза + миграцияҳо дар Git.
