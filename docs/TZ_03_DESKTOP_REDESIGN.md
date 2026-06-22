# ТЗ — Қисми 3: Desktop Redesign (Windows + macOS)

> Мастер-плани таҳияи нав: барномаи касса/анбор **танҳо desktop** (Windows + macOS),
> бо UI-и касбии дорухона/POS. Мобилӣ (iOS/Android) ва web **партофта мешаванд**.
> Алоқа: `TZ_00_TAHLILI_ILOVAGI.md`, `TZ_01_BACKEND_DOTNET.md`, `TZ_02_FRONTEND_FLUTTER.md`, `TZ_04_OFFLINE_ARCHITECTURE.md`.

**Сана:** 2026-06-22
**Қарори соҳиб (FIXED):** desktop-only (Windows + macOS), beautiful professional pharmacy UI, real features wired to the existing backend, maximize offline.
**Платформа:** Windows 10/11 + macOS. Stack бетағйир: Flutter • Riverpod • Dio • go_router • Drift • Material 3.

---

## 0. Чаро таҳияи нав — мушкилоти асосии барномаи ҳозира

Барнома cross-platform/responsive сохта шуда буд: `app_shell.dart` бо `LayoutBuilder`
дар breakpoint 800px байни `NavigationRail` (васеъ) ва bottom `NavigationBar` (танг)
иваз мешавад. Дар лаптоп ин ҳамчун «телефони калоншуда» дида мешавад — назорати
калон, фазои уфуқии беҳуда, бе контексти доимӣ, маълумотдарорӣ бо dialog-ҳо.

**Мушкилоти ҳалшаванда (аз audit):**

1. **Shell-и мобилӣ** — bottom `NavigationBar` дар равзанаи танги лаптоп; 6 destination-и
   ҳамворшуда бе гурӯҳбандӣ, бе header/branding, бе нишондиҳандаи смена/онлайн.
   (`app_shell.dart:40-62`)
2. **Бе window chrome** — `windows/runner/main.cpp` шаблон: 1280×720, бе минималӣ;
   равзанаро то кӣ ҷадвалҳо мебуранд танг кардан мумкин. Унвони равзана `dorukhonai_man`.
3. **Бе дашборд** — `initialLocation: /pos`; саҳифаи асосӣ нест; огоҳиҳои мӯҳлат/камшуда
   дар таб-ҳои `/stock` дафн шудаанд, ҳеҷ ҷо global нестанд.
4. **Бе ҷустуҷӯи global / command palette** — ҷустуҷӯ танҳо дар дохили ҳар экран.
5. **Маълумотдарорӣ бо dialog** — ҳар сатри приход = ду dialog (`product_picker` →
   `receipt_line_dialog`); барои клавиатура азобовар.
6. **FK ҳамчун матни озод (бадтарин)** — `drugGroupId`/`manufacturerId`/`unitId`/`supplierId`/
   `branchId` дастӣ GUID навишта мешаванд (`product_form_screen.dart:193-217`,
   `receipt_edit_screen.dart:425-448`, `pos_screen.dart:541-548`).
7. **Дастгирии заифи клавиатура** — Del танҳо баъди интихоби сатр бо муш; миқдор фақат
   бо `+`/`-`; бе hotkey берун аз POS.
8. **Тугмаҳои хурди мобилӣ** — `IconButton size:18-20`, `FloatingActionButton.extended`,
   pagination танҳо бо chevron.
9. **Темаи умумӣ** — `ColorScheme.fromSeed` teal, бе зичӣ (density), бе styling-и ҷадвал,
   бе рангҳои семантикии огоҳӣ (ad-hoc amber/red дар `stock_screen.dart`).
10. **Reports placeholder, Settings = logout** — бе корбарон/нақшҳо/нарх/принтер.
11. **Offline тамоман нест** — `drift` declare шуда, вале дар `lib/` ягон DB/sync нест
    (нигаред TZ_04).

**Нигоҳ дошта мешавад (хуб аст):** server-side FEFO ва нархгузории authoritative;
Riverpod `StateNotifier` + repository abstraction; `Failure` + Dio mapping; JWT
single-flight refresh interceptor; ProductPicker scan-flow (USB 1D); 97 тест бо fakes;
paged envelope + debounced search; expiry-tint logic (ба system-и муштараки огоҳӣ
кӯчонда мешавад).

---

## A) APP SHELL — се минтақа

