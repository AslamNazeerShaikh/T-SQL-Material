# 27 — Data Types: Numbers, Dates, Specials (IDENTITY, SEQUENCE, XML, Bits)

**Goal:** Size ints right, stop float-money rot, stamp dates sharp, and make keys with IDENTITY vs SEQUENCE.

## Definition (say this in the interview)

**What it is:** The non-text half of types. Exact ints (BIGINT→TINYINT) for
counts, DECIMAL for money-math, FLOAT for science-guess (never money),
BIT flags, full date-time family, GUIDs, auto-stamp ROWVERSION, XML with teeth,
and key-makers IDENTITY (per-table) vs SEQUENCE (shared object).

**Why it was introduced:** Text types (`02`) can't count, date, or key safely.
Each job needs its shape — 1-byte flags, 100ns stamps, zone-aware times,
gap-free-ish keys — or math rots and clocks lie.

**What problem it resolves:** Wrong-shape storage (FLOAT money drift, DATETIME
3ms blur, VARCHAR dates that won't sort) and hand-made keys that clash. Right
type = right math, right sort, right size.

**Interview-ready answer:** *"Counts go exact ints — TINYINT to BIGINT by max
size. Money math goes DECIMAL, never FLOAT, as floats guess. Dates go
DATETIME2 sharp or UTC stamps; GETDATE is old DATETIME local, SYSDATETIME is
sharp. GUIDs for spread keys, ROWVERSION stamps for clash checks. Keys come
from IDENTITY per table or SEQUENCE shared town — sequences cache and cycle by
law."*

## 1. Numbers

| Type (name) | Size (bytes) | Span (range) | Use for (job) |
|---|---|---|---|
| BIGINT / INT / SMALLINT / TINYINT | 8 / 4 / 2 / 1 | ±9e18 / ±2.1e9 / ±32K / 0–255 | counts, keys — smallest that fits |
| DECIMAL(p,s) / NUMERIC | 5–17 by size | exact fixed-point | money math (never FLOAT) |
| FLOAT / REAL (=FLOAT(24)) | 8 / 4 | approx science | stats, geo — guesses allowed |
| MONEY / SMALLMONEY | 8 / 4 | 4-decimal fixed | legacy — DECIMAL preferred (clean math) |
| BIT | ~1/8th | 0 / 1 / NULL | flags (packs 8 per byte) |

## 2. Dates and times

| Type (name) | Size (bytes) | Sharpness (tick) | Use for (job) |
|---|---|---|---|
| DATE / TIME | 3 / 3–5 | day / 100ns | pure dates, day-times |
| DATETIME (old) | 8 | 3.33ms blur | legacy — GETDATE stamps it |
| SMALLDATETIME | 4 | minute | rough stamps, tight store |
| DATETIME2 (new pick) | 6–8 | 100ns | SYSDATETIME stamps it — default pick |
| DATETIMEOFFSET | 10 | 100ns + zone | zone-aware times |

GETDATE() = old local DATETIME. SYSDATETIME() = sharp DATETIME2. SYSUTCDATETIME()
= UTC sharp (apps across zones). TIME holds day-time only, not DATETIME-lite.

## 3. Specials + key-makers

- **UNIQUEIDENTIFIER** (16B GUID): spread keys via NEWID (random) / NEWSEQUENTIALID
  (ordered, index-kind — DEFAULT only).
- **ROWVERSION** (TIMESTAMP alias, binary(8)): auto-stamps each update — clash-check
  reads (`.NET optimistic concurrency`), never a clock.
- **XML**: checked well-formed + XQuery teeth (`.value/.query/.exist/.nodes`);
  FOR XML PATH('') glued strings pre-2017; XML indexes (primary + secondary) speed
  node hunts; Indeed-asked, rarely built.
- **Deprecated**: TEXT/NTEXT/IMAGE → VARCHAR(MAX)/NVARCHAR(MAX)/VARBINARY(MAX).
  LEN() dies on TEXT (use DATALENGTH).
- **SPARSE**: NULL-heavy saver. **FILESTREAM**: blobs on disk, SQL face.
- **IDENTITY(seed, step)** (int-only): per-table auto-keys; gaps on rollback/delete/
  restart-cache — normal, never gap-free vows. `SET IDENTITY_INSERT t ON` (one table
  per sitting) hand-feeds keys. `IDENT_CURRENT('t')` any scope/sitting;
  `IDENT_INCR`/`IDENT_SEED` read the law; `SCOPE_IDENTITY()` beats `@@IDENTITY`
  past trigger skew (`20` detail).
- **SEQUENCE** (shared object): keys across tables; `CREATE SEQUENCE ... START WITH /
  INCREMENT BY / MIN|MAXVALUE / CYCLE / CACHE n`; `NEXT VALUE FOR dbo.Seq`; gaps on
  rollback/cache like IDENTITY; CYCLE restarts at bound; CACHE pre-grabs for speed.
- **Bitwise** `& | ^ ~` (+ `&= |= ^=`): flag packs — one INT holds 32 on/off laws
  (design dodge for flag tables).

## 4. Examples

```sql
-- Money exact vs float guess
SELECT CAST(0.1 + 0.2 AS DECIMAL(10,2)) AS Exact, CAST(0.1 + 0.2 AS FLOAT) AS Guess;
-- Stamps: old blur vs sharp vs UTC
SELECT GETDATE() AS OldLocal, SYSDATETIME() AS Sharp, SYSUTCDATETIME() AS Utc;
-- XML teeth + pre-2017 glue trick
DECLARE @X XML = '<r><i>Asha</i><i>Dev</i></r>';
SELECT @X.value('(/r/i)[1]', 'VARCHAR(20)') AS First, @X.exist('/r/i') AS Has;
SELECT (SELECT Name + ',' FROM (VALUES ('Asha'),('Dev')) v(Name) FOR XML PATH('')) AS Glue;
-- Bits: flag pack check (4 = 100b; 5&4=4 set, 2&4=0 clear)
SELECT 5 & 4 AS HasPaid, 2 & 4 AS HasShip, 5 | 2 AS Both, ~5 AS Flip;
```

## 5. Edge cases

- FLOAT money drift compounds — DECIMAL(p,s) sized past max cents.
- DATETIME rounds to .000/.003/.007 — equality on stamps misses; range it.
- VARCHAR dates sort wrong ('2' > '10') — DATE types or ISO text only.
- IDENTITY gaps are law (rollback/cache) — need gap-free? SEQUENCE NOCACHE still gaps on rollback; true serial needs locks.
- IDENTITY_INSERT one table per sitting — second ON flips error; mind OFF after.
- SEQUENCE shared = cross-table key pools; NEXT VALUE FOR per row in set INSERTs.
- NEWID in clustered key = page-split storm — NEWSEQUENTIALID or INT keys.
- ROWVERSION unreadable by eye — compare, never show.

## 6. Interview scenario questions

1. "Money math drifting cents — type?" → DECIMAL(19,4)-ish, never FLOAT/MONEY.
2. "Stamps blurry 3ms — fix?" → DATETIME2 + SYSDATETIME; UTC apps SYSUTCDATETIME.
3. "Keys across Order + Invoice pools?" → SEQUENCE shared; per-table IDENTITY else.
4. "Clash-check same row edited twice (.NET)?" → ROWVERSION compare pre-write.
5. "Pre-2017 string glue?" → FOR XML PATH('') trick; now STRING_AGG (`20`).
6. "32 flags, no flag table?" → Bitwise pack in INT, `&` tests.
7. "Last id past trigger?" → SCOPE_IDENTITY; IDENT_CURRENT peeks any scope.

## Cheat recap

```text
Ints by max size | DECIMAL money, FLOAT guesses, MONEY legacy | BIT flags pack
DATETIME2 + SYSDATETIME pick | UTC apps SYSUTCDATETIME | TIME day-time only
GUID spread | ROWVERSION clash-stamp | XML teeth + PATH glue | TEXT dead → MAX
IDENTITY per-table gaps-law + INSERT session | SEQUENCE shared CACHE/CYCLE
Bitwise & | ^ ~ flag packs
```
