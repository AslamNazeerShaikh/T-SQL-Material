# System Functions by Category (MS-Learn Map + Popular Picks)

Companion to `README.md` (your shapes) and `functions-system-vs-user-usability.md`
(determinism + where-usable). Maps the MS-Learn function families to the popular
calls with runnable T-SQL 2019 examples. Already covered elsewhere: aggregates
(`11`), ranking/analytic (`16`), logical null-fillers (`12`).

> Already in `20`: LEN, SUBSTRING, CONCAT, TRY_CAST, SCOPE_IDENTITY, NEWID-bar.
> Below goes family by family with the popular picks + traps.

## Definition (say this in the interview)

**What it is:** Shipped calls grouped by job — string cutters, date shifters,
converters, math, JSON readers, metadata askers, security checkers, config and
state readers. Learn the popular of each, not all — checks reward the common.

**Interview-ready answer:** *"Shipped calls group by job. String cutters like
SUBSTRING and splitters like STRING-SPLIT. Date shifters like DATEADD and month
enders. TRY-converters that give NULL not blasts. JSON readers for API text.
Metadata and security askers for shape and rights. State readers like ROWCOUNT
for flow checks. I learn the popular of each with one live example apiece."*

## 1. String (most-asked family)

| Call (name) | Job (use) | Live example |
|---|---|---|
| LEN / DATALENGTH | letters / bytes | `LEN('Asha')` = 4 (trailing gaps cut); `DATALENGTH('Asha')` = 4 bytes |
| LEFT / RIGHT | head/tail cut | `LEFT('Asha',2)` = 'As' |
| SUBSTRING | mid cut (1-based!) | `SUBSTRING('Asha',2,2)` = 'sh' |
| CHARINDEX | find spot (0 = miss) | `CHARINDEX('@','a@x')` = 2 |
| PATINDEX | shape find (`%` wild) | `PATINDEX('%[0-9]%', 'ab3')` = 3 |
| REPLACE / TRANSLATE / STUFF | swap / multi-swap / splice | `STUFF('Asha',2,2,'XX')` = 'AXXa' |
| UPPER / LOWER / TRIM | case + gap clean (TRIM 2017+) | `TRIM('  x  ')` = 'x' |
| CONCAT / CONCAT_WS | null-safe glue (WS 2017+) | `CONCAT_WS(',','a',NULL,'b')` = 'a,b' |
| REVERSE / REPLICATE | flip / pad-make | `REPLICATE('0',3)` = '000' |
| STRING_SPLIT | csv → rows (2016+, NO order vow) | `SELECT value FROM STRING_SPLIT('a,b',',')` |
| STRING_AGG | rows → csv (2017+, needs compat 140+) | `STRING_AGG(Name,', ') WITHIN GROUP (ORDER BY Name)` |
| FORMAT | pretty dates/numbers (slow!) | `FORMAT(GETDATE(),'yyyy-MM-dd')` — hot paths use CONVERT styles |

```sql
SELECT LEN('Asha ') AS L,                    -- 4, tail gaps cut
       SUBSTRING('Asha',2,2) AS Mid,         -- sh (1-based spots)
       CHARINDEX('@','a@x.com') AS At,       -- 2 (0 = miss)
       STUFF('Asha',2,2,'XX') AS Splice,     -- AXXa
       CONCAT_WS(',', 'a', NULL, 'b') AS Glue,-- a,b (NULL skipped)
       REPLICATE('0', 3) AS Pad;             -- 000
SELECT value FROM STRING_SPLIT('a,b,c', ',');-- rows; order NOT vowed
```

## 2. Date and time (second most-asked)

| Call (name) | Job (use) | Live example |
|---|---|---|
| GETDATE / SYSDATETIME / SYSUTCDATETIME | now stamps (local / sharp / UTC) | UTC for apps across zones |
| DATEADD / DATEDIFF / DATEDIFF_BIG | shift / span count | `DATEADD(MONTH,1,'2026-01-31')` = 2026-02-28 |
| DATENAME / DATEPART / DAY / MONTH / YEAR | part read | `DATENAME(WEEKDAY, GETDATE())` |
| EOMONTH | month-end (+ shift) | `EOMONTH(GETDATE(), -1)` = last month end |
| DATEFROMPARTS / DATETIME2FROMPARTS | safe build (no format guess) | `DATEFROMPARTS(2026,2,28)` |
| CONVERT styles | text shape (101 US, 103 UK, 120 ODBC, 126 ISO) | `CONVERT(VARCHAR, GETDATE(), 120)` |
| SWITCHOFFSET / TODATETIMEOFFSET | zone shift / zone tag | reports across zones |
| ISDATE | 'is this a date?' guard | `ISDATE('2026-02-30')` = 0 |

