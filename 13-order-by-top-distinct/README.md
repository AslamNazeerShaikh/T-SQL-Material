# 13 — ORDER BY, TOP, DISTINCT (Ordered, Limited, Unique Lists)

**Goal:** Sort right, cap lists two ways (TOP vs OFFSET-FETCH), and de-dupe with DISTINCT.

## Definition (say this in the interview)

**What it is:** `ORDER BY` sets row order (ASC up, DESC down). `TOP n` (T-SQL)
or `OFFSET/FETCH` (ANSI paging) caps how many rows come back. `DISTINCT` drops
repeat rows so each line is one of a kind.

**Why it was introduced:** Tables hold sets with no order — screens need "top 10
pay," "page 2 of list," "all cities once." These three clauses turn a set into a
shown list: sorted, capped, de-duped.

**What problem it resolves:** Without them the app sorts and pages in memory —
slow and racy as data shifts mid-pages. Server-side sort + cap + de-dupe keeps
pages fast, stable, and small on the wire.

**Interview-ready answer:** *"ORDER BY sorts — ASC up, DESC down. TOP n caps
fast lists in T-SQL, while OFFSET plus FETCH pages ANSI-style but needs an
ORDER BY. DISTINCT drops repeat rows. For page-safe lists I sort by a one-of-a-
kind key, else ties jump pages between reads."*

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT, Name VARCHAR(20), Salary INT, City VARCHAR(20));
INSERT INTO #Emp VALUES (1,'Asha',90000,'Pune'),(2,'Dev',80000,'Pune'),
 (3,'Ravi',90000,'Mumbai'),(4,'Kiran',70000,'Pune'),(5,'Meena',80000,'Mumbai');
```

## 2. Examples

```sql
-- Sort: two keys, mixed ways
SELECT * FROM #Emp ORDER BY Salary DESC, Name ASC;

-- Cap: TOP n (+ WITH TIES keeps pay-ties), percent form
SELECT TOP 3 * FROM #Emp ORDER BY Salary DESC;
SELECT TOP 1 WITH TIES * FROM #Emp ORDER BY Salary DESC;  -- Asha + Ravi (tie)

-- Page: rows 3-4 (ANSI, ORDER BY a must)
SELECT * FROM #Emp ORDER BY Id OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;

-- De-dupe: one-of-a-kind cities; count of same
SELECT DISTINCT City FROM #Emp;
SELECT City, COUNT(*) AS Times FROM #Emp GROUP BY City;  -- de-dupe + counts
```

## 3. Query breakdown (paging)

`ORDER BY Id OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY`: sort full set by Id
(1..5), skip 2 (Ids 1,2), take next 2 (Ids 3,4). Stable only if the sort key is
one of a kind — ties can swap slots between page reads.

## 4. Edge cases

- No ORDER BY = no promised order. Looks sorted today (index scan), scrambles morrow.
- `OFFSET/FETCH` with no ORDER BY → error. `TOP` with no ORDER BY → random n rows.
- `DISTINCT` + ORDER BY: sort fields must sit in the SELECT list.
- `TOP` ties cut mid-tie — `WITH TIES` keeps the full tie club (needs ORDER BY).
- `DISTINCT` checks full rows — want one field's list? Name just that field.
- Ties + paging: always add Id as last sort key for page-stable lists.

## 5. Interview scenario questions

1. "Top 3 pay?" → `TOP 3 ... ORDER BY Salary DESC`. Ties matter? Add `WITH TIES`.
2. "Page 2, 10 per page?" → `ORDER BY Id OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY`.
3. "All cities once?" → `SELECT DISTINCT City`. With counts? GROUP BY form.
4. "Same query, new order each run — why?" → No ORDER BY. Add one on a kind key.
5. "Nth top pay (say 2nd)?" → `OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY` on DESC pay — full Nth-salary craft lives in `16`.

## Cheat recap

```text
ORDER BY col ASC|DESC | no ORDER BY = no promised order
TOP n [WITH TIES] | OFFSET m FETCH NEXT n (ORDER BY a must)
DISTINCT full-row de-dupe | page-safe = sort by kind key
```
