# 08 — UNION vs UNION ALL

**Goal:** Combine result sets correctly and pick the faster option when dedupe isn't needed.

## 1. Sample tables

Employees: `John, Sara` — Contractors: `Sara, Mike`

```sql
CREATE TABLE #Emp (Name VARCHAR(20));
CREATE TABLE #Con (Name VARCHAR(20));
INSERT INTO #Emp VALUES ('John'),('Sara');
INSERT INTO #Con VALUES ('Sara'),('Mike');
```

## 2. Examples

UNION — dedupes:

```sql
SELECT Name FROM #Emp
UNION
SELECT Name FROM #Con;
-- John | Sara | Mike   (Sara once)
```

UNION ALL — keeps dupes:

```sql
SELECT Name FROM #Emp
UNION ALL
SELECT Name FROM #Con;
-- John | Sara | Sara | Mike
```

Multi-column (column count must match):

```sql
SELECT Id, Name FROM Employees
UNION ALL
SELECT Id, Name FROM Contractors;
```

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
