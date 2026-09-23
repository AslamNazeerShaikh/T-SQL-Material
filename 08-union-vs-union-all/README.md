# 08 — UNION vs UNION ALL

**Goal:** Combine result sets correctly and pick the faster option when dedupe isn't needed.

## Definition (say this in the interview)

**What it is:** `UNION` and `UNION ALL` stack the results of two queries vertically into one result set. Both require the same number of columns with compatible types. The difference: `UNION` removes duplicate rows, `UNION ALL` keeps them.

**Why it was introduced:** Related data often lives in separate but structurally similar places — employees vs contractors, current vs archived orders, regional tables. Reports need them as one list, and running two queries plus merging client-side is wasteful — so SQL got a set operator that concatenates result sets server-side.

**What problem it resolves:** Without it you'd union data in application memory or with temp tables. The operator choice then trades correctness for speed: `UNION` pays for a dedupe pass (sort/hash) so each row appears once, while `UNION ALL` skips that work and is the right pick whenever duplicates are impossible or acceptable.

**Interview-ready answer:** *"UNION and UNION ALL stack two same-shape lists into one. UNION drops repeats. UNION ALL keeps them. Drop of repeats needs more work — a sort step — so UNION ALL is fast. I use UNION ALL by default. I use UNION only when I need one clean list — like staff plus vendor names with no repeats."*

## 1. Sample tables

Employees: `John, Sara` — Contractors: `Sara, Mike`

```sql
CREATE TABLE #Emp (Name VARCHAR(20));
CREATE TABLE #Con (Name VARCHAR(20));
INSERT INTO #Emp VALUES ('John'), ('Sara');
INSERT INTO #Con VALUES ('Sara'), ('Mike');
```

## 2. Examples

Input used by every example below:

`#Emp`:

| Name |
|---|
| John |
| Sara |

`#Con`:

| Name |
|---|
| Sara |
| Mike |

UNION — dedupes:

```sql
SELECT Name FROM #Emp
UNION
SELECT Name FROM #Con;
```

Input: `#Emp` + `#Con` above.

Output (3 rows):

| Name |
|---|
| John |
| Sara |
| Mike |

UNION ALL — keeps dupes:

```sql
SELECT Name FROM #Emp
UNION ALL
SELECT Name FROM #Con;
```

Input: `#Emp` + `#Con` above.

Output (4 rows):

| Name |
|---|
| John |
| Sara |
| Sara |
| Mike |

Multi-column (column count must match) + source label, ordered:

Input: same tables plus literal `'Emp'` / `'Con'`.

```sql
SELECT
    Name,
    'Emp' AS Src
FROM #Emp
UNION ALL
SELECT
    Name,
    'Con'
FROM #Con
ORDER BY Name;
```

Output (4 rows, ordered by `Name`):

| Name | Src |
|---|---|
| John | Emp |
| Mike | Con |
| Sara | Emp |
| Sara | Con |

## 3. Query breakdown

1. Both branches execute; column names come from the **first** branch.
2. `UNION` adds Sort/Distinct (or hash aggregate) to remove duplicates → extra cost.
3. `UNION ALL` concatenates streams — no dedupe pass.
4. `ORDER BY` goes once at the end: `... UNION ALL ... ORDER BY Name;`

## 4. Edge cases

- Column count mismatch → error. Fix: add NULL/explicit columns to align.
- Type mismatch → implicit conversion or error (e.g., INT vs DATE fails; INT vs VARCHAR may convert unexpectedly — cast explicitly).
- `UNION` treats NULLs as equal for dedupe (two NULL rows collapse to one).
- `ORDER BY` inside a branch without `TOP` → error; wrap branch or move ORDER to the end.
- `UNION` vs `UNION ALL` row counts differ? That's your dupe detector — compare counts to find overlaps.
- Collation conflict between branches → resolve with explicit `COLLATE`.

## 5. Interview scenario questions

1. "Combine employees + contractors, no dupes?" → `UNION`.
2. "Same, perf matters and dupes ok?" → `UNION ALL` (skips dedupe).
3. "Branches return different column counts?" → Error; pad/align columns.
4. "Why is UNION slower?" → Must sort/hash to eliminate duplicates.
5. "Need source label?" → Add literal: `SELECT Name, 'Emp' AS Src FROM #Emp UNION ALL SELECT Name, 'Con' FROM #Con;`

## Cheat recap

```text
UNION → dedupes (extra cost) | UNION ALL → keeps dupes (faster)
Same column count + compatible types. ORDER BY once at end.
```
