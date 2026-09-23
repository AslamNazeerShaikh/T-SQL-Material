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

Example 1 — money exact vs float guess:

```sql
SELECT
    CAST(0.1 + 0.2 AS DECIMAL(10, 2)) AS Exact,
    CAST(0.1 + 0.2 AS FLOAT) AS Guess;
```

Input: literals `0.1`, `0.2`.

Output (1 row — verified on SQL Server 2025):

| Exact | Guess |
|---:|---|
| 0.30 | 0.29999999999999999 |

> SSMS grid shows `0.30`; `sqlcmd` renders it as `.30` (no leading zero).
> `Guess` is the binary float — never use it for money.

Example 2 — stamps:

```sql
SELECT
    GETDATE() AS OldLocal,
    SYSDATETIME() AS Sharp,
    SYSUTCDATETIME() AS Utc;
```

Input: system clock.

Output (1 row — all execution-time, non-deterministic):

| OldLocal | Sharp | Utc |
|---|---|---|
| <DATETIME local> | <DATETIME2> | <UTC> |

Example 3 — `IDENTITY(100,5)`:

```sql
INSERT INTO dbo.Key27 (Name) VALUES ('Asha'), ('Dev');
SELECT * FROM dbo.Key27;
```

Input: `('Asha'),('Dev')`.

Output (2 rows):

| Id | Name |
|---:|---|
| 100 | Asha |
| 105 | Dev |

```sql
DELETE FROM dbo.Key27 WHERE Id = 105;
INSERT INTO dbo.Key27 (Name) VALUES ('Ravi');
SELECT * FROM dbo.Key27;
```

Input: delete 105, add Ravi.

Output (2 rows):

| Id | Name |
|---:|---|
| 100 | Asha |
| 110 | Ravi |

```sql
SELECT
    IDENT_CURRENT('dbo.Key27') AS AnyScope,
    IDENT_INCR('dbo.Key27') AS Step,
    IDENT_SEED('dbo.Key27') AS Seed;
```

Output (1 row):

| AnyScope | Step | Seed |
|---:|---:|---:|
| 110 | 5 | 100 |

```sql
SET IDENTITY_INSERT dbo.Key27 ON;
INSERT INTO dbo.Key27 (Id, Name) VALUES (1, 'Hand');
SET IDENTITY_INSERT dbo.Key27 OFF;
SELECT * FROM dbo.Key27;
```

Output (3 rows):

| Id | Name |
|---:|---|
| 1 | Hand |
| 100 | Asha |
| 110 | Ravi |

Example 4 — `SEQUENCE`:

```sql
SELECT
    NEXT VALUE FOR dbo.Seq27 AS S1,
    NEXT VALUE FOR dbo.Seq27 AS S2;
```

Input: `dbo.Seq27 START 1000 STEP 10`.

Output (1 row — verified on SQL Server 2025):

| S1 | S2 |
|---:|---:|
| 1000 | 1000 |

> Two references in one `SELECT` share a single increment — both read `1000`.
> The *next* call returns `1010` (verified: a follow-up
> `SELECT NEXT VALUE FOR dbo.Seq27` gives `1010`). Separate statements (or
> `NEXT VALUE FOR ... OVER`) advance per call; same-statement twin references
> do not.

Example 5 — XML teeth:

```sql
DECLARE @X XML = '<r><i>Asha</i><i>Dev</i></r>';
SELECT
    @X.value('(/r/i)[1]', 'VARCHAR(20)') AS First,
    @X.exist('/r/i[text()="Dev"]') AS HasDev;
```

Input `@X`:

| @X |
|---|
| `<r><i>Asha</i><i>Dev</i></r>` |

Output (1 row):

| First | HasDev |
|---|---:|
| Asha | 1 |

```sql
SELECT Dev.query('.') FROM @X.nodes('/r/i') D (Dev);
```

Output (2 rows):

| (No column name) |
|---|
| `<i>Asha</i>` |
| `<i>Dev</i>` |

```sql
SELECT
    (SELECT Name + ',' FROM (VALUES ('Asha'), ('Dev')) v (Name) FOR XML PATH ('')) AS Glue;
```

Input:

| Name |
|---|
| Asha |
| Dev |

Output (1 row):

| Glue |
|---|
| Asha,Dev, |

Example 6 — bits:

```sql
SELECT
    5 & 4 AS HasPaid,
    2 & 4 AS HasShip,
    5 | 2 AS Both,
    5 ^ 1 AS Toggle,
    ~5 AS Flip;
```

Input: literals `5`, `4`, `2`.

Output (1 row):

| HasPaid | HasShip | Both | Toggle | Flip |
|---:|---:|---:|---:|---:|
| 4 | 0 | 7 | 4 | -6 |

## 5. Edge cases

- FLOAT money drift compounds — DECIMAL(p,s) sized past max cents.
- DATETIME rounds to .000/.003/.007 — equality on stamps misses; range it.
- VARCHAR dates sort wrong ('2' > '10') — DATE types or ISO text only.
- IDENTITY gaps are law (rollback/cache) — need gap-free? SEQUENCE NOCACHE still gaps on rollback; true serial needs locks.
- IDENTITY_INSERT one table per sitting — second ON flips error; mind OFF after.
- SEQUENCE shared = cross-table key pools; NEXT VALUE FOR per row in set INSERTs.
  Twin references in one SELECT share one increment (verified: S1=S2=1000,
  next call 1010) — don't assume one increment per reference.
- XML methods and filtered indexes need QUOTED_IDENTIFIER ON (Msg 1934).
  SSMS sets it ON; `sqlcmd` defaults OFF — `examples.sql` sets it explicitly,
  so the file stays F5-clean in both tools.
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
