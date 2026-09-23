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

Input `#Emp` used by every example below:

| Id | Name | Salary | City |
|---:|---|---:|---|
| 1 | Asha | 90000 | Pune |
| 2 | Dev | 80000 | Pune |
| 3 | Ravi | 90000 | Mumbai |
| 4 | Kiran | 70000 | Pune |
| 5 | Meena | 80000 | Mumbai |

Example 1 — sort two keys:

```sql
SELECT * FROM #Emp ORDER BY Salary DESC, Name ASC;
```

Input: 5 rows above.

Output (5 rows in order):

| Id | Name | Salary | City |
|---:|---|---:|---|
| 1 | Asha | 90000 | Pune |
| 3 | Ravi | 90000 | Mumbai |
| 2 | Dev | 80000 | Pune |
| 5 | Meena | 80000 | Mumbai |
| 4 | Kiran | 70000 | Pune |

Example 2 — `TOP 3`:

```sql
SELECT TOP 3 * FROM #Emp ORDER BY Salary DESC;
```

Input: 5 rows above.

Output (3 rows — third pick nondet without 2nd key):

| Id | Name | Salary | City |
|---:|---|---:|---|
| 1 | Asha | 90000 | Pune |
| 3 | Ravi | 90000 | Mumbai |
| 2 | Dev | 80000 | Pune |

Example 3 — `WITH TIES`:

```sql
SELECT TOP 1 WITH TIES * FROM #Emp ORDER BY Salary DESC;
```

Input: 5 rows above.

Output (2 rows):

| Id | Name | Salary | City |
|---:|---|---:|---|
| 1 | Asha | 90000 | Pune |
| 3 | Ravi | 90000 | Mumbai |

Example 4 — `TOP 40 PERCENT` (40% of 5 = 2):

```sql
SELECT TOP 40 PERCENT * FROM #Emp ORDER BY Salary DESC;
```

Input: 5 rows above.

Output (2 rows):

| Id | Name | Salary | City |
|---:|---|---:|---|
| 1 | Asha | 90000 | Pune |
| 3 | Ravi | 90000 | Mumbai |

Example 5 — paging rows 3–4:

```sql
SELECT * FROM #Emp ORDER BY Id OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;
```

Input: 5 rows above.

Output (2 rows):

| Id | Name | Salary | City |
|---:|---|---:|---|
| 3 | Ravi | 90000 | Mumbai |
| 4 | Kiran | 70000 | Pune |

Example 6 — 2nd pay:

```sql
SELECT Salary FROM #Emp ORDER BY Salary DESC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;
```

Input pays: 90000, 90000, 80000, 80000, 70000.

Output (1 row):

| Salary |
|---:|
| 90000 |

Example 7 — last 2 by `Id DESC`:

```sql
SELECT * FROM #Emp ORDER BY Id DESC OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;
```

Input: 5 rows above.

Output (2 rows):

| Id | Name | Salary | City |
|---:|---|---:|---|
| 5 | Meena | 80000 | Mumbai |
| 4 | Kiran | 70000 | Pune |

Example 8 — `DISTINCT` cities:

```sql
SELECT DISTINCT City FROM #Emp;
```

Input: 5 rows above.

Output (2 rows):

| City |
|---|
| Pune |
| Mumbai |

Example 9 — counts:

```sql
SELECT City, COUNT(*) AS Times FROM #Emp GROUP BY City;
```

Input: 5 rows above.

Output (2 rows):

| City | Times |
|---|---:|
| Pune | 3 |
| Mumbai | 2 |

Example 10 — `DISTINCT` melts NULLs:

```sql
SELECT DISTINCT x FROM (VALUES (1),(NULL),(NULL)) v(x);
```

Input (no `ORDER BY`, so engine order is undefined — this run returned):

| x |
|---:|
| NULL |
| NULL |
| 1 |

Output (2 rows — `DISTINCT` melts the two NULLs into one; display order
undefined, this run returned NULL first):

| x |
|---:|
| NULL |
| 1 |

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

## 6. More list law (asked follow-ups)

- DISTINCT vs GROUP BY: DISTINCT = unique rows, no math. GROUP BY = unique clubs
  + totals (`11`). Need counts? GROUP BY. Need a bare list? DISTINCT.
- T-SQL has NO `NULLS FIRST/LAST` — blanks-first needs CASE (`14`):
  `ORDER BY CASE WHEN x IS NULL THEN 0 ELSE 1 END, x`.
- DISTINCT melts NULLs to one row (unlike `=` tests, see `12`).
- Last N rows: flip the sort — `ORDER BY Id DESC OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY`.
- `ORDER BY 2` (ordinal) runs but rots on SELECT edits — name fields. Per-query
  case law: `ORDER BY Name COLLATE Latin1_General_CS_AS` (`02`).

## Cheat recap

```text
ORDER BY col ASC|DESC | no ORDER BY = no promised order
TOP n [WITH TIES] | OFFSET m FETCH NEXT n (ORDER BY a must)
DISTINCT full-row de-dupe | page-safe = sort by kind key
no NULLS FIRST (CASE instead) | DISTINCT melts NULLs | last-N = flipped sort.
```
