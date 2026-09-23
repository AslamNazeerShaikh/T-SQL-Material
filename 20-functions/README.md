# 20 — Functions (Scalar vs Inline TVF vs Multi-Statement TVF)

**Goal:** Pick the right function shape — and know why scalars and multi-step table funcs can tank plans.

## Definition (say this in the interview)

**What it is:** Saved value-makers with inputs and one back-value. Scalar gives
one value (tax on pay). Inline table gives a table from one SELECT (a view with
inputs). Multi-step table builds a table with many steps in a BEGIN-END pack.

**Why it was introduced:** Same math pasted in fifty queries rots. Funcs pack
it once —-called all town, same answer. Shapes fit needs: one value, one clear
SELECT, or staged table build.

**What problem it resolves:** Copy-paste math rot. But each shape costs apart:
inline folds into plans (fast), scalars ran row-by-row (slow pre-2019 — 2019
folds the worthy ones), multi-step hides stats (often slow). Right shape = same
truth at low cost.

**Interview-ready answer:** *"Three shapes. Scalar gives one value — ran row by
row before 2019, which now folds the worthy ones inline. Inline table is one
SELECT with inputs, like a view with inputs — fast, folds in plans. Multi-step
table builds with many steps but hides stats, so oft slow. I use inline for
table work, scalar for plain math, multi-step only when steps truly must stage."*

> Deep dive: `functions-system-vs-user-usability.md` — built-in library tour, determinism bars, where-usable matrix incl. CROSS APPLY.
> Category map: `system-functions-by-category.md` + `system-functions-examples.sql` — popular calls per MS-Learn family with live demos.

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT, Salary INT);
INSERT INTO #Emp VALUES (1, 90000), (2, 80000);
```

## 2. Examples (shapes — make in your test DB; #temp shown for shape)

Input `#Emp`:

| Id | Salary |
|---:|---:|
| 1 | 90000 |
| 2 | 80000 |

Extended demo `dbo.Emp20`:

| Id | Salary | DeptId |
|---:|---:|---:|
| 1 | 90000 | 10 |
| 2 | 80000 | 10 |
| 3 | 45000 | 20 |

Example 1 — scalar, single call:

```sql
CREATE FUNCTION dbo.fn_Tax(@Pay INT) RETURNS DECIMAL(18, 2) AS
BEGIN RETURN @Pay * 0.10; END;
SELECT dbo.fn_Tax(90000) AS Tax;
```

Input: `90000`.

Output (1 row):

| Tax |
|---:|
| 9000.00 |

Example 2 — scalar per row:

```sql
SELECT
    Id,
    Salary,
    dbo.fn_Tax(Salary) AS Tax
FROM dbo.Emp20;
```

Input: `dbo.Emp20` 3 rows above.

Output (3 rows):

| Id | Salary | Tax |
|---:|---:|---:|
| 1 | 90000 | 9000.00 |
| 2 | 80000 | 8000.00 |
| 3 | 45000 | 4500.00 |

Example 3 — inline TVF:

```sql
CREATE FUNCTION dbo.fn_Team(@D INT)
RETURNS TABLE AS RETURN (SELECT
    Id,
    Salary
FROM #Emp WHERE Id = @D);
SELECT * FROM dbo.fn_Team(1);
```

Input: `#Emp` 2 rows.

Output (1 row):

| Id | Salary |
|---:|---:|
| 1 | 90000 |

```sql
SELECT * FROM dbo.fn_Team20(10);
```

Input: `dbo.Emp20` 3 rows.

Output (2 rows):

| Id | Salary |
|---:|---:|
| 1 | 90000 |
| 2 | 80000 |

Example 4 — multi-step TVF:

```sql
CREATE FUNCTION dbo.fn_Bands()
RETURNS @Out TABLE (Band VARCHAR(10), Cnt INT) AS
BEGIN
    INSERT INTO @Out SELECT
        'High',
        COUNT(*)
    FROM #Emp WHERE Salary >= 100000;
    INSERT INTO @Out SELECT
        'Rest',
        COUNT(*)
    FROM #Emp WHERE Salary < 100000;
    RETURN;
END;
SELECT * FROM dbo.fn_Bands20 ();
```

Input: `dbo.Emp20` 3 rows.

Output (2 rows):

| Band | Cnt |
|---|---:|
| High | 0 |
| Rest | 3 |

Example 5 — `CROSS APPLY`:

```sql
SELECT
    e.Id,
    t.Salary AS TeamSal
FROM dbo.Emp20 e
CROSS APPLY dbo.fn_Team20(e.DeptId) t;
```

Input: 3 rows above.

Output (5 rows — verified on SQL Server 2025; row order undefined without
`ORDER BY`, this run returned source order):

| Id | TeamSal |
|---:|---:|
| 1 | 90000 |
| 2 | 90000 |
| 1 | 80000 |
| 2 | 80000 |
| 3 | 45000 |

Example 6 — `OUTER APPLY` (keeps all left rows):

```sql
SELECT
    e.Id,
    t.Salary AS TeamSal
FROM dbo.Emp20 e
OUTER APPLY dbo.fn_Team20(e.DeptId) t;
```

Input: 3 rows above (every `DeptId` matches, so same 5 rows as `CROSS APPLY`
here; a `DeptId` with zero members would add an `(Id, NULL)` row only under
`OUTER`).

Output (5 rows — verified on SQL Server 2025; row order undefined):

| Id | TeamSal |
|---:|---:|
| 1 | 90000 |
| 1 | 80000 |
| 2 | 90000 |
| 2 | 80000 |
| 3 | 45000 |

## 3. Query breakdown (inline win)

`SELECT * FROM dbo.fn_Team(1)` — engine pastes the one SELECT into your query
and plans full-table work as one (seeks kept). Scalar pre-2019 fenced each call
apart (row-by-row math). Multi-step walls its @Out table off from stats, so
joins past it guess blind.

## 4. Edge cases

- Scalar in big SELECTs pre-2019 = row-by-row tax — test plans, 2019 helps worthy ones.
- Multi-step TVF joins guess 1 row (no stats) — small builds fine, big builds pain.
- Inline TVF has no BEGIN-END pack — one SELECT only; need steps? That's multi-step shape.
- Funcs can't do all proc tricks (no deals, no side writes) — math and reads only.
- SCHEMABINDING locks base shape, helps speed + inlining — use on hot funcs.
- Nondeterministic calls (GETDATE) in funcs fence inlining — keep funcs clean.

## 5. Interview scenario questions

1. "Same tax math in fifty queries — pack it?" → Scalar func, one truth.
2. "Team list with input id, fast?" → Inline TVF — folds in plan like a view.
3. "Multi-step table build reused — shape?" → Multi-step TVF, watch stats-blind joins.
4. "Scalar in 1M-row SELECT crawls — why?" → Row-by-row fence (pre-2019); 2019 inlines worthy ones — check plan.
5. "Proc vs func?" → Proc: deals, writes, many steps (`19`). Func: values/tables in queries.

## Cheat recap

```text
Scalar one value (2019 inlines worthy) | Inline one-SELECT table, fast
Multi-step staged table, stats-blind | SCHEMABINDING hot funcs
Procs do work, funcs give values
```
