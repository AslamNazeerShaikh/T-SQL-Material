# 09 — CTE (Common Table Expression)

**Goal:** Structure complex queries with named expressions and write a recursive hierarchy.

## Definition (say this in the interview)

**What it is:** A Common Table Expression is a named temporary result set, declared with `WITH`, that exists only for the single statement that follows it. It comes in two forms: non-recursive, which is essentially a named subquery that makes complex logic readable, and recursive, which references itself to walk hierarchies like org charts.

**Why it was introduced:** Deeply nested subqueries become unreadable — queries inside queries inside queries — and before CTEs there was no standard way to express recursion (employee → manager → CEO traversal) in plain SQL. The CTE gave queries named, composable building blocks plus an anchor-plus-recursive-member pattern for hierarchies.

**What problem it resolves:** It turns a 200-line nested monster into named steps (`HighPaid`, `Ranked`, `Tree`) that read top-to-bottom, and it makes hierarchical traversal possible without loops or temp tables. Note it is not a temp table: it lives for one statement and is generally inlined, not materialized.

**Interview-ready answer:** *"A CTE is a named temporary result defined with WITH for the single statement that follows. I use non-recursive CTEs to break complex queries into readable steps instead of deep nesting, and recursive CTEs — an anchor query plus a UNION ALL recursive member — to traverse hierarchies like an org chart. It doesn't create a physical temp table; it's a query expression the optimizer generally inlines."*

## 1. Sample tables

```sql
CREATE TABLE Employees (Id INT, Name VARCHAR(50), Salary INT, DepartmentId INT);
INSERT INTO Employees VALUES (1,'John',80000,10),(2,'Sara',120000,10),(3,'Mike',45000,20);

CREATE TABLE Org (Id INT, Name VARCHAR(20), ManagerId INT NULL);
INSERT INTO Org VALUES (1,'CEO',NULL),(2,'MgrA',1),(3,'MgrB',1),(4,'Emp1',2),(5,'Emp2',2),(6,'Emp3',3);
```

## 2. Examples

Basic CTE:

```sql
WITH EmployeeCTE AS (
    SELECT Id, Name, Salary FROM Employees WHERE Salary > 50000
)
SELECT * FROM EmployeeCTE;
```

Multi-step (vs nested mess):

```sql
WITH HighPaid AS (
    SELECT * FROM Employees WHERE Salary > 100000
)
SELECT * FROM HighPaid WHERE DepartmentId = 10;
```

Chained CTEs:

```sql
WITH FirstCTE AS (...),
SecondCTE AS (SELECT ... FROM FirstCTE ...)
SELECT ... FROM SecondCTE;
```

Recursive (org hierarchy):

```sql
WITH OrgTree AS (
    SELECT Id, Name, ManagerId, 0 AS Lvl
    FROM Org WHERE ManagerId IS NULL          -- anchor: CEO
    UNION ALL
    SELECT o.Id, o.Name, o.ManagerId, t.Lvl + 1
    FROM Org o JOIN OrgTree t ON o.ManagerId = t.Id  -- recursive: reports
)
SELECT * FROM OrgTree;
```

## 3. Query breakdown (recursive)

1. Anchor runs once → `{CEO, Lvl 0}`.
2. Recursive member joins `Org` to prior level → managers' direct reports, `Lvl+1`.
3. Repeats until no new rows. `UNION ALL` stacks levels.
4. Final SELECT reads the built-up set. `OPTION (MAXRECURSION n)` caps runaway recursion (default 100).

## 4. Edge cases

- CTE lives for **one statement only** — the SELECT right after it. Two SELECTs need the CTE defined twice or a temp table.
- Not materialized / not a temp table: generally inlined per reference; referencing the same CTE twice can execute twice — check the plan.
- Recursive CTE requires `UNION ALL`, matching column counts, and a terminating anchor — cycles in data = infinite loop without `MAXRECURSION`.
- Forward reference banned: `SecondCTE` can read `FirstCTE`, not vice versa.
- `WITH` must be first in its statement — preceding statement needs `;` terminator (`;WITH` habit).
- One CTE can't be indexed; for large reused sets use #temp + index (Level 2: CTE vs temp vs table variable).

## 5. Interview scenario questions

1. "Huge nested query — refactor?" → Chain CTEs per logical step.
2. "CEO → managers → employees traversal?" → Recursive CTE with anchor + recursive member.
3. "Does CTE create a temp table?" → No — single-statement named expression, generally not materialized.
4. "Reference CTE in two separate SELECTs?" → No — scope is one statement; use temp table/view.
5. "Recursion never ends — guard?" → Data cycle; add `OPTION (MAXRECURSION 100)` (or 0 = unlimited, dangerous).

## Cheat recap

```text
WITH x AS (...) SELECT ... FROM x;
Readability + step-wise logic + recursion. One-statement scope, not a temp table.
```
