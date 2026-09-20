# T-SQL Study — SQL Server 2019 Interview Prep

Strictly focused on **Microsoft SQL Server 2019 + T-SQL** for a **Full-Stack Developer interview** that includes SQL question-answering.

No generic SQL. No other engine. Every example is SQL Server / T-SQL specific.

## How this repo is organized

Each topic lives in its own folder. Folder numbers = **difficulty / understanding level** (00 = start here, 10 = advanced for this set).

Each topic folder contains:

- `README.md` — answers, examples, sample tables, detailed query breakdown, edge cases, interview scenario questions
- `examples.sql` — runnable T-SQL scripts for that topic (SSMS / Azure Data Studio, SQL Server 2019+)

| # | Folder | Topic | Level |
|---|--------|-------|-------|
| 00 | `00-sql-comments/` | SQL Comments (`--`, `/* */`) + traps | Start here |
| 01 | `01-sql-statement-types/` | Types of SQL / T-SQL Statements (DDL, DML, DQL, DCL, TCL) + DELETE vs TRUNCATE vs DROP | Foundation |
| 02 | `02-character-data-types/` | Character Data Types (CHAR, VARCHAR, NCHAR, NVARCHAR) | Foundation |
| 03 | `03-keys/` | Types of Keys (Primary, Foreign, Unique, Candidate, Alternate, Composite) | Foundation |
| 04 | `04-constraints/` | Constraints (PK, FK, UNIQUE, NOT NULL, CHECK, DEFAULT) | Foundation → Easy |
| 05 | `05-query-vs-subquery/` | Query vs Subquery (scalar, multi-row, correlated) | Easy |
| 06 | `06-where-vs-having/` | WHERE vs HAVING | Easy → Medium |
| 07 | `07-joins/` | SQL Joins (INNER, LEFT, RIGHT, FULL, CROSS, SELF) | Medium |
| 08 | `08-union-vs-union-all/` | UNION vs UNION ALL | Medium |
| 09 | `09-cte/` | CTE — Common Table Expression (incl. recursive) | Medium → Advanced |
| 10 | `10-indexes/` | Clustered vs Non-Clustered Index | Advanced |
| 11 | `11-group-by-aggregates/` | GROUP BY + Aggregates (COUNT/SUM/AVG, dup-spotting, ROLLUP) | Easy → Medium |
| 12 | `12-null-handling/` | NULL, IS NULL, ISNULL vs COALESCE, NOT IN trap | Easy → Medium |
| 13 | `13-order-by-top-distinct/` | ORDER BY, TOP vs OFFSET-FETCH paging, DISTINCT | Easy → Medium |
| 14 | `14-case-expression/` | CASE (simple/searched), PIVOT rows→cols | Medium |
| 15 | `15-exists-vs-in/` | EXISTS vs IN vs JOIN, NULL-safe anti-joins | Medium |
| 16 | `16-window-functions/` | ROW_NUMBER/RANK/DENSE_RANK, running totals, LEAD/LAG, Nth salary | Medium → Advanced |
| 17 | `17-temp-tables-vs-variables/` | #temp vs ##temp vs @var vs CTE, SELECT INTO | Medium |
| 18 | `18-views/` | Views as saved queries + rights wall | Medium |
| 19 | `19-stored-procedures/` | Procs with params/OUTPUT/TRY-CATCH, cursors last-resort | Medium → Advanced |
| 20 | `20-functions/` | Scalar vs inline TVF vs multi-statement TVF | Advanced |
| 21 | `21-triggers/` | AFTER vs INSTEAD OF, inserted/deleted, audit + veto | Advanced |
| 22 | `22-transactions-acid/` | ACID, isolation levels, NOLOCK, deadlocks | Advanced |
| 23 | `23-normalization/` | 1NF/2NF/3NF + denormalize-when | Medium |
| 24 | `24-like-pattern-matching/` | LIKE wildcards, ESCAPE, seek vs scan | Easy → Medium |
| 25 | `25-dynamic-sql-injection/` | sp_executesql + params, QUOTENAME, injection defense | Advanced |
| 26 | `26-query-optimization/` | Plans, seeks vs scans, sargability, slow-query habits | Advanced |
| 27 | `27-data-types-numbers-dates/` | Numbers, dates, GUID/ROWVERSION/XML, IDENTITY vs SEQUENCE, bitwise | Easy → Medium |

> Naming convention: `NN-topic-name/` where `NN` is a zero-padded difficulty order. New topics continue as `11-...`, `12-...`, etc.

## How to study

1. Go in order `00 → 27` the first time.
2. For each topic: read `README.md`, run `examples.sql` in SSMS, try the **Scenario questions** without looking.
3. Use the **Cheat Sheet** at the bottom of each README for last-day revision.

## Prerequisites

- SQL Server 2019 (Developer / Express ok)
- SSMS or Azure Data Studio
- Basic `SELECT` knowledge

## Running the SQL files

Each `examples.sql` is self-contained. It creates its own sample tables (usually `#Temp` or uniquely named tables) so you can run the whole file with F5 without polluting your database.

