# 10 — Clustered vs Non-Clustered Index

**Goal:** Explain the physical difference, the 1-per-table rule, and PK ≠ clustered.

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