`LayoutBuilder`/breakpoint/bottom-nav **тамоман нест карда мешавад.** Як shell-и
desktop-и собит: sidebar доимии чап + top bar + минтақаи контент бо page-header.

```
+----------------------------------------------------------------------------------+
| TOP BAR  (56px) — branch · shift · online/offline · Ctrl+K search · user menu     |
+--------------+-------------------------------------------------------------------+
|              |                                                                   |
|  SIDEBAR     |   PAGE HEADER  (title · breadcrumb · primary action · view tabs)   |
|  (240px,     |   ----------------------------------------------------------------|
|  collapsible |                                                                   |
|  to 64px)    |   CONTENT  (tables / master-detail / dashboard grid)              |
|              |                                                                   |
+--------------+-------------------------------------------------------------------+
```

- **Минималии равзана:** `1100 × 720`. Default launch `1440 × 900`. Зери 1100w контент
  бо horizontal scroll корӣ мемонад (бе reflow ба мобилӣ). Тавассути `window_manager`
  `setMinimumSize`. Андоза/мавқеъ дар `shared_preferences` нигоҳ дошта мешавад.
- **Sidebar:** доимӣ, чап, 240px кушода / 64px пӯшида (танҳо icon + tooltip). Toggle дар
  поён; ҳолат дар pref маҳаллӣ. Item-и фаъол: pill-и filled (`secondaryContainer`).
- **Top bar:** дар ҳама route mount мемонад (қисми shell, на per-screen `AppBar`).
  Амалҳои ҳар экран дар **page header** ҳастанд, на дар top bar.

### A.2 Sidebar — гурӯҳбандӣ дусатҳа (ивази rail-и ҳамвори 6-итемӣ)

```
DOROHONA  (logo)

  ▸ Дашборд            (dashboard)        Ctrl+1
  ▸ Касса / POS        (point_of_sale)    Ctrl+2   ← badge: "Смена кушода" нуқта
  ▸ Анбор              (warehouse)        Ctrl+3   ← badge: low+expiring count
  ▸ Приход             (inventory_2)      Ctrl+4

  МАЪЛУМОТНОМАҲО  (expandable group)
    • Доруҳо            (medication)
    • Гурӯҳҳо           (category)
    • Таъминкунандагон  (local_shipping)
    • Истеҳсолкунандагон(factory)
    • Воҳидҳо           (straighten)

  ▸ Ҳисоботҳо          (bar_chart)        Ctrl+5
  ▸ Танзимот           (settings)         Ctrl+6

  ─────────────
  ⟨⟩ collapse           v1.0 · online
```

**Role-gating (TZ_00 §4):** Фурӯшанда → Дашборд, Касса, Анбор (хондан). Анбордор +Приход,
+Амалиёт. Менеджер/Admin → ҳама; Танзимот/Корбарон танҳо Admin. Item-ҳои манъ
**пинҳон** мешаванд, на disable.

### A.3 Top bar (чап → рост)

| Slot | Контент | Манбаъ | Рафтор |
|---|---|---|---|
| Branch | `🏪 Дорухонаи марказӣ` (chip) | `GET /branches` (1 ҳозир) | Статикӣ ҳозир; dropdown баъди MODUL 8. Picker нест (қарори TZ_00). |
| Shift | `🟢 Смена кушода · 14:02` / `⚪ Баста` | `GET /cash-shifts/current` | Click → POS. Сабз=кушода, хокистарӣ=баста. |
| Sync/online | `🟢 Онлайн` / `🟠 Офлайн · 3 навбат` | connectivity + Drift pending | Tooltip: вақти охирин sync + pending; click → sync panel. |
| Search | `🔍 Ҷустуҷӯ ё фармон…  Ctrl+K` | command palette | Ҳамеша намоён. |
| User | avatar + ном + нақш; menu | `GET /auth/me` | профиль, забон (TJ/RU), тема, баромад. |

### A.4 Command palette (Ctrl+K)

Modal марказӣ, 640px, fuzzy search. Се гурӯҳ: **Навигатсия** (ҷаҳидан ба бахш),
**Амалҳо** ("Кушодани смена", "Приходи нав", "Списание", "Ҷустуҷӯи дору"),
**Дору/Товар** (live `GET /products?search=` + Drift cache). Клавиатура: `↑/↓` ҳаракат,
`Enter` иҷро, `Esc` пӯшидан. Бо `Shortcuts`/`Actions` + overlay.

### A.5 Page-header (як шакл барои ҳама экран, баландӣ 64px, hairline border поён)