```sql
-- Example
USE master; -- or your practice DB
-- Open 01-sql-statement-types/examples.sql and execute
```

## Cheat sheet (the 28 topics)

```text
0. -- → to line end | /* */ → block, nestable
1. DDL → CREATE, ALTER, DROP, TRUNCATE
   DML → INSERT, UPDATE, DELETE, MERGE
   DQL → SELECT
   DCL → GRANT, DENY, REVOKE
   TCL → BEGIN TRAN, COMMIT, ROLLBACK, SAVE TRAN

2. CHAR → fixed, non-Unicode
   VARCHAR → variable, non-Unicode
   VARCHAR(MAX) → large variable non-Unicode (~2GB)
   NCHAR → fixed Unicode
   NVARCHAR → variable Unicode
   NVARCHAR(MAX) → large variable Unicode

3. Query → SQL statement (usually SELECT)
   Subquery → query nested inside another query

4. Keys → Primary, Foreign, Candidate, Alternate, Composite, Unique

5. Constraints → PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK, DEFAULT

6. WHERE → filters rows (before grouping)
   HAVING → filters groups (after aggregation)

7. INNER → matching | LEFT → all left + match | RIGHT → all right + match
   FULL → everything | CROSS → Cartesian | SELF → self-join

8. UNION → removes duplicates | UNION ALL → keeps duplicates, less overhead

9. CTE → named temporary result for next statement, readability + recursion

10. Clustered → max 1/table, defines row order
    Non-clustered → many/table, separate structure

11. GROUP BY clubs rows, aggregates boil to one number
12. NULL = unknown | IS NULL tests | COALESCE/ISNULL fills | NOT IN + NULL = empty
13. ORDER BY sorts | TOP caps | OFFSET-FETCH pages | DISTINCT de-dupes
14. CASE = if-then per row | SUM(CASE) / PIVOT turn rows to columns
15. IN tests list | EXISTS stops early | NOT EXISTS NULL-safe anti
16. ROW_NUMBER 1-2-3 | RANK 1-2-2-4 | DENSE_RANK 1-2-2-3 | LEAD/LAG peek
17. #temp big/indexed | @var tiny | CTE one query | SELECT INTO WHERE 1=2 clones shape
18. View = saved SELECT, no rows | rights on view, base shut
19. Proc = named work + params/OUTPUT | TRY-CATCH deals | SET NOCOUNT ON
20. Scalar one value | inline TVF fast | multi-step TVF stats-blind
21. AFTER audits | INSTEAD OF vetoes/reshapes | inserted/deleted are sets
22. Deal wins whole | rungs UNCOMMITTED→SERIALIZABLE | NOLOCK dirt | 1205 retry
23. 1NF atomic | 2NF no half-key lean | 3NF no non-key lean | de-split for reads
24. % any run | _ one letter | [ab] one of | head-% scans, head-pinned seeks
25. sp_executesql + params safe | QUOTENAME names | never paste input
26. Plan first | bare columns seek | no star | match types | prove before/after
27. Ints by size | DECIMAL money | DATETIME2 sharp | IDENTITY per-table | SEQUENCE shared
```

## Roadmap — Level 2 (all added ✅)

Former roadmap, now built. Priority marked ★:

1. `GROUP BY` + aggregates ★ → `11-group-by-aggregates/` ✅
2. `ORDER BY`, `DISTINCT`, `CASE` → `13-order-by-top-distinct/` + `14-case-expression/` ✅
3. `NULL`, `IS NULL`, `COALESCE`, `ISNULL` → `12-null-handling/` ✅
4. Subqueries vs `EXISTS` vs `IN` ★ → `15-exists-vs-in/` ✅
5. CTE vs temp table vs table variable ★ → `17-temp-tables-vs-variables/` ✅
6. Window functions — `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`, `LAG` ★ → `16-window-functions/` ✅
7. Stored procedures ★ → `19-stored-procedures/` ✅
8. Functions — scalar, inline TVF, multi-statement TVF → `20-functions/` ✅
9. Views → `18-views/` ✅
10. Triggers → `21-triggers/` ✅
11. Transactions + ACID ★ → `22-transactions-acid/` ✅
12. Isolation levels + locking ★ → `22-transactions-acid/` ✅
13. Deadlocks ★ → `22-transactions-acid/` ✅
14. Indexes + execution plans ★ → `10-indexes/` + `26-query-optimization/` ✅
15. Query optimization ★ → `26-query-optimization/` ✅
16. Pagination + Nth / highest salary → `13-order-by-top-distinct/` + `16-window-functions/` ✅

Extras added beyond the roadmap: `23-normalization/`, `24-like-pattern-matching/`,
`25-dynamic-sql-injection/`, `08` set-ops detail (`INTERSECT`/`EXCEPT`).

## Contributing

- One topic per folder: `NN-kebab-case-name/`
- Every folder must have `README.md` + `examples.sql`
- README sections (in order): Goal → Sample Tables → Examples → Query Breakdown → Edge Cases → Scenario Questions → Cheat Recap
