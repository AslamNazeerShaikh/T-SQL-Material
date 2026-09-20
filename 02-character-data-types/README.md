# 02 — Character Data Types in SQL Server

**Goal:** Choose correctly between CHAR / VARCHAR / NCHAR / NVARCHAR (+ MAX) and explain storage + Unicode behavior.

## Definition (say this in the interview)

**What it is:** Character data types declare how text is physically stored — fixed vs variable length, and non-Unicode (1 byte/char, English/ASCII) vs Unicode (2 bytes/char, all languages). `CHAR/NCHAR` always reserve their full length; `VARCHAR/NVARCHAR` store only what you put in; `(MAX)` variants hold up to ~2 GB.

**Why it was introduced:** Early systems only needed English text, so 1-byte-per-char types were enough and cheap. As software went global, the same columns had to hold Hindi, Arabic, Chinese, emoji — so Unicode (`N`-prefixed) types were added. Fixed vs variable exists because padding every value wastes disk and memory, while variable storage needs length overhead.

**What problem it resolves:** Picking wrong costs you twice: `CHAR(100)` for names wastes storage on every row, and `VARCHAR` for multilingual names silently corrupts data into `????`. The type system lets you trade storage for correctness per column — `CHAR(6)` for fixed codes, `NVARCHAR` for people's names.

**Interview-ready answer:** *"CHAR holds fixed text. VARCHAR holds free-size text. Both are for English text only. NCHAR and NVARCHAR are the same two, but for all world scripts. MAX types hold very big text, near 2 GB. I use CHAR for fixed codes, like a 6-letter staff code. I use NVARCHAR for names, with N put before the text — else Hindi or local text turns into question marks."*

## 1. The six types

```text
CHAR           fixed-length,     non-Unicode
VARCHAR        variable-length,  non-Unicode
VARCHAR(MAX)   large variable,   non-Unicode (~2 GB)

NCHAR          fixed-length,     Unicode
NVARCHAR       variable-length,  Unicode
NVARCHAR(MAX)  large variable,   Unicode (~2 GB / ~1B chars)
```

## 2. Sample table

```sql
CREATE TABLE DemoStrings
(
    Code    CHAR(6),          -- 'EMP001' always 6 chars
    Name    VARCHAR(100),     -- varying English names
    UniName NVARCHAR(100)     -- multilingual names
);
```

| Code (CHAR(6)) | Name (VARCHAR) | UniName (NVARCHAR) |
|---|---|---|
| EMP001 | John | John |
| EMP002 | Sara | अस्लम |

## 3. Examples

```sql
CHAR(10)          -- 'ABC' stored padded to 10 chars
VARCHAR(100)      -- 'ABC' stored as 3 chars + overhead
VARCHAR(MAX)      -- JSON / XML / large payloads up to ~2 GB

NCHAR(10)         -- fixed Unicode
NVARCHAR(100)     -- variable Unicode (multilingual default)
NVARCHAR(MAX)     -- large Unicode text

DECLARE @Name NVARCHAR(100);
SET @Name = N'अस्लम';  -- N prefix = Unicode literal
SELECT @Name;
```

## 4. Query breakdown

`SET @Name = N'अस्लम';`

1. `N'...'` tells SQL Server the literal is Unicode (UTF-16). Without `N`, non-ASCII chars can corrupt to `???`.
2. Column/variable must be `NCHAR/NVARCHAR` to preserve it end-to-end.
3. Comparison `WHERE UniName = N'अस्लम'` also needs the `N` prefix.

`CHAR(6)` vs `VARCHAR(100)` for `EmployeeCode = 'EMP001'`:

1. Every code is exactly 6 chars → `CHAR(6)` avoids length variance, predictable.
2. Names vary → `VARCHAR`/`NVARCHAR` avoids padding waste.

## 5. CHAR vs VARCHAR vs NVARCHAR

| | CHAR | VARCHAR | NVARCHAR |
|---|---|---|---|
| Length | Fixed | Variable | Variable |
| Unicode | No | No | Yes |
| Storage/char | 1 byte | 1 byte + overhead | 2 bytes (mostly) + overhead |
| Best for | Fixed codes (country/state, EMP001) | ASCII/English varying text | Multilingual / names / UI text |

## 6. Edge cases

- Forgetting `N` prefix: `SET @x = 'अस्लम'` (no N) into NVARCHAR still corrupts — literal was already mangled.
- `VARCHAR` + emoji/CJK/Arabic/Devanagari = data loss. Use NVARCHAR.
- `CHAR(n)` comparisons pad with spaces — `'ABC' = 'ABC   '` can surprise in joins/filters.
- `(MAX)` types can't be index keys; overusing `NVARCHAR(MAX)` for short strings hurts indexing + memory grants.
- Size math: `VARCHAR(8000)` / `NVARCHAR(4000)` are the last non-MAX sizes; beyond needs MAX (+ LOB storage).
- Collation matters for comparisons/sorting but doesn't make VARCHAR Unicode.

## 7. Interview scenario questions

1. "EmployeeCode always 6 chars, EmployeeName varies — types?" → `CHAR(6)` + `VARCHAR`/`NVARCHAR`.
2. "Hindi/Marathi names stored as `????` — bug?" → Column is VARCHAR or literal missed `N` prefix. Fix: `NVARCHAR` + `N'...'`.
3. "Need to store 5 MB JSON per row?" → `VARCHAR(MAX)` (or NVARCHAR(MAX) if Unicode). ~2 GB limit.
4. "Why is NVARCHAR twice the size?" → UTF-16, ~2 bytes/char. Trade-off for Unicode safety.
5. "When is CHAR better than VARCHAR?" → Fixed-length codes: no length variance, avoids fragmentation subtleties, self-documenting.

## Cheat recap

```text
CHAR → fixed non-Unicode | VARCHAR → variable non-Unicode | MAX → ~2GB
N = Unicode. Multilingual → NVARCHAR + N'...' literal.
Fixed codes → CHAR. Varying text → VARCHAR/NVARCHAR.
```
