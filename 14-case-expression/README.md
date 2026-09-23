# 14 — CASE Expression (If-Then in Queries)

**Goal:** Branch in SELECT/WHERE/ORDER BY with simple + searched CASE, and pivot rows to columns two ways.

## Definition (say this in the interview)

**What it is:** CASE is SQL's if-then-else that gives back one value per row.
Simple form matches one field to values; searched form tests free rules with
WHENs, one ELSE fallback, and END. Null ELSE when no WHEN hits and no ELSE set.

**Why it was introduced:** Raw fields rarely match shown needs — pay must show
as High/Med/Low bands, sort must float blanks last. CASE puts that rule work in
the query, next to the data, not strewn in app code.

**What problem it resolves:** Without it each row needs app-side ifs (chatty) or
rigid lookup tables for trivial bands. CASE bands, flags, and pivots inline —
one trip, same rules for all readers.

**Interview-ready answer:** *"CASE is if-then-else in a query, giving one value
per row. Simple form matches a field. Searched form tests free rules with WHEN
and ELSE. No hit and no ELSE means NULL. I use it to band pay, flag rows, sort
blanks last — and with SUM to pivot rows into columns."*

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT, Name VARCHAR(20), Salary INT NULL, DeptId INT);
INSERT INTO #Emp VALUES (1, 'Asha', 120000, 10), (2, 'Dev', 80000, 10),
(3, 'Ravi', 45000, 20), (4, 'Kiran', NULL, 20);
```

## 2. Examples

Input `#Emp` used by every example below:

| Id | Name | Salary | DeptId |
|---:|---|---:|---:|
| 1 | Asha | 120000 | 10 |
| 2 | Dev | 80000 | 10 |
| 3 | Ravi | 45000 | 20 |
| 4 | Kiran | NULL | 20 |

Example 1 — searched bands:

```sql
SELECT
    Name,
    Salary,
    CASE
        WHEN Salary >= 100000 THEN 'High'
        WHEN Salary >= 60000 THEN 'Med'
        ELSE 'Low'
    END AS Band
FROM #Emp;
```

Input: 4 rows above.

Output (4 rows):

| Name | Salary | Band |
|---|---|---|
| Asha | 120000 | High |
| Dev | 80000 | Med |
| Ravi | 45000 | Low |
| Kiran | NULL | Low |

Example 2 — simple decode:

```sql
SELECT
    Name,
    CASE DeptId WHEN 10 THEN 'IT' WHEN 20 THEN 'HR' ELSE 'Other' END AS Dept
FROM #Emp;
```

Input: 4 rows above.

Output (4 rows):

| Name | Dept |
|---|---|
| Asha | IT |
| Dev | IT |
| Ravi | HR |
| Kiran | HR |

Example 3 — blanks last:

```sql
SELECT * FROM #Emp
ORDER BY CASE WHEN Salary IS NULL THEN 1 ELSE 0 END, Salary DESC;
```

Input: 4 rows above.

Output (4 rows in order):

| Id | Name | Salary | DeptId |
|---:|---|---:|---:|
| 1 | Asha | 120000 | 10 |
| 2 | Dev | 80000 | 10 |
| 3 | Ravi | 45000 | 20 |
| 4 | Kiran | NULL | 20 |

Example 4 — pivot `SUM(CASE)`:

```sql
SELECT
    DeptId,
    SUM(CASE WHEN Salary >= 100000 THEN 1 ELSE 0 END) AS HighCnt,
    COUNT(*) AS Total
FROM #Emp GROUP BY DeptId;
```

Input: 4 rows above.

Output (2 rows):

| DeptId | HighCnt | Total |
|---:|---:|---:|
| 10 | 1 | 2 |
| 20 | 0 | 2 |

Example 5 — `PIVOT` operator:

```sql
SELECT
    [10] AS IT,
    [20] AS HR
FROM
    (SELECT
        DeptId,
        Salary
    FROM #Emp WHERE Salary IS NOT NULL) s
PIVOT (AVG(Salary) FOR DeptId IN ([10], [20])) p;
```

Input: 3 non-NULL rows.

Output (1 row):

| IT | HR |
|---:|---:|
| 100000 | 45000 |

## 3. Query breakdown (band CASE)

Per row: test `Salary >= 100000` → 'High', stop. Else test `>= 60000` →
'Med', stop. Else 'Low'. NULL pay fails all tests (NULL test = UNKNOWN) and
lands on ELSE — the silent-NULL-catch most miss in checks.

## 4. Edge cases

- No hit + no ELSE = NULL — add ELSE when blanks would shock readers.
- Output type = top-rank type of all returns — mix text and ints and ints turn text.
- WHENs test in order — put tight rules first, wide nets last.
- CASE gives values, not flow — can't run UPDATEs in branches; use WHERE/IF outside.
- PIVOT needs a known column list — shifting months need dynamic SQL (see `25`).
- PIVOT hides its group fields — feed it a tight subquery or stray fields split groups.

## 5. Interview scenario questions

1. "Band pay High/Med/Low incl. blanks?" → Searched CASE, ELSE 'Low' catches NULLs.
2. "Sort blanks last?" → `ORDER BY CASE WHEN x IS NULL THEN 1 ELSE 0 END, x`.
3. "Count High earners per team in one query?" → `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` + GROUP BY.
4. "Rows to columns for 12 fixed months?" → PIVOT with fixed list.
5. "Months shift each run?" → Dynamic SQL builds the list (see `25`).

## Cheat recap

```text
CASE WHEN t THEN v ELSE d END | simple matches field | searched tests rules
No hit + no ELSE = NULL | type = top-rank return | WHEN order counts
Pivot: SUM(CASE...) free-form | PIVOT op fixed-list | UNPIVOT cols→rows
```