```
[ Icon ]  Анбор                                   [ filter chips ]   [ + Primary action ]
          Бақия · 1 240 ададҳо · навсозӣ 14:31      [ Бақия | Мӯҳлат | Камшуда ]  tabs
```

Чап: icon + H1 + subtitle (count/last-updated). Марказ (ихтиёрӣ): segmented view-tabs.
Рост: 0–1 `FilledButton` primary + overflow menu барои амалҳои дуюмдараҷа.

---

## B) DESIGN SYSTEM — се самт; ТАВСИЯИ ниҳоӣ + 2 алтернатива

### B.0 ТАВСИЯ — Direction 1: Clinical Teal (refined)

Seed `#0E7C66` (амиқтар аз `#00796B`-и ҳозира), системаи карти flat-bordered, +
`StatusColors` `ThemeExtension`.

**Чаро:**
1. **Давомнокӣ** — код аллакай teal seed мекунад; амиқтар кардан як хат, бе rebrand.
2. **Мувофиқат** — сабз "дорухона/клиникӣ" хонда мешавад; дар канори шкалаи
   сабз→зард→сурхи мӯҳлат табиӣ менишинад (огоҳии мӯҳлат/камшуда муҳимтарин signal).
3. **Хонданӣ** — ранги brand ором, ранги сершуда танҳо барои status → ҷадвалҳои зич
   ором мемонанд ва огоҳиҳо барҷаста.

### B.1 Алтернативаҳо (соҳиб интихоб мекунад)

| Самт | Seed | Эҳсос | Эзоҳ |
|---|---|---|---|
| **1. Clinical Teal** ✅ | `#0E7C66` | Ором, тиббӣ, сабзи дорухона | Familiar; бо шкалаи сабз/зард/сурх табиӣ. |
| **2. Professional Indigo** | `#3A4DB3` | Ҷиддӣ "ERP/молия" | Эътимоди баланд; dark mode-и қавӣ; вале бо ҳуҷайраҳои сурх/зард рақобат мекунад. |
| **3. Warm Neutral + Teal accent** | neutral `#5B6166` + accent `#0E9C8A` | Ором, маълумот-аввал, камхастагӣ | Ҷадвалҳо қаҳрамон; ранг танҳо status; вале аз ҳозира дуртар. |

Ҳама бо `ColorScheme.fromSeed(seed, brightness)`. Рангҳои status **берун** аз seed
(ThemeExtension) то бо hue-и primary бархӯрд накунанд.

### B.2 StatusColors (ThemeExtension)

| Token | Light | Dark | Истифода |
|---|---|---|---|
| `danger` / expired | `#C62828` on `#FDECEC` | `#FF6B6B` on `#3A1A1A` | мӯҳлат гузашта, бақия нарасид, офлайн-хато |
| `warn` / near | `#B26A00` on `#FFF4E2` | `#FFB74D` on `#3A2E16` | ≤30 рӯз, low stock, pending sync |
| `ok` / healthy | `#2E7D32` on `#E8F5E9` | `#81C784` on `#16331A` | солим, posted, synced/online |
| `info` | primaryContainer | primaryContainer | draft, badge-и нейтралӣ |

**Шкалаи мӯҳлат (аз `StockItem.daysUntilExpiry`, TZ_00 §1.2 қоидаи 4):** `<0` гузашта (сурх),
`0–30` наздик (сурх-зард), `31–90` ба зудӣ (зард), `>90` ок (сабз). Low вақте
`totalQuantity < minStockLevel` (`LowStockItem`).

### B.3 Typography — ду зичӣ

Default desktop (ивази oversize-и global): H1 саҳифа 22/w600; H2 18/w600; body 14
(буд 16); ҳуҷайраи ҷадвал 13.5, header 12.5/w600/+0.3 spacing; caption 12.
**POS override:** танҳо POS register калон мемонад — сатри сабад 18, ҷамъи сатр 20,
**ҶАМЪ 40/w700**, тугмаи ПАРДОХТ 20. Тавассути scoped `Theme` гирди subtree-и POS
(на theme-и global). Font: system default (Segoe UI / SF). `FontFeature.tabularFigures()`
дар ҳама сутуни пул/миқдор.

### B.4–B.6 Зичӣ, elevation, ҷадвал

- 8px grid; gutters 16/24; padding 24. `VisualDensity.compact` global; ҷадвал row 36px.
  `materialTapTargetSize: shrinkWrap`.
