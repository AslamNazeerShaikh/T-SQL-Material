# 10 — Clustered vs Non-Clustered Index

**Goal:** Explain the physical difference, the 1-per-table rule, and PK ≠ clustered.

## Definition (say this in the interview)

**What it is:** An index is an auxiliary structure SQL Server maintains so it can find rows without scanning the whole table. A clustered index dictates the logical order of the table's rows themselves — one per table maximum, since rows have a single order. A non-clustered index is a separate structure holding the key plus a locator to the row — many allowed per table.

**Why it was introduced:** Table scans don't scale: finding one customer among a hundred million rows by reading every page is unusable. Indexes trade extra storage and slower writes for fast seeks — the same reason books have an index instead of requiring you to read every page.

**What problem it resolves:** Without indexes every lookup and every range query (`BETWEEN`, `ORDER BY`, joins) degrades to a full scan. The clustered index additionally gives one ordering that makes range scans contiguous, while non-clustered indexes accelerate filters on other columns — at the cost of maintenance on each write, which is why you index deliberately, not blindly.

**Interview-ready answer:** *"A clustered index sets the row order of the table — just one per table. So it suits range scans, and most days backs the primary key. Non-clustered tags are side lists — key plus row mark — many per table, for search fields. Two points go wrong oft. One, a primary key need not be clustered — that is just the default. Two, the clustered key is pasted in all side lists — so keep it small, fixed, and on the rise, like INT IDENTITY."*

> Next step: `26-query-optimization/` — plans, seeks, sargability.

## 1. Sample setup

```sql
CREATE TABLE dbo.Employees (Id INT, Name VARCHAR(100), Salary INT);
-- Input rows used below:
-- (1,'John',80000),(2,'Sara',90000),(3,'Mike',45000)

CREATE CLUSTERED INDEX IX_Employees_Id ON dbo.Employees(Id);
CREATE NONCLUSTERED INDEX IX_Employees_Name ON dbo.Employees(Name);
```

Input `dbo.Employees`:

| Id | Name | Salary |
|---:|---|---:|
| 1 | John | 80000 |
| 2 | Sara | 90000 |
| 3 | Mike | 45000 |

Example 1 — clustered range seek:

```sql
SELECT * FROM dbo.Employees WHERE Id BETWEEN 1 AND 2;
```

Input: 3 rows above.

Output (2 rows):

| Id | Name | Salary |
|---:|---|---:|
| 1 | John | 80000 |
| 2 | Sara | 90000 |

Example 2 — nonclustered seek on `Name`:

```sql
SELECT * FROM dbo.Employees WHERE Name = 'Sara';
```

Input: 3 rows above.

Output (1 row):

| Id | Name | Salary |
|---:|---|---:|
| 2 | Sara | 90000 |

Example 3 — covering `INCLUDE(Salary)`:

```sql
SELECT Name, Salary FROM dbo.Employees WHERE Name = 'Sara';
```

Input: 3 rows above.

Output (1 row):

| Name | Salary |
|---|---:|
| Sara | 90000 |

Example 4 — composite seek:

```sql
SELECT * FROM dbo.Employees WHERE Id = 1 AND Name = 'John';
```

Input: 3 rows above.

Output (1 row):

| Id | Name | Salary |
|---:|---|---:|
| 1 | John | 80000 |

## 2. Definitions

Clustered index — defines the **logical order of data rows by the key**. The table's clustered structure. One per table max (rows have one order).

Non-clustered index — separate structure: key + row locator. Many per table. Great for search/filter columns without reordering the table.

## 3. Comparison

| Feature | Clustered | Non-Clustered |
|---|---|---|
| Number per table | Max 1 | Multiple |
| Determines row ordering | Yes | No |
| Separate structure | Yes (is the clustered table) | Yes (key + locator) |
| Range queries | Very useful | Useful |
| Included columns | Via definition | Yes (`INCLUDE`) |
| Common use | PK / range access | Search / filter columns |

## 4. Query breakdown

`WHERE Id BETWEEN 100 AND 200` with clustered on `Id`:

1. Seek to 100 in the clustered structure, scan forward to 200 — contiguous range, minimal I/O.

`WHERE Name = 'Sara'` with non-clustered on `Name`:

1. Seek the non-clustered index for 'Sara' → get row locator(s).
2. Key lookup to fetch remaining columns (or avoid it with covering `INCLUDE` columns).

## 5. Edge cases

- **PK ≠ clustered.** `PRIMARY KEY` defaults to clustered only if no clustered index exists and you don't say `NONCLUSTERED`. You can declare `PRIMARY KEY NONCLUSTERED` + a separate clustered index on a range column (e.g., date).
- Heap (no clustered index) + many non-clustered → lookups use RIDs; forwarded rows/fragmentation can hurt — usually add a clustered key.
- Wide/clustered key tax: clustered key is copied into every non-clustered index — keep it narrow, static, increasing (`INT IDENTITY` ideal; GUID/varchar = bloat + fragmentation).
- Missing-index DMVs + execution plans suggest non-clustered indexes — validate with workload, don't blindly add.
- `INCLUDE` columns make covering indexes (no lookup) without widening the key.
- Index ≠ always faster: writes pay per index; unused/duplicate indexes cost maintenance + locks.

## 6. Interview scenario questions

1. "How many clustered per table?" → Max one. Many non-clustered.
2. "Is PK always clustered?" → No — default, not rule. `PRIMARY KEY NONCLUSTERED` is legal.
3. "Range query on dates is slow — index choice?" → Clustered (or well-chosen non-clustered) on the date for ordered range scans.
4. "Name lookups fast but SELECT * still slow?" → Key lookups; add `INCLUDE` covering columns or reassess clustered key.
5. "GUID PK, inserts fragmented — why?" → Random wide clustered key → page splits + bloat in all non-clustered indexes. Use `INT IDENTITY` or `NEWSEQUENTIALID()`.

```sql
-- PK explicitly nonclustered + separate clustered index
CREATE TABLE dbo.Orders (
    OrderId INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY NONCLUSTERED,
    OrderDate DATE NOT NULL
);
CREATE CLUSTERED INDEX IX_Orders_Date ON dbo.Orders(OrderDate);
```

## 7. Composite, covering recap + limits (asked follow-ups)

- Composite = key on 2+ fields: `CREATE NONCLUSTERED INDEX IX ON T(A, B)`.
  Leftmost law: seeks fly on `A` or `A+B`, never on `B` alone — lead with the
  most-filtered field.
- Covering recap: key fields sort/seek, INCLUDE fields ride leaf-only (§2 demo).
- Max: 999 non-clustered + 1 clustered = 1000 per table (asked number).
- Heap (no clustered) lookups ride RIDs; forwarded rows rot heaps — a clustered
  key usually wins for churned tables.

## Cheat recap

```text
Clustered → max 1, row order, range/PK access
Non-clustered → many, separate key+locator, filters
PK defaults clustered but PK ≠ clustered. Keep clustered key narrow/static.
Composite leftmost law | max 999 non-clustered | heaps ride RIDs.
```
