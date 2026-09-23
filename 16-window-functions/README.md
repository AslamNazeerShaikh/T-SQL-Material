# 16 — Window Functions (Rank, Totals, Shifts, Nth Pay)

**Goal:** Rank rows, run totals, peek at next/prev rows — all with rows kept (unlike GROUP BY).

## Definition (say this in the interview)

**What it is:** Window calls math over a "glass" of linked rows (`OVER (...)`)
while keeping each row. `PARTITION BY` cuts the glass per team (fresh count per
team); `ORDER BY` lines rows up in it. Stars: ROW_NUMBER (1,2,3…), RANK
(1,2,2,4 — ties share, next skips), DENSE_RANK (1,2,2,3 — no skip), SUM OVER
(run total), LEAD/LAG (peek next/prev row).

**Why it was introduced:** GROUP BY crushes rows to totals, but reports need
both — each staff line *plus* her team rank, run total next to each sale.
Self-joins faked this slow and ugly. OVER gives row-plus-math in one pass.

**What problem it resolves:** Top-N per team, Nth top pay, run totals, gap
checks — all in one read, no self-joins, no temp piles. Plus de-dupe: number
dup rows and keep `rn = 1`.

**Interview-ready answer:** *"Window calls work over a glass of rows with OVER,
keep all rows, and cut fresh per team with PARTITION BY. ROW_NUMBER gives
1-2-3. RANK shares ties and skips next. DENSE_RANK shares with no skip. SUM
OVER gives run totals. LEAD and LAG peek next and last rows with no self-join.
Top gun uses: top N per team, Nth top pay, and kill dupes with row number 1."*

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT, Name VARCHAR(20), DeptId INT, Salary INT);
INSERT INTO #Emp VALUES (1, 'Asha', 10, 90000),
(2, 'Dev', 10, 90000),
(3, 'Ravi', 10, 80000),
(4, 'Kiran', 20, 70000), (5, 'Meena', 20, 70000), (6, 'Tom', 20, 60000);
```

## 2. Examples

Input `#Emp` used by every example below:

| Id | Name | DeptId | Salary |
|---:|---|---:|---:|
| 1 | Asha | 10 | 90000 |
| 2 | Dev | 10 | 90000 |
| 3 | Ravi | 10 | 80000 |
| 4 | Kiran | 20 | 70000 |
| 5 | Meena | 20 | 70000 |
| 6 | Tom | 20 | 60000 |

Example 1 — rank trio, fresh per team:

```sql
SELECT
    Name,
    DeptId,
    Salary,
    ROW_NUMBER() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rn,
    RANK() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rnk,
    DENSE_RANK() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS drnk
FROM #Emp;
```

Input: 6 rows above.

Output (6 rows):

| Name | DeptId | Salary | rn | rnk | drnk |
|---|---|---:|---:|---:|---:|
| Asha | 10 | 90000 | 1 | 1 | 1 |
| Dev | 10 | 90000 | 2 | 1 | 1 |
| Ravi | 10 | 80000 | 3 | 3 | 2 |
| Kiran | 20 | 70000 | 1 | 1 | 1 |
| Meena | 20 | 70000 | 2 | 1 | 1 |
| Tom | 20 | 60000 | 3 | 3 | 2 |

Example 2 — top 1 per team:

```sql
WITH R AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rn
    FROM #Emp
)

SELECT * FROM R WHERE rn = 1;
```

Input: 6 rows above.

Output (2 rows — tie pick nondet):

| Id | Name | DeptId | Salary |
|---:|---|---:|---:|
| 1 | Asha | 10 | 90000 |
| 4 | Kiran | 20 | 70000 |

Example 3 — 2nd top distinct pay:

```sql
WITH D AS (
    SELECT
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS dr
    FROM #Emp
)

SELECT DISTINCT Salary FROM D WHERE dr = 2;
```

Input pays: 90000, 90000, 80000, 70000, 70000, 60000.

Output (1 row):

| Salary |
|---:|
| 80000 |

Example 4 — running total:

```sql
SELECT
    Name,
    Salary,
    SUM(Salary) OVER (PARTITION BY DeptId ORDER BY Salary) AS RunTotal
FROM #Emp;
```

Input: 6 rows above.

Output (6 rows):