```sql
SELECT SYSDATETIME() AS SharpNow, SYSUTCDATETIME() AS UtcNow,
       DATEADD(MONTH, 1, '2026-01-31') AS Shift,   -- 2026-02-28 (clips, no blast)
       DATEDIFF(DAY, '2026-01-01', '2026-02-01') AS Span,  -- 31
       EOMONTH(GETDATE()) AS MonthEnd,
       DATEFROMPARTS(2026, 2, 28) AS Built,        -- safe, no format guess
       CONVERT(VARCHAR(20), GETDATE(), 120) AS Odbc,-- yyyy-mm-dd hh:mi:ss
       ISDATE('2026-02-30') AS Nope;               -- 0
```

## 3. Conversion (TRY_ twins = interview gold)

| Call (name) | Job (use) | Live example |
|---|---|---|
| CAST | ANSI shape-shift | `CAST('12' AS INT)` |
| CONVERT | T-SQL shift + styles | `CONVERT(INT, '12')`, styles for dates |
| TRY_CAST / TRY_CONVERT | soft shift → NULL on rot | `TRY_CAST('12x' AS INT)` = NULL, no blast |
| TRY_PARSE (+ culture) | culture-aware soft parse | `TRY_PARSE('31/12/2026' AS DATE USING 'en-GB')` |
| PARSE | culture parse (blasts on rot) | imports prefer TRY_ |

```sql
SELECT CAST('12' AS INT) AS Hard,
       TRY_CAST('12x' AS INT) AS Soft,        -- NULL, batch lives
       TRY_CONVERT(INT, '12x') AS Soft2,      -- NULL
       TRY_PARSE('31/12/2026' AS DATE USING 'en-GB') AS UkDate;
```

## 4. Mathematical (popular numeric)

| Call (name) | Job (use) | Live example |
|---|---|---|
| ABS / SIGN | magnitude / -1·0·1 | `SIGN(-5)` = -1 |
| ROUND (3rd input!) | round / truncate | `ROUND(3.567, 2)` = 3.57; `ROUND(3.567, 2, 1)` = 3.56 (cut) |
| CEILING / FLOOR | up / down whole | `CEILING(3.1)` = 4 |
| POWER / SQUARE / SQRT | powers | `POWER(2, 10)` = 1024 |
| LOG / EXP / PI | logs, e^x, pi | science shapes |
| RAND | 0–1 float (non-det, barred in func bodies) | seed input repeats run |

```sql
SELECT ABS(-5) AS A, SIGN(-5) AS S, ROUND(3.567, 2) AS R,
       ROUND(3.567, 2, 1) AS Cut,   -- 3.56 (3rd input = cut, not round)
       CEILING(3.1) AS Up, FLOOR(3.9) AS Down, POWER(2,10) AS P;
```

## 5. Aggregate extras (beyond `11`: GROUPING)

```sql
-- GROUPING() marks rollup-made NULLs (1 = total row, 0 = real group)
SELECT Region, SUM(Amt) AS Total, GROUPING(Region) AS IsTotal
FROM (VALUES ('E',100),('W',200)) v(Region, Amt)
GROUP BY ROLLUP (Region);
-- GROUPING_ID() bitmask for multi-field rollups (which fields are totaled)
```

## 6. JSON (2016+, full-stack gold)

| Call (name) | Job (use) | Live example |
|---|---|---|
| ISJSON | shape check | `ISJSON('{"a":1}')` = 1 |
| JSON_VALUE | one scalar out (lax default) | `JSON_VALUE('{"a":1}', '$.a')` = '1' |
| JSON_QUERY | object/array out | `JSON_QUERY('{"a":{"b":2}}', '$.a')` = '{"b":2}' |
| JSON_MODIFY | returns CHANGED text (not in-place!) | `JSON_MODIFY('{"a":1}', '$.a', 2)` |
| OPENJSON | json → rows (+ WITH schema) | needs compat 130+ |

```sql
DECLARE @J NVARCHAR(MAX) = '{"name":"Asha","tags":["x","y"]}';
SELECT ISJSON(@J) AS Ok,
       JSON_VALUE(@J, '$.name') AS Nm,          -- Asha
       JSON_QUERY(@J, '$.tags') AS Tg,          -- ["x","y"]
       JSON_MODIFY(@J, '$.name', 'Dev') AS New; -- changed TEXT back
SELECT tag FROM OPENJSON(@J, '$.tags') WITH (tag VARCHAR(20) '$');
```

