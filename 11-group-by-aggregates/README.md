# 11 — GROUP BY + Aggregate Functions

**Goal:** Group rows and total them right — COUNT/SUM/AVG/MIN/MAX, `COUNT(*)` vs `COUNT(col)`, dup-spotting with HAVING.

## Definition (say this in the interview)

**What it is:** `GROUP BY` clubs same-value rows into one set, and aggregate
calls (COUNT, SUM, AVG, MIN, MAX) boil each set down to one number. One row out
per group — the reverse of window calls, which keep all rows (see `16`).

**Why it was introduced:** Lists don't answer "how much per team." Reports need
one line per team with a total, not a thousand raw rows. Group-then-total turns
raw logs into heads-up numbers in one server step.

**What problem it resolves:** Without it you pull all rows and total them in app
code — slow, chatty, and racy. GROUP BY pushes the math to the data, with the
engine's sums you can trust.

**Interview-ready answer:** *"GROUP BY clubs same-value rows, and COUNT, SUM,
AVG, MIN, MAX boil each club to one number. COUNT star counts rows. COUNT of a
field skips blanks. AVG skips blanks too. I pair it with HAVING to keep only
strong groups — like teams with more than five staff."*

## 1. Sample table

```sql
CREATE TABLE #Sales (Region VARCHAR(10), Seller VARCHAR(20), Amt INT NULL);
INSERT INTO #Sales VALUES
 ('East','Asha',100),('East','Asha',200),('East','Dev',NULL),
 ('West','Ravi',300),('West','Ravi',300),('West',NULL,150);
```

## 2. Examples

Input `#Sales` used by every example below:

| Region | Seller | Amt |
|---|---|---:|
| East | Asha | 100 |
| East | Asha | 200 |
| East | Dev | NULL |
| West | Ravi | 300 |
| West | Ravi | 300 |
| West | NULL | 150 |

Example 1 — totals per region (NULL amts skipped):

```sql
SELECT Region, COUNT(*) AS Rows, COUNT(Amt) AS Priced,
       SUM(Amt) AS Total, AVG(Amt * 1.0) AS AvgAmt,
       MIN(Amt) AS Lo, MAX(Amt) AS Hi
FROM #Sales GROUP BY Region;
```

Input: 6 rows above.

Output (2 rows):

| Region | Rows | Priced | Total | AvgAmt | Lo | Hi |
|---|---|---:|---:|---:|---:|---:|
| East | 3 | 2 | 300 | 150.0 | 100 | 200 |
| West | 3 | 3 | 750 | 250.0 | 150 | 300 |

Example 2 — dupes (`HAVING COUNT(*) > 1`):

```sql
SELECT Seller, COUNT(*) AS Times
FROM #Sales GROUP BY Seller HAVING COUNT(*) > 1;
```

Input: 6 rows above.

Output (2 rows):

| Seller | Times |
|---|---:|
| Asha | 2 |
| Ravi | 2 |

Example 3 — empty-set aggregate:

```sql
SELECT SUM(Amt) AS SumNone, COUNT(*) AS CntNone FROM #Sales WHERE 1 = 2;
```

Input: 0 rows (filter kills all).

Output (1 row):

| SumNone | CntNone |
|---|---:|
| NULL | 0 |

Example 4 — `ROLLUP` grand total:

```sql
SELECT Region, Seller, SUM(Amt) AS Total
FROM #Sales GROUP BY ROLLUP (Region, Seller);
```

Input: 6 rows above.

Output (7 rows):

| Region | Seller | Total |
|---|---|---:|
| East | Asha | 300 |
| East | Dev | NULL |
| East | NULL | 300 |
| West | Ravi | 600 |
| West | NULL | 150 |
| West | NULL | 750 |
| NULL | NULL | 1050 |

## 3. Query breakdown (dup-spotter)

1. `GROUP BY Seller` clubs rows per name (blanks form their own club).
2. `COUNT(*)` counts rows per club — blanks included.
3. `HAVING COUNT(*) > 1` keeps only clubs with repeats. `WHERE` can't do this —
   totals don't live yet at row-filter time (see `06`).

## 4. Edge cases

- `COUNT(*)` counts rows; `COUNT(col)` skips NULLs — mixing them up undercounts.
- `SUM`/`AVG` skip NULLs; `SUM` of zero rows is NULL (not 0), `COUNT` is 0.
- `AVG` on ints cuts the tail (`AVG(5,4)` = 4) — times `1.0` or cast first.
- `GROUP BY` rejects SELECT nicknames — restate the full phrase or wrap in a CTE.
- `COUNT(DISTINCT col)` takes one field only in T-SQL — need two? Pre-group first.
- Every plain SELECT field must sit in GROUP BY or in a total call — else error.

## 5. Interview scenario questions

1. "Total pay per team, keep teams over 5 staff?" → `GROUP BY Dept HAVING COUNT(*) > 5`.
2. "Find dup mails, show the dup rows?" → Keys via `GROUP BY mail HAVING COUNT(*)>1`, then join back for full rows.
3. "COUNT star vs COUNT id — ever differ?" → Yes when id holds NULLs. Star counts rows, field-count skips blanks.
4. "Grand total plus per-team lines in one shot?" → `ROLLUP` — extra `NULL`-key row is the grand total.
5. "AVG looks low — bug?" → Check NULLs (skipped) and int math (cast to decimal).

## Cheat recap

```text
GROUP BY clubs rows | COUNT SUM AVG MIN MAX boil each club to one number
COUNT(*) rows | COUNT(col) skips NULL | AVG int math → cast first
Dupe keys: GROUP BY x HAVING COUNT(*) > 1 | ROLLUP adds grand total
```