| Name | Salary | RunTotal |
|---|---|---:|
| Ravi | 80000 | 80000 |
| Asha | 90000 | 260000 |
| Dev | 90000 | 260000 |
| Tom | 60000 | 60000 |
| Kiran | 70000 | 200000 |
| Meena | 70000 | 200000 |

Example 5 — grand total:

```sql
SELECT
    Name,
    Salary,
    SUM(Salary) OVER () AS GrandTotal
FROM #Emp;
```

Input: 6 rows above.

Output (6 rows — every row `GrandTotal` 460000):

| Name | Salary | GrandTotal |
|---|---|---:|
| Asha | 90000 | 460000 |
| Dev | 90000 | 460000 |
| Ravi | 80000 | 460000 |
| Kiran | 70000 | 460000 |
| Meena | 70000 | 460000 |
| Tom | 60000 | 460000 |

Example 6 — `LEAD` / `LAG` gaps:

```sql
SELECT
    Name,
    Salary,
    LEAD(Salary) OVER (ORDER BY Salary DESC) AS NextPay,
    Salary - LAG(Salary, 1, Salary) OVER (ORDER BY Salary DESC) AS GapVsPrev
FROM #Emp;
```

Input: 6 rows above.

Output (6 rows):

| Name | Salary | NextPay | GapVsPrev |
|---|---|---:|---:|---:|
| Asha | 90000 | 90000 | 0 |
| Dev | 90000 | 80000 | 0 |
| Ravi | 80000 | 70000 | -10000 |
| Kiran | 70000 | 70000 | -10000 |
| Meena | 70000 | 60000 | 0 |
| Tom | 60000 | NULL | -10000 |

Example 7 — de-dupe dry run:

```sql
-- WITH D AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY Name, Salary ORDER BY Id) AS rn FROM #Emp)
-- DELETE FROM D WHERE rn > 1;
```

Input: 6 rows above (all pairs unique).

Output: 0 rows.

| Id | Name | DeptId | Salary | rn |
|---|---|---|---|---|
| *(no rows)* | | | | |

## 3. Query breakdown (rank trio on Asha/Dev tie)

Same pay, same team: ROW_NUMBER must differ (1,2 — order of ties is luck unless
key added). RANK shares 1,1 then skips to 3. DENSE_RANK shares 1,1 then keeps
2. Rule: need one row? ROW_NUMBER. Need fair tie clubs? DENSE_RANK.

## 4. Edge cases

- ROW_NUMBER needs ORDER BY in OVER — ties break at random; add Id for firm order.
- No PARTITION BY = one glass for full table (grand rank / grand total per row).
- `SUM() OVER (ORDER BY x)` runs total; `SUM() OVER ()` pastes grand total each row.
- RANK gaps shift Top-N counts — `rnk <= 2` can give 3+ rows on ties.
- Window calls can't sit in WHERE — wrap in CTE first, then filter (`WHERE rn = 1` on the CTE).
- LEAD/LAG past the edge give NULL — third input sets a safe fallback.

## 5. Interview scenario questions

1. "Top 2 per team?" → ROW_NUMBER per team, keep `rn <= 2`.
2. "2nd top pay, ties fair?" → DENSE_RANK ladder, pick `dr = 2`.
3. "Run total per team?" → `SUM(Salary) OVER (PARTITION BY DeptId ORDER BY Salary)`.
4. "Pay jump vs last staff, no join?" → `Salary - LAG(Salary) OVER (ORDER BY Salary)`.
5. "Dup rows, keep one?" → ROW_NUMBER per dup key, delete `rn > 1` through CTE.
6. "RANK vs DENSE_RANK vs ROW_NUMBER, one line each?" → 1-2-2-4 / 1-2-2-3 / 1-2-3-4.

## 6. NTILE buckets (asked with the rank trio)

`NTILE(n)` cuts ordered rows into n near-even clubs (4 = quartiles) — ties may
split across clubs (unlike DENSE_RANK, which keeps tie clubs whole).

## Cheat recap

```text
OVER glass | PARTITION BY fresh per team | ORDER BY lines rows up
ROW_NUMBER 1-2-3 | RANK 1-2-2-4 | DENSE_RANK 1-2-2-3
Top-N per team rn<=N | Nth pay DENSE ladder | run SUM OVER | gaps LEAD/LAG
De-dupe: rn per dup key, keep 1 | no window calls in WHERE — CTE first
NTILE cuts n clubs (ties may split).
```
