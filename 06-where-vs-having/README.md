# 06 — WHERE vs HAVING

**Goal:** Never mix them up: WHERE filters rows, HAVING filters groups.

## Definition (say this in the interview)

**What it is:** `WHERE` filters individual rows *before* grouping and aggregation happen; `HAVING` filters the *groups* produced by `GROUP BY` after aggregates like `AVG` or `COUNT` are computed. They operate at two different stages of SQL's logical processing order: `FROM → WHERE → GROUP BY → HAVING → SELECT`.

**Why it was introduced:** Aggregate queries need filtering at two levels and one clause cannot serve both. You must remove irrelevant rows before averaging (otherwise HR salaries pollute the IT average), and you must also drop whole groups after averaging (departments whose average is too low). SQL separates the two so each filter runs at the only stage where its inputs exist.

**What problem it resolves:** Without the split you'd either average the wrong rows or be unable to express "departments averaging over 50K" at all. Mixing them up gives wrong results silently — filtering groups in WHERE is impossible (aggregates don't exist yet), and filtering rows in HAVING is wasteful (you aggregate rows you never wanted).

**Interview-ready answer:** *"WHERE keeps rows first, before groups are made. HAVING keeps groups next, after totals are made. So WHERE pay > 50000 drops low-pay rows first. Then HAVING average pay > 50000 drops weak teams. The steps are FROM, WHERE, GROUP BY, HAVING, SELECT. That is why a total like AVG can not sit in WHERE."*

## 1. Sample table

Employees:

| Employee | Department | Salary |
|---|---|---:|
| A | IT | 80000 |
| B | IT | 90000 |
| C | HR | 40000 |
| D | HR | 45000 |

```sql
CREATE TABLE #Emp (Employee CHAR(1), Department VARCHAR(10), Salary INT);
INSERT INTO #Emp VALUES ('A','IT',80000),('B','IT',90000),('C','HR',40000),('D','HR',45000);
```

## 2. Examples

WHERE — before grouping:

```sql
SELECT DepartmentId, AVG(Salary)
FROM Employees
WHERE Salary > 50000
GROUP BY DepartmentId;
-- HR rows removed BEFORE averages are computed
```

HAVING — after aggregation:

```sql
SELECT DepartmentId, AVG(Salary) AS AverageSalary
FROM Employees
GROUP BY DepartmentId
HAVING AVG(Salary) > 50000;
-- groups with avg <= 50K removed AFTER computing
```

Both together:

```sql
SELECT DepartmentId, AVG(Salary) AS AvgSalary
FROM Employees
WHERE Salary > 50000
GROUP BY DepartmentId
HAVING AVG(Salary) > 75000;
```

HAVING without GROUP BY (whole result = one group):

```sql
SELECT COUNT(*) AS EmployeeCount
FROM Employees
HAVING COUNT(*) > 100;
-- zero rows if count <= 100 (not a row with 0!)
```

## 3. Query breakdown

Logical order (not written order):

```text
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

1. `WHERE Salary > 50000` — drops individual HR rows first.
2. `GROUP BY Department` — forms IT/HR groups from survivors.
3. `AVG()` — computed per group.
4. `HAVING AVG() > 75000` — drops groups failing the bar.

So with the sample data: `WHERE > 50K` kills both HR rows → only IT group survives → `AVG(IT) = 85K` passes `HAVING > 75K`.

## 4. Edge cases

- Can't use `WHERE` on aggregates: `WHERE AVG(Salary) > 5` → error. That's HAVING's job.
- Can't use `HAVING` on non-grouped row columns (without aggregate/GROUP BY key) — engine rejects or misleads; filter rows in WHERE.
- Alias in HAVING: SQL Server allows `HAVING AVG(Salary) > ...` but referencing `SELECT` alias in HAVING is restricted — repeat the expression to be safe.
- HAVING without GROUP BY returning no rows confuses beginners: condition false → empty set, not `0`.
- WHERE is sargable-friendly (index seeks); HAVING runs post-aggregate — push filters to WHERE whenever they're row-level.

## 5. Interview scenario questions

1. "Avg salary per dept, only depts averaging > 50K?" → `GROUP BY` + `HAVING AVG > 50000`.
2. "Exclude salaries ≤ 50K *before* averaging?" → `WHERE Salary > 50000` + `GROUP BY`.
3. "Both at once?" → WHERE (rows) then HAVING (groups). Explain order.
4. "Depts with more than 5 high earners?" → `WHERE Salary > X GROUP BY Dept HAVING COUNT(*) > 5`.
5. "HAVING without GROUP BY — valid?" → Yes; whole result is one implicit group.

## Cheat recap

```text
WHERE → filters rows (before GROUP BY)
HAVING → filters groups (after aggregation)
Order: FROM → WHERE → GROUP BY → HAVING → SELECT
```
