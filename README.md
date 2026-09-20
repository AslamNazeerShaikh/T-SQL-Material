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

> Naming convention: `NN-topic-name/` where `NN` is a zero-padded difficulty order. New topics continue as `11-...`, `12-...`, etc.

## How to study

1. Go in order `00 → 10` the first time.
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

## Cheat sheet (the 11 topics)

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
```

## Roadmap — Level 2 (to be added)

Grouped for a 6+ year .NET backend / full-stack interview. Priority marked ★:

1. `GROUP BY` + aggregates ★
2. `ORDER BY`, `DISTINCT`, `CASE`
3. `NULL`, `IS NULL`, `COALESCE`, `ISNULL`
4. Subqueries vs `EXISTS` vs `IN` ★
5. CTE vs temp table vs table variable ★
6. Window functions — `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`, `LAG` ★
7. Stored procedures ★
8. Functions — scalar, inline TVF, multi-statement TVF
9. Views
10. Triggers
11. Transactions + ACID ★
12. Isolation levels + locking ★
13. Deadlocks ★
14. Indexes + execution plans ★
15. Query optimization ★
16. Pagination + Nth / highest salary

## Contributing

- One topic per folder: `NN-kebab-case-name/`
- Every folder must have `README.md` + `examples.sql`
- README sections (in order): Goal → Sample Tables → Examples → Query Breakdown → Edge Cases → Scenario Questions → Cheat Recap