- **Flat-bordered (desktop, на телефон):** карт elevation 0, `surfaceContainerLow` fill,
  1px `outlineVariant` border, radius 10. Top bar/sidebar elevation 0 + hairline. Танҳо
  surface-ҳои transient (palette, dialog, menu, toast) elevation 3–6. Input:
  `OutlineInputBorder`, `isDense:true`, radius 8, padding `(12,10)`.
- **`AppDataTable`** (дар `data_table_2`): sticky header (`fixedTopRows`), header fill
  `surfaceContainer`, border ҳар сатр `outlineVariant`, row 36, single-select →
  side-panel, hover highlight, сутуни рақамӣ рост-чин + tabular figures + `Formatters.money`,
  sort indicators, `fixedLeftColumns:1` барои ҷадвали васеъ, status → `StatusChip`,
  ҳолатҳои empty/loading(shimmer)/error дарунсохт.

### B.7 Widget-ҳои нав (`shared/`)

`AppScaffold` (page-header), `AppDataTable`, `StatusChip`, `KpiCard`, `SidePanel` (380px
master-detail), `EntityPicker` (typeahead — ивази typed ID), `MoneyField`,
`DatePickerField`, `Toast`/`AppSnackBar`, `EmptyState`, `LoadingOverlay`, `FKeyHint`
(`F9` chip), `CommandPalette`.

---

## C) ЭКРАН БА ЭКРАН

### C.1 Дашборд (НАВ)

Манбаъ: `GET /reports/sales?from=today`, `/stock/expiring?days=90`, `/stock/low`,
`/cash-shifts/current`, `/reports/sales?groupBy=day`.

```
+--------------+-------------------------------------------------------------------+
| SIDEBAR      | 📊 Дашборд                              Имрӯз, 22.06.2026         |
|              |-------------------------------------------------------------------|
| ▸Дашборд ●   |  +------------+ +------------+ +------------+ +------------+        |
|  Касса       |  | ФУРӮШИ     | | МӮҲЛАТ      | | КАМШУДА    | | СМЕНА      |        |
|  Анбор       |  | ИМРӮЗ      | | НАЗДИК(90р) | | (зери мин) | |            |        |
|  Приход      |  | 4 820 смн  | |   18 🟠     | |    7 🔴    | | 🟢 Кушода  |        |
|  …           |  | 32 чек     | | дору        | | дору       | | 14:02      |        |
|              |  +------------+ +------------+ +------------+ +------------+        |
|              |                                                                   |
|              |  +-------------------------------+ +----------------------------+ |
|              |  | ⚠ Мӯҳлаташ наздик (топ-8)     | | Амалҳои зуд                | |
|              |  | Дору          Серия  Мӯҳл  Бақ| |  [ + Приходи нав        ]  | |
|              |  | Аспирин 500   A12   12р🔴  40 | |  [ ▶ Кушодани смена     ]  | |
|              |  | Парацетамол   B07   25р🟠  12 | |  [ 🔍 Ҷустуҷӯи дору       ] | |
|              |  | …                            | |  [ 📉 Списание           ]  | |
|              |  | [ Ҳамаро дидан → Анбор ]      | |                            | |
|              |  +-------------------------------+ +----------------------------+ |
|              |                                                                   |
|              |  +-----------------------------------------------------------+    |
|              |  | Фурӯш — 7 рӯзи охир (fl_chart bar/line)                    |    |
|              |  +-----------------------------------------------------------+    |
+--------------+-------------------------------------------------------------------+
```

4 `KpiCard` (рақами калон + label + delta + click-through; Expiring/Low бо `StatusColors`);
мини-ҷадвали "Мӯҳлаташ наздик" топ-8 → click → детали stock; амалҳои зуд wired; карти
смена ба "Бастани смена / Z-отчёт" иваз мешавад вақте кушода. Reports gated by role.

### C.2 POS register (full-screen, keyboard-first) — марказ

Logic-и мавҷуда нигоҳ дошта мешавад (`posCartControllerProvider`,
`saleSubmitControllerProvider`, `cashShiftControllerProvider`) + USB-1D scanner pattern.

