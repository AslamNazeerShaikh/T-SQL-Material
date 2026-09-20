# 10 — Clustered vs Non-Clustered Index

**Goal:** Explain the physical difference, the 1-per-table rule, and PK ≠ clustered.

## Definition (say this in the interview)

**What it is:** An index is an auxiliary structure SQL Server maintains so it can find rows without scanning the whole table. A clustered index dictates the logical order of the table's rows themselves — one per table maximum, since rows have a single order. A non-clustered index is a separate structure holding the key plus a locator to the row — many allowed per table.

**Why it was introduced:** Table scans don't scale: finding one customer among a hundred million rows by reading every page is unusable. Indexes trade extra storage and slower writes for fast seeks — the same reason books have an index instead of requiring you to read every page.

**What problem it resolves:** Without indexes every lookup and every range query (`BETWEEN`, `ORDER BY`, joins) degrades to a full scan. The clustered index additionally gives one ordering that makes range scans contiguous, while non-clustered indexes accelerate filters on other columns — at the cost of maintenance on each write, which is why you index deliberately, not blindly.

**Interview-ready answer:** *"A clustered index sets the row order of the table — just one per table. So it suits range scans, and most days backs the primary key. Non-clustered tags are side lists — key plus row mark — many per table, for search fields. Two points go wrong oft. One, a primary key need not be clustered — that is just the default. Two, the clustered key is pasted in all side lists — so keep it small, fixed, and on the rise, like INT IDENTITY."*

## 1. Sample setup

```sql
CREATE TABLE Employees (Id INT, Name VARCHAR(100), Salary INT);

CREATE CLUSTERED INDEX IX_Employees_Id ON Employees(Id);
CREATE NONCLUSTERED INDEX IX_Employees_Name ON Employees(Name);
```

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
CREATE TABLE Orders (
    OrderId INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY NONCLUSTERED,
    OrderDate DATE NOT NULL
);
CREATE CLUSTERED INDEX IX_Orders_Date ON Orders(OrderDate);
```

## Cheat recap

```text
Clustered → max 1, row order, range/PK access
Non-clustered → many, separate key+locator, filters
PK defaults clustered but PK ≠ clustered. Keep clustered key narrow/static.
```
