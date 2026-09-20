# 07 — SQL Joins

**Goal:** Return correct rows for every join type and find mismatches (anti-join).

## 1. Sample tables

Employees:

| Id | Name | DepartmentId |
|---:|---|---:|
| 1 | John | 10 |
| 2 | Sara | 20 |
| 3 | Mike | 30 |

Departments:

| Id | Department |
|---:|---|
| 10 | IT |
| 20 | HR |
| 40 | Finance |

```sql
CREATE TABLE #E (Id INT, Name VARCHAR(20), DepartmentId INT);
CREATE TABLE #D (Id INT, Department VARCHAR(20));
INSERT INTO #E VALUES (1,'John',10),(2,'Sara',20),(3,'Mike',30);
INSERT INTO #D VALUES (10,'IT'),(20,'HR'),(40,'Finance');
```

## 2. Examples

INNER — only matches:

```sql
SELECT e.Name, d.Department
FROM #E e INNER JOIN #D d ON e.DepartmentId = d.Id;
-- John IT | Sara HR   (Mike 30 unmatched, Finance 40 employeeless)
```

LEFT — all left + matches:

```sql
SELECT e.Name, d.Department
FROM #E e LEFT JOIN #D d ON e.DepartmentId = d.Id;
-- John IT | Sara HR | Mike NULL
```

Anti-join — departments with NO employees:

```sql
SELECT d.Department
FROM #D d LEFT JOIN #E e ON e.DepartmentId = d.Id
WHERE e.Id IS NULL;
-- Finance
```

RIGHT — all right + matches:

```sql
SELECT e.Name, d.Department
FROM #E e RIGHT JOIN #D d ON e.DepartmentId = d.Id;
-- John IT | Sara HR | NULL Finance
-- (Prefer LEFT JOIN with swapped order for readability.)
```

FULL OUTER — everything:

```sql
SELECT e.Name, d.Department
FROM #E e FULL OUTER JOIN #D d ON e.DepartmentId = d.Id;
-- John IT | Sara HR | Mike NULL | NULL Finance
```

CROSS — Cartesian, no ON:

```sql
SELECT * FROM #E CROSS JOIN #D;  -- 3 x 3 = 9 rows
```

SELF — manager hierarchy:

```sql
SELECT e.Name AS Employee, m.Name AS Manager
FROM Employees e LEFT JOIN Employees m ON e.ManagerId = m.Id;
```

## 3. Query breakdown (LEFT + anti-join)

```sql
FROM #D d LEFT JOIN #E e ON e.DepartmentId = d.Id WHERE e.Id IS NULL;
```

1. LEFT preserves every department row; non-matching columns from `#E` become NULL.
2. `ON` decides matching; `WHERE e.Id IS NULL` keeps only departments that matched nothing.
3. Classic mistake: putting `e.X = ...` in WHERE (instead of ON) converts outer join to inner — NULL rows get filtered out.

## 4. Edge cases

- `WHERE` on the nullable side kills outer-join semantics — move such predicates to `ON` or test `IS NULL` deliberately.
- Duplicate join keys fan out rows (1×N, N×M) — aggregates after joins double-count; pre-aggregate first.
- NULL never equals NULL in `ON col = col` — NULL keys never match; handle with `IS NOT DISTINCT FROM` logic or coalesce keys.
- `FULL OUTER JOIN` + `WHERE` needs care on both sides; often clearer as UNION of two anti-joins.
- CROSS JOIN explodes: 10K × 10K = 100M rows — confirm intent (e.g., tally/calendar generation).
- JOIN ≠ FK requirement: any logical predicate works, but PK/FK joins are the indexed, expected case.

## 5. Interview scenario questions

1. "All employees with dept name, keep employeeless... wait, keep dept-less employees?" → `LEFT JOIN`, Mike shows NULL.
2. "Departments with zero employees?" → `LEFT JOIN ... WHERE e.Id IS NULL`.
3. "RIGHT vs LEFT?" → Same power; LEFT with swapped tables reads better.
4. "Why did row count explode after joining?" → Duplicate keys / fanout; dedupe or pre-aggregate.
5. "Employee–manager in one table?" → SELF JOIN with two aliases.

## Cheat recap

```text
INNER → matching | LEFT → all left + match | RIGHT → all right + match
FULL → everything | CROSS → Cartesian (no ON) | SELF → same table, 2 aliases
Anti-join: LEFT JOIN ... WHERE right.key IS NULL
```