```
+----------------------------------------------------------------------------------+
| 🟢 Смена кушода · Касса №1 · Фурӯшанда: Алӣ      🟠 Офлайн · 3 навбат   [⎙ принтер]|
+----------------------------------------------------+-----------------------------+
| 🔍 [ Штрих-кодро скан кунед ё ном…           (F2) ]| ҲИСОБ                        |
|----------------------------------------------------|                             |
| #  Дору                Сер. Мӯҳ.  Миқ  Нарх   Ҷамъ |  Зерҷамъ        4 820.00     |
|----------------------------------------------------|  Тахфиф (F4)    – 200.00     |
| 1  Аспирин 500мг #10   A12  🟠   [- 2 +] 12.00 24.0|  ─────────────────────────  |
| 2  Парацетамол 500     B07  🟢   [- 1 +]  8.00  8.0|                             |
| 3  Амоксициллин ℞      C30  🟢   [- 1 +] 36.00 36.0|   ҲАМАГӢ                     |
|    (℞ = ретсептӣ — огоҳӣ)                           |   4 620.00 смн              |
|                                                    |                             |
|  ← сатри интихобшуда highlight; Del = ҳазф          |  Тарзи пардохт:             |
|                                                    |  [ Нақд (F9) ] [ Корт ]     |
|                                                    |  [ Қарз ] [ Омехта ]        |
|                                                    |                             |
|                                                    |  +-----------------------+  |
|                                                    |  |   ПАРДОХТ  (F9)        |  |
|                                                    |  +-----------------------+  |
|----------------------------------------------------|                             |
| F2 Ҷустуҷӯ · F4 Тахфиф · Del Ҳазф · F9 Пардохт · Esc| 3 сатр · 4 ададҳо           |
+----------------------------------------------------+-----------------------------+
```

- **Чап (≈65%):** scan bar доимӣ (autofocus, баъди ҳар амал refocus), сабад ҳамчун
  `AppDataTable`. Сутун: # / Дору / Серия / Мӯҳлат-chip / Миқдор-stepper (тайп кардани
  рақам, на танҳо +/−) / Нарх / Ҷамъ. Серия/мӯҳлат **indicative** (сервер FEFO-ро
  иҷро ва сатрро split мекунад). Дору ретсептӣ → `℞` badge + confirm (TZ_00 §1.2 қоидаи 5).
- **Рост (≈35%):** subtotal, тахфиф, **ҶАМЪ** (40px), тугмаҳои tender (`PaymentMethod`
  аллакай ҳаст), як тугмаи калони **ПАРДОХТ**. Омехта → split dialog.
- **F-key hint bar** (`FKeyHint`): F2/F4/Del/F9/Esc + F7 Бозгашт + F10 Бастани смена.
- **Pay:** `PaymentDialog` → confirm-и чек (`Sale.changeDue`) → auto-print ESC/POS
  (чеки оддӣ) → cart clear + refocus scan. Бе драйвери фискалӣ.
- **Бе смена:** карти марказии "Кушодани смена" бо openingCash (бе "Филиал (ID)" —
  бо 1 филиал implicit).
- **Офлайн:** агар `POST /sales` ноком → сабт ба Drift `pending` бо `ClientId`, чоп,
  нишон додани change; badge зиёд мешавад (TZ_04).

### C.3 Анбор / Stock (master-detail + view tabs)

Манбаъ: `/stock`, `/stock/expiring?days=`, `/stock/low`, `/stock/movements`.

```
+--------------+-------------------------------------------------------------------+
| SIDEBAR      | 🏬 Анбор    [Бақия | Мӯҳлати наздик | Камшуда]      🔍[ ҷустуҷӯ ]  |
|              |             Гурӯҳ ▾  Истеҳсолкунанда ▾  Мӯҳлат: [90р ▾]            |
|              |-------------------------------------------------+-----------------|
|              | Дору            Серия Мӯҳлат   Бақия Нарх        | ДЕТАЛИ ДОРУ      |
|              | Аспирин 500мг   A12  12р 🔴    40    12.00       | Аспирин 500мг    |
|              | Парацетамол     B07  25р 🟠    12     8.00 ◀sel  | Штрих:4870...    |
|              | Амоксициллин    C30  120р🟢  150    36.00       | Гурӯҳ: Анальгет. |
|              | …                                               | ℞: не · Воҳид:дона|
|              |                                                 | ─── Партияҳо ─── |
|              |                                                 | A12  40  12р🔴   |
|              |                                                 | B19 110 200р🟢   |
|              |                                                 | ─── Ҳаракат ──── |
|              |                                                 | 22.06 Фурӯш −2   |
|              |                                                 | 20.06 Приход +50 |
|              | 1 240 сатр · саҳ. 1/25                          | [Списание][Таърих]|
+--------------+-------------------------------------------------------------------+
```

