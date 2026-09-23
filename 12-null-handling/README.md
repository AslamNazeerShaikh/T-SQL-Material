# 12 — NULL Handling (IS NULL, ISNULL vs COALESCE)

**Goal:** Treat blanks right — three-state logic, `= NULL` trap, `NOT IN` + NULL wipeout, ISNULL vs COALESCE.

## Definition (say this in the interview)

**What it is:** NULL means "no value set" — not zero, not blank text. SQL tests it
with `IS NULL` / `IS NOT NULL` (never `= NULL`), and fills it with `ISNULL(x, d)`
(T-SQL, two inputs) or `COALESCE(a, b, ...)` (ANSI, first non-blank wins).

**Why it was introduced:** Real data has gaps — unknown phone, missing bonus.
The model needed a mark for "not known" apart from false numbers like 0, plus
safe fill-ins so reports don't die on gaps.

**What problem it resolves:** Fake math. `NULL + 100` is NULL, `= NULL` matches
nothing, and one NULL in a `NOT IN` list wipes the full answer. Right tests and
fill-ins keep gaps from silently wrecking totals and filters.

**Interview-ready answer:** *"NULL means no value — not zero, not blank. I test
it with IS NULL, never equals NULL, as that test never comes true. For fill-ins
I use COALESCE for many inputs, ISNULL for two in T-SQL. And I never trust NOT
IN when the list can hold a NULL — one blank kills all rows, so I use NOT
EXISTS there."*

## 1. Sample table

```sql
CREATE TABLE #Staff (Id INT, Name VARCHAR(20), Bonus INT NULL);
INSERT INTO #Staff VALUES (1, 'Asha', 100), (2, 'Dev', NULL), (3, 'Ravi', 200);
```

## 2. Examples

Input `#Staff` used by every example below:

| Id | Name | Bonus |
|---:|---|---:|
| 1 | Asha | 100 |
| 2 | Dev | NULL |
| 3 | Ravi | 200 |

Example 1 — `IS NULL`:

```sql
SELECT * FROM #Staff WHERE Bonus IS NULL;
```

Input: 3 rows above.

Output (1 row):

| Id | Name | Bonus |
|---:|---|---:|
| 2 | Dev | NULL |

Example 2 — `IS NOT NULL`:

```sql
SELECT * FROM #Staff WHERE Bonus IS NOT NULL;
```

Input: 3 rows above.

Output (2 rows):

| Id | Name | Bonus |
|---:|---|---:|
| 1 | Asha | 100 |
| 3 | Ravi | 200 |

Example 3 — trap `= NULL`:

```sql
SELECT * FROM #Staff WHERE Bonus = NULL;
```

Input: 3 rows above.

Output: 0 rows (UNKNOWN never true).

| Id | Name | Bonus |
|---|---|---|
| *(no rows)* | | |

Example 4 — `COALESCE` / `ISNULL`:

```sql
SELECT
    Name,
    COALESCE(Bonus, 0) AS SafeBonus
FROM #Staff;
SELECT
    Name,
    ISNULL(Bonus, 0) AS SafeBonus
FROM #Staff;
```

Input: 3 rows above.

Output (3 rows, both queries):

| Name | SafeBonus |
|---|---:|
| Asha | 100 |
| Dev | 0 |
| Ravi | 200 |

Example 5 — NULL poisons math:

```sql
SELECT
    NULL + 100 AS M,
    'Hi ' + NULL AS C;
```

Input: none (literals).

Output (1 row):

| M | C |
|---|---|
| NULL | NULL |

Example 6 — `NOT IN` trap vs safe `NOT EXISTS`:

```sql
SELECT * FROM #Staff WHERE Id NOT IN (1, NULL);
```

Input: 3 rows above, list `(1, NULL)`.

Output: 0 rows.

| Id | Name | Bonus |
|---|---|---|
| *(no rows)* | | |

```sql
SELECT s.* FROM #Staff s
WHERE NOT EXISTS (SELECT 1 FROM (VALUES (1)) v (x) WHERE v.x = s.Id);
```

Input: 3 rows above.

Output (2 rows):

| Id | Name | Bonus |
|---:|---|---:|
| 2 | Dev | NULL |
| 3 | Ravi | 200 |

## 3. Query breakdown (NOT IN wipeout)

`Id NOT IN (1, NULL)` on Id=2: `2<>1` is true, `2<>NULL` is UNKNOWN.
`TRUE AND UNKNOWN` = UNKNOWN → row dropped. No row can ever pass when the list
holds NULL — hence empty answer. `NOT EXISTS` has no such hole.

## 4. Edge cases

- Three-state logic: TRUE / FALSE / UNKNOWN. `WHERE` keeps only TRUE.
- `NULL = NULL` is UNKNOWN, not true — dup checks need `IS NULL` pairs or keys.
- Aggregates skip NULLs (see `11`); `COUNT(*)` doesn't care — it counts rows.
- `ISNULL` takes the first input's type; `COALESCE` takes the top-rank type —
  mixed int/decimal fills can shift type on you.
- `COALESCE` checks inputs in order and stops at the first non-NULL.
- `ORDER BY` puts NULLs first on ASC in SQL Server — plan Top-N lists with it.

## 5. Interview scenario questions

1. "Bonus math shows NULL for Dev — fix in report?" → `COALESCE(Bonus,0)`.
2. "NOT IN query gives zero rows though matches live — why?" → NULL in the list. Switch to `NOT EXISTS`.
3. "ISNULL vs COALESCE?" → Two inputs T-SQL-only vs many-input ANSI; type rules differ.
4. "Is NULL same as 0 or ''?" → No. Unknown ≠ zero ≠ blank. Tests prove it.
5. "Top paid list puts blanks first — want last?" → `ORDER BY CASE WHEN Bonus IS NULL THEN 1 ELSE 0 END, Bonus DESC`.

## 6. Catch-all WHERE caution (asked pattern)

`WHERE Col = COALESCE(@p, Col)` looks clever (skip the filter when @p is blank)
but: NULL rows never match (`NULL = NULL` is unknown), and the wrap fences seeks
(`26`). Safe shape: `WHERE (@p IS NULL OR Col = @p)` — the optimizer can still
seek on Col.

## Cheat recap

```text
NULL = unknown | test IS NULL / IS NOT NULL | = NULL never true
COALESCE many-input ANSI | ISNULL two-input T-SQL
NOT IN + NULL = empty → use NOT EXISTS | NULL math = NULL
catch-all: WHERE (@p IS NULL OR Col = @p), never COALESCE-wrapped.
```
