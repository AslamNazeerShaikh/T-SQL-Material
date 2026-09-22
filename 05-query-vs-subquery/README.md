# 05 — Query vs Subquery

**Goal:** Define query/subquery and write scalar, multi-row, and correlated subqueries.

## Definition (say this in the interview)

**What it is:** A query is a SQL statement that asks the database to do something — most often a `SELECT` that retrieves data. A subquery is a query nested inside another query, whose result the outer query consumes: a scalar subquery returns one value (e.g. an average), a multi-row subquery returns a set used with `IN`, and a correlated subquery references the outer row so it re-evaluates per row.

**Why it was introduced:** Real questions are multi-step — "employees earning above the average" needs the average first, then the comparison. Subqueries let you compose such logic inside a single statement instead of running two queries and ferrying results through application code or temp tables.

**What problem it resolves:** Without subqueries you'd compute intermediate results client-side and interpolate them back, which is chatty, racy (data changes between steps), and hard to keep in one transaction. Subqueries keep multi-step logic atomic, server-side, and in a single round trip.

**Interview-ready answer:** *"A query is an ask put to the database — most days, a SELECT. A subquery is a query placed in one more query. A one-value type gives a single number, like average pay. A many-row type feeds IN. A linked type uses the outer row — like staff paid more than their own team average. They keep multi-step work in one safe server-side step, not two trips."*

> Next step: `15-exists-vs-in/` — EXISTS vs IN vs JOIN, NULL-safe anti-joins.

## 1. Sample tables

dbo.Employees:

| Id | Name | Salary | DepartmentId |
|---:|---|---:|---:|
| 1 | John | 80000 | 10 |
| 2 | Sara | 90000 | 10 |
| 3 | Mike | 45000 | 20 |

dbo.Departments:

| Id | Location |
|---:|---|
| 10 | Pune |
| 20 | Mumbai |

## 2. Definitions

Query — a SQL statement against the DB. In interviews, usually means `SELECT`:

```sql
SELECT * FROM dbo.Employees;
```

Subquery — a query nested inside another query (in `WHERE`, `SELECT`, `FROM`, `HAVING`).

```sql
SELECT *
FROM dbo.Employees
WHERE Salary > (SELECT AVG(Salary) FROM dbo.Employees);
```

Inner query = subquery. Outer query consumes its result.

## 3. Three types + examples

Input used by every example below:

`dbo.Employees`:

| Id | Name | Salary | DepartmentId |
|---:|---|---:|---:|
| 1 | John | 80000 | 10 |
| 2 | Sara | 90000 | 10 |
| 3 | Mike | 45000 | 20 |

`dbo.Departments`:

| Id | Location |
|---:|---|
| 10 | Pune |
| 20 | Mumbai |

Company `AVG(Salary)` = 71666.666666. Dept 10 avg = 85000.0. Dept 20 avg = 45000.0.

Scalar — one value (above company average):

```sql
SELECT *
FROM dbo.Employees
WHERE Salary > (SELECT AVG(Salary) FROM dbo.Employees);
```

Input: `dbo.Employees` above.

Output (2 rows):

| Id | Name | Salary | DepartmentId |
|---:|---|---:|---:|
| 1 | John | 80000 | 10 |
| 2 | Sara | 90000 | 10 |

Multi-row — many rows, use `IN` (employees in Pune):

```sql
SELECT *
FROM dbo.Employees
WHERE DepartmentId IN (
    SELECT Id FROM dbo.Departments WHERE Location = 'Pune'
);
```

Input: `dbo.Employees` + `dbo.Departments` above.

Output (2 rows):

| Id | Name | Salary | DepartmentId |
|---:|---|---:|---:|
| 1 | John | 80000 | 10 |
| 2 | Sara | 90000 | 10 |

Correlated — inner references outer, re-evaluates per row (above own-dept average):

```sql
SELECT e1.*
FROM dbo.Employees e1
WHERE Salary > (
    SELECT AVG(e2.Salary)
    FROM dbo.Employees e2
    WHERE e2.DepartmentId = e1.DepartmentId
);
-- "employees earning above their own department average"
```

Input: `dbo.Employees` above.

Output (1 row):

| Id | Name | Salary | DepartmentId |
|---:|---|---:|---:|
| 2 | Sara | 90000 | 10 |

## 4. Query breakdown (correlated example)

1. Outer scans `e1` row by row (John, Sara, Mike).
2. For John's row (`Dept 10`), inner computes `AVG` over Dept 10 only.
3. Compare John's salary to that average; keep/discard.
4. Repeat per row → correlated = row-dependent, often slower; EXISTS/JOIN may beat it (Level 2 topic).

## 5. Edge cases

- Scalar subquery returning 2+ rows → error ("returned more than one value"). Enforce single-row (aggregate / `TOP 1`) or switch to `IN`.
- `IN (SELECT ...)` with NULLs in the list → `NOT IN` turns UNKNOWN and filters everything. Prefer `NOT EXISTS` for anti-joins.
- Uncorrelated runs once; correlated runs per outer row — watch plans on large tables.
- Alias scoping: inner can see outer tables; outer cannot see inner aliases.
- Subquery in SELECT list must be scalar per row — accidental multi-row breaks the query.

## 6. Interview scenario questions

1. "Above-average earners?" → Scalar subquery with `AVG`.
2. "Employees in Pune?" → `IN` multi-row subquery on Departments.
3. "Above their *own department* average?" → Correlated subquery on `e2.DepartmentId = e1.DepartmentId`.
4. "Subquery vs CTE?" → Subquery is inline/nested; CTE is a named expression before the statement — better for readability, multi-step logic, recursion.
5. "Scalar subquery errors with multiple rows — fix?" → Add aggregation/`TOP 1` with `ORDER BY`, or rewrite as `IN`/`EXISTS`/JOIN.

## Cheat recap

```text
Query → statement (usually SELECT)
Subquery → nested query: scalar (1 value) | IN (many) | correlated (refs outer)
```