Tabs = се endpoint. "Мӯҳлати наздик" default 90р бо 30/60/90 selector; рангҳо аз
`StatusColors`. "Камшуда" — `totalQuantity` vs `minStockLevel` бо shortfall bar.
`SidePanel` (row select): header + ҳама партияҳо + ledger (`/stock/movements?productId=`)
бо `MovementType` labels; амал: Списание, кушодани корти дору. Filter: гурӯҳ/
истеҳсолкунанда (`EntityPicker`), ҷустуҷӯ ном/штрих. Pagination lazy.

### C.4 Приход / Receipts (рӯйхат + редактори full-page, НА dialog)

Манбаъ: `/receipts`, `/receipts/{id}`, `POST /receipts`, `/receipts/{id}/post|cancel`.
`receipt_line_dialog.dart` бартараф мешавад.

```
LIST                                    EDITOR (route /receipts/:id)
+-----------------------------------+   +-------------------------------------------+
| 📥 Приход        [ + Приходи нав ]|   | ← Приход №RC-00042   [Draft]  [Тасдиқ✓]   |
| Аз[..]До[..] Таъминкунанда▾ Ст.▾ |   |  Таъминкунанда [Фармотрейд ▾] Сана[22.06] |
|-----------------------------------|   |  Рақам [RC-00042]                         |
| № Сана  Таъминк.  Статус  Ҷамъ    |   |-------------------------------------------|
| 42 22.06 Фармо.. Draft   1 200   |   | Дору          Миқ Серия Мӯҳлат Хар. Фур. |
| 41 21.06 Медлайн Posted  3 400   |   | [+ илова сатр / скан штрих-код]           |
| …                                |   | Аспирин 500   50  A12  12.2026 8.0  12.0 |
|                                  |   | Парацетамол   30  B07  06.2027 5.0   8.0 |
|                                  |   | ← inline-editable cells, Tab moves →     |
|                                  |   |-------------------------------------------|
|                                  |   |               Сатрҳо:2  Ҷамъи харид:790  |
| саҳ.1/8                          |   | [Нигоҳ доштан (Draft)]  [Тасдиқ (Provesti)]|
+-----------------------------------+   +-------------------------------------------+
```

Нав/таҳрир → **саҳифаи пурра** (`/receipts/:id`). Header: supplier (`EntityPicker` →
`/suppliers`), сана (`DatePickerField`), рақам. Сатрҳо: inline-editable `AppDataTable` —
илова бо scan/picker; сутун Миқдор/**Серия**/**Мӯҳлат**/Нархи харид/Нархи фурӯш
(майдонҳои `ReceiptLine`). `Tab`/`Enter` пеш, `Ctrl+Enter` сатри нав. **Тасдиқ** →
`/receipts/{id}/post` (Batch+Stock дар сервер). Posted → read-only + "Бекор". Статус →
`StatusChip` (Draft=info, Posted=ok, Cancelled=muted).

### C.5 Доруҳо + маълумотномаҳои дигар (ҷадвал + side-panel, dropdown НА ID)

Ғалабаи асосӣ: **ҳеҷ ҷо typed ID нест.** Манбаъ: `/products`, `/drug-groups`,
`/manufacturers`, `/suppliers`, `/units`.

```
+--------------+-------------------------------------------------------------------+
| Доруҳо       | 💊 Доруҳо        🔍[..] Гурӯҳ▾ Истеҳс.▾ ☐Танҳо фаъол  [+ Дору]    |
| Гурӯҳҳо      |--------------------------------------------------+----------------|
| Таъминк.     | Ном            Штрих   Гурӯҳ      Воҳид ℞ Фаъол   | ТАҲРИРИ ДОРУ   |
| Истеҳсол.    | Аспирин 500мг  4870..  Анальгет.  дона  –  ✓      | Ном*[Аспирин ]|
| Воҳидҳо      | Амоксициллин   4871..  Антибиот.  дона  ℞  ✓ ◀sel | Штрих[4871..] |
|              | …                                                | Гурӯҳ [Антиб.▾]|
|              |                                                  | Истеҳс[Bayer▾] |
|              |                                                  | Воҳид [дона ▾] |
|              |                                                  | ☐ Ретсептӣ     |
|              |                                                  | Мин. бақия[10] |
|              |                                                  | ☑ Фаъол        |
|              |                                                  | [Бекор][Захира]|
+--------------+-------------------------------------------------------------------+
```