## 7. Metadata (shape askers)

| Call (name) | Job (use) | Live example |
|---|---|---|
| DB_NAME / DB_ID | current db | `DB_NAME()` |
| OBJECT_ID / OBJECT_NAME | id ⇄ name | `OBJECT_ID('dbo.Emp')` (NULL = missing — safe exists-check) |
| SCHEMA_NAME / SCHEMA_ID | schema of id | `SCHEMA_NAME(OBJECTPROPERTY(...))` — simpler: `SCHEMA_NAME()` = yours |
| COL_LENGTH / COL_NAME | field bytes / name by spot | `COL_LENGTH('dbo.Emp','Salary')` |
| TYPE_NAME | type name of id | `TYPE_NAME(56)` = 'int' |
| APP_NAME / HOST_NAME | who called (app / box) | audit trails |

```sql
SELECT DB_NAME() AS Db, OBJECT_ID('dbo.Emp') AS Eid,   -- NULL if missing
       TYPE_NAME(56) AS T, APP_NAME() AS App, HOST_NAME() AS Box;
```

## 8. Security (rights askers — pairs with `01` DCL)

| Call (name) | Job (use) | Live example |
|---|---|---|
| SUSER_SNAME / SYSTEM_USER | server login name | `SUSER_SNAME()` |
| USER_NAME / SESSION_USER | db user name | `USER_NAME()` |
| ORIGINAL_LOGIN | first login (past EXEC AS swaps) | audit who-really |
| IS_MEMBER | role check 1/0/NULL | `IS_MEMBER('db_owner')` |
| HAS_PERMS_BY_NAME | right check 1/0 | `HAS_PERMS_BY_NAME(DB_NAME(),'DATABASE','SELECT')` |

```sql
SELECT SUSER_SNAME() AS Login, USER_NAME() AS DbUser,
       ORIGINAL_LOGIN() AS FirstLogin, IS_MEMBER('db_owner') AS Owner;
```

## 9. Configuration + state + stats (server askers)

```sql
SELECT @@SERVERNAME AS Srv, @@VERSION AS Ver,        -- config: box + build
       @@SERVICENAME AS Svc, @@LANGUAGE AS Lang, @@DATEFIRST AS WeekStart;
SELECT @@ROWCOUNT AS Rows, @@TRANCOUNT AS Deals,     -- state: last-count, open deals
       @@CONNECTIONS AS Conns, @@CPU_BUSY AS Cpu;    -- stats: since boot
```

## 10. Cursor + rowset + skip-list (short)

- Cursor asks: `@@FETCH_STATUS` (0 ok / -1 past end / -2 row gone), `@@CURSOR_ROWS`
  count, `CURSOR_STATUS('global','c')` (1 open / 0 shut / -1 missing). Cursors stay
  last-resort (`19`).
- Rowset makers (`OPENROWSET`, `OPENDATASOURCE`, `OPENQUERY`) query outside boxes —
  need 'Ad Hoc Distributed Queries' switched on + tight rights; admin turf, not app code.
- Skip on 2019: bit-manipulation calls (2022+ only), graph calls (niche), legacy
  text/image calls (`TEXTPTR` — old TEXT type, dead road).
- String collation rule (MS note): text-in → text-out keeps input collation;
  built text uses db default (`02`).

## Cheat recap

```text
String: LEN LEFT SUBSTRING CHARINDEX PATINDEX REPLACE STUFF TRIM CONCAT_WS SPLIT AGG FORMAT-slow
Date: GETDATE/SYSUTCDATETIME DATEADD DATEDIFF EOMONTH DATEFROMPARTS CONVERT-styles ISDATE
Convert: CAST CONVERT TRY_CAST TRY_CONVERT TRY_PARSE | Math: ROUND-3rd-cuts CEIL FLOOR POWER
GROUPING marks rollup NULLs | JSON: ISJSON VALUE QUERY MODIFY OPENJSON
Meta: DB_NAME OBJECT_ID COL_LENGTH APP_NAME | Security: SUSER USER ORIGINAL IS_MEMBER HAS_PERMS
Config/state: @@SERVERNAME @@VERSION @@ROWCOUNT @@TRANCOUNT | cursor/rowset short above
```