Як шакл барои 5 entity: ҷадвали searchable/sortable + редактори `SidePanel` рост
("+"=нав, row=таҳрир). **`EntityPicker` dropdown** ивази `drugGroupId`/`manufacturerId`/
`unitId` — typeahead ном нишон, GUID нигоҳ; ҳар picker "➕ нав" дарунсохт. Майдонҳои
Product 1:1 ба model. Soft-delete = "Ғайрифаъол".

### C.6 Ҳисоботҳо

Rail-и навъи ҳисобот → config + ҷадвал/chart + date-range + export. Манбаъ:
`/reports/sales|stock-value|profit|expiring|z-report`. Sales `groupBy` = day/product/seller
(segmented). Z-report per shift (`ZReport.byMethod`, `expectedCash`). Export тавассути
`printing`/`pdf` + `file_selector` (Save as).

### C.7 Танзимот

Sub-nav: Корбарон (`/users`, Admin), Нарх/наценка, Огоҳӣ (рӯзҳои мӯҳлат), Принтер,
**Server/Сервер** (scheme/host/port + Test connection — нигаред TZ_04 §base-url),
Sync (pending offline, last `/sync/catalog`, "Sync now"), Дар бораи. Забон (TJ/RU) + тема.

---

## D) INTERACTION & KEYBOARD MAP

**Global (app-level `Shortcuts`/`Actions` ё `PlatformMenuBar`, Cmd/Ctrl per platform):**

| Key | Амал |
|---|---|
| `Ctrl/Cmd+1..6` | Дашборд / Касса / Анбор / Приход / Ҳисобот / Танзимот |
| `Ctrl/Cmd+K` | Command palette |
| `Ctrl/Cmd+N` | "Нав" контекстӣ (приходи нав / доруи нав) |
| `Ctrl/Cmd+P` | Чоп/preview чек ё ҳисобот |
| `Ctrl/Cmd+E` | Export ҷадвали ҷорӣ |
| `Ctrl/Cmd+,` | Танзимот (macOS) |
| `Ctrl/Cmd+Q` | Баромад (macOS menu) |
| `Esc` | Пӯшидани panel/dialog |
| `Tab` / `Shift+Tab` | Гузаштан дар форма ва ҳуҷайраҳои editable |
| `Enter` | Амали асосӣ |

**POS-local (scoped, бо global намеҷанганд):** `F2` Ҷустуҷӯ, `F4` Тахфиф, `Del` Ҳазф,
`F9` Пардохт, `F7` Бозгашт, `F10` Бастани смена, `Esc` бекор.

**Master-detail:** Анбор, Доруҳо, ҳама маълумотнома → рӯйхат + `SidePanel` 380px;
интихоб навигатсия намекунад → контекст нигоҳ дошта мешавад.
**Toasts:** bottom-right stacked, auto-dismiss 4s. **Empty:** `EmptyState` + амали асосӣ.
**Loading:** shimmer rows; `LoadingOverlay` танҳо барои submit (pay/post); POS thin
`LinearProgressIndicator`. **Error:** banner inline + toast; insufficient-stock/conflict
бо номи дору.

---

## E) ПЛАТФОРМА / PACKAGING (Windows + macOS)

1. **Партофтани мобилӣ/web/linux:** `git rm -r android ios web linux`; `flutter clean`;
   `flutter pub get`. Ба `pubspec.yaml` `flutter:` → `platforms: { windows:, macos: }`.
   `analysis_options.yaml`: exclude `*.g.dart`/`*.freezed.dart`/`build/`.
2. **Window:** `window_manager: ^0.4.3`; `main.dart` → size 1440×900, minimumSize 1100×700,
   center, title `'Дорухона — Каса/Анбор'` (танҳо `Platform.isWindows||isMacOS`). Андоза/
   мавқеъ персист тавассути `shared_preferences` + `WindowListener`.
3. **Shell:** `app_shell.dart` → fixed extended-rail desktop shell (нест кардани narrow/
   bottom-nav path).
4. **Branding:** `windows/runner/main.cpp` (`window.Create(L"Дорухона"…)`) + `Runner.rc`
   (CompanyName/ProductName); macOS `AppInfo.xcconfig` `PRODUCT_NAME` + bundle id
   `com.example.*` → `tj.donishsoft.dorukhona`. Icon: `flutter_launcher_icons` аз 1 PNG.
5. **Single instance:** `windows_single_instance` (Windows; macOS пешфарз single).
6. **Native menu:** `PlatformMenuBar` (macOS top menu + accelerators).
7. **Export dialogs:** `file_selector` `getSaveLocation`.
8. **Base URL configurable** (ивази hardcoded `:5000`): `ServerConfig{scheme,host,port}`,
   resolution `--dart-define → server.json → shared_prefs → default http/localhost/5000`;
   `dioClientProvider` ба `serverConfigProvider` вобаста (rebuild ҳангоми тағйир); Settings
   "Сервер" section + Test connection. macOS http LAN → ATS exception дар `Info.plist`.
9. **Build:** Windows `flutter build windows --release` (ниёз: VS "Desktop development with
   C++"; дар dev machine насб нест → CI `windows-latest` ё насб). Packaging: Inno Setup
   (тавсия барои 1 дорухона) ё MSIX. macOS: `flutter build macos` → `.dmg` (ниёз: Mac +
   Xcode; Developer ID sign + notarize). CI: `windows-latest` + `macos-latest`, `flutter
   analyze` gate.

---

## F) ROADMAP — фазаҳо (тартиб)

> **P1–P3** мушкилоти "лаптоп" -ро мустақиман ҳал мекунанд ва ба backend-и нав вобаста
> нестанд. **P6+** ба endpoint-ҳои `/sync` вобастаанд (TZ_04).

| Фаза | Кор | Definition of Done |
|---|---|---|
| **P0. Platform foundation** | Партофтани android/ios/web/linux; `window_manager` + `main.dart` (size/min/title/center); persist bounds; branding+icon; single-instance; CI Win+mac. | App дар равзанаи минималӣ 1100×720 кушода мешавад, унвон дуруст, build pipeline. |
| **P1. Shell + theme** | Fixed sidebar + top bar (нест кардани breakpoint/bottom-nav); page-header; `StatusColors` extension; density theme + scoped POS theme; `AppScaffold`/`AppDataTable`/`StatusChip`/`Toast`/`EmptyState`. | Навигатсияи доимӣ, ҷадвалҳои desktop-density, огоҳиҳои семантикӣ. |
| **P2. EntityPicker (нест кардани typed ID)** | `EntityPicker` + repository-ҳои reference (drug-groups/manufacturers/suppliers/units); ивази typed ID дар Product/Receipt/POS-shift. | Ягон ҷо GUID дастӣ навишта намешавад. |
| **P3. Dashboard + global search** | Дашборд (KPI + expiring/low + quick actions + 7-day chart); `CommandPalette` (Ctrl+K); global shortcuts Ctrl+1..6. | Саҳифаи асосӣ бо огоҳиҳои барҷаста; ҷустуҷӯ/навигатсияи global. |
| **P4. Screen reworks** | POS two-pane register (qty-typing, F-keys, scan refocus); Stock master-detail; Receipt full-page editor (inline grid, retire dialog); Products/reference side-panel editors. | Ҳар экран desktop-grade, keyboard-driven. |
| **P5. Reports + Settings + roles** | Reports (sales/profit/stock-value/expiring/z) + export PDF/CSV; Settings (users/markup/alert-days/printer/server); role-based menu hiding. | Reports воқеӣ, Settings пурра, меню аз рӯи нақш. |
| **P6. Offline read (backend-gated)** | Drift schema + PULL `/sync/catalog`+`/sync/stock`; offline-first read repos; connectivity indicator; DioClient offline-session fix. | Scan/search/browse/cart офлайн кор мекунанд (нигаред TZ_04). |
| **P7. Offline write (backend-gated)** | Local FEFO + local stock decrement; outbox + sync engine (FIFO-per-shift, ClientId idempotent); offline shift + Z-report; offline ESC/POS print; reconciliation + conflict screen; pending-sync badge/panel. | Касса бе интернет мефурӯшад → баъди васл sync. |
| **P8. Полиш** | Тестҳоро ба shell/theme/picker нав мутобиқ кардан; freezed-decision; build .exe/.dmg signed. | Тест сабз, build-и Windows+macOS-и signed. |

**Файлҳои асосӣ:** иваз — `lib/app/app_shell.dart`, `lib/app/theme.dart`, `lib/app/router.dart`,
`lib/main.dart`, `lib/core/config/api_config.dart`, `lib/core/api/dio_client.dart`,
`lib/features/settings/presentation/settings_screen.dart`; илова — `lib/shared/*`,
`lib/features/dashboard/`; rework — `pos_screen.dart`, `stock_screen.dart`,
`receipt_edit_screen.dart`, `product_form_screen.dart`; native — `windows/runner/main.cpp`,
`Runner.rc`, `macos/.../AppInfo.xcconfig`, `Info.plist`. Model-ҳо тағйир намехоҳанд.
