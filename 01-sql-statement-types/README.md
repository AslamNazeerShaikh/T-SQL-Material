# 01 — Types of SQL / T-SQL Statements

**Goal:** Classify any T-SQL statement as DDL / DML / DQL / DCL / TCL, and nail DELETE vs TRUNCATE vs DROP.

## Definition (say this in the interview)

**What it is:** SQL statements are grouped into five categories by what they act on — DDL acts on *structure* (tables, indexes), DML on *data rows*, DQL *reads* data, DCL manages *permissions*, TCL manages *transactions*.

**Why it was introduced:** As databases grew from simple file stores into multi-user systems, one flat list of commands became unmanageable. The categories let the engine, tools, and DBAs treat fundamentally different operations differently — e.g. schema changes need stricter locking and permissions than reading rows, and transaction control needs its own commands.

**What problem it resolves:** Without categories you cannot answer "who is allowed to do what" or "what will this statement affect." The split makes it possible to GRANT only `SELECT` (DQL) without allowing `DROP` (DDL), to audit schema changes separately from data changes, and to reason about logging/locking per operation type.

**Interview-ready answer:** *"SQL has five types of commands. DDL builds tables — CREATE, ALTER, DROP, TRUNCATE. DML works on rows — INSERT, UPDATE, DELETE, MERGE. DQL reads data — SELECT. DCL sets rights — GRANT, DENY, REVOKE. TCL ends a deal safe — BEGIN, COMMIT, ROLLBACK. This split is a big help. For one, I can give a user only SELECT rights, with no right to touch the tables."*

> Deep dive: `statements-in-detail.md` — full demo-table examples per family, what/why/how + problems solved, 5-way comparison, limitations, 12 interview Q&A + 6 scenarios.
> Syntax + knobs: `modern-syntax-and-session-settings.md` — T-SQL vs SQL, CREATE OR ALTER, DROP IF EXISTS, GO, SET vs SELECT, ANSI_NULLS/QUOTED_IDENTIFIER.

## 1. Categories

| Category | Full Form | Purpose | Common Statements |
|----------|-----------|---------|-------------------|
| DDL | Data Definition Language | Defines structure/objects | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| DML | Data Manipulation Language | Modifies data | `INSERT`, `UPDATE`, `DELETE`, `MERGE` |
| DQL | Data Query Language | Retrieves data | `SELECT` |
| DCL | Data Control Language | Permissions | `GRANT`, `DENY`, `REVOKE` |
| TCL | Transaction Control Language | Transactions | `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVE TRANSACTION` |

> Note: some textbooks fold `SELECT` into DML. In interviews, saying "DQL = SELECT" is expected and fine — just be consistent.

## 2. Sample table

```sql
CREATE TABLE Employees
(
    Id INT,
    Name VARCHAR(100)
);
```

Seed:

| Id | Name |
|---:|------|
| 1 | John |
| 10 | Sara |

## 3. Examples

```sql
-- DDL
CREATE TABLE Employees (Id INT, Name VARCHAR(100));
ALTER TABLE Employees ADD Salary DECIMAL(18,2);
TRUNCATE TABLE Employees;
DROP TABLE Employees;

-- DML
INSERT INTO Employees (Id, Name) VALUES (1, 'John');
UPDATE Employees SET Name = 'Jon' WHERE Id = 1;
DELETE FROM Employees WHERE Id = 10;
MERGE INTO Employees AS tgt USING (SELECT 1 AS Id) AS src
  ON tgt.Id = src.Id WHEN NOT MATCHED THEN INSERT (Id) VALUES (src.Id);

-- DQL
SELECT * FROM Employees;

-- DCL
GRANT SELECT ON Employees TO AppReader;
DENY DELETE ON Employees TO AppReader;
REVOKE SELECT ON Employees TO AppReader;

-- TCL
BEGIN TRANSACTION;
DELETE FROM Employees WHERE Id = 10;
ROLLBACK; -- or COMMIT;
SAVE TRANSACTION BeforeDelete; -- savepoint inside a transaction
```

## 4. Query breakdown

`DELETE FROM Employees WHERE Id = 10;`

1. `FROM Employees` — target table.
2. `WHERE Id = 10` — row filter (omit it = all rows deleted, structure stays).
3. Logged row-by-row → DELETE triggers fire → can be slow on huge tables.

`TRUNCATE TABLE Employees;`

1. Deallocates data pages — fast, minimal logging.
2. No `WHERE`, no triggers, resets `IDENTITY` (generally).
3. DDL, yet **rollback-able inside an explicit transaction** in SQL Server.

`DROP TABLE Employees;`

1. Removes definition + data + indexes/constraints/triggers.
2. Structure is gone — `SELECT` afterwards errors.

## 5. DELETE vs TRUNCATE vs DROP

| | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| Removes rows | Yes | Yes | Table itself |
| `WHERE` allowed | Yes | No | No |
| DML/DDL | DML | DDL | DDL |
| Rollback in explicit tran | Yes | Yes | Yes |
| Removes structure | No | No | Yes |
| Identity reset | No | Yes, generally | N/A |
| Fires DELETE trigger | Yes | No | No |
| FK-blocked? | Checks per row | Blocked if any FK references table (even empty, unless FK removed) | Blocked if referenced |

## 6. Edge cases

- `TRUNCATE` fails if an FK references the table — even with zero rows. `DELETE` may succeed (checks rows).
- `TRUNCATE` needs `ALTER` permission; `DELETE` needs `DELETE` permission. People get blocked in prod for this reason.
- `DELETE` without `WHERE` inside autocommit = full wipe, still logged. Always `BEGIN TRAN` first when testing.
- `DROP` then `ROLLBACK` restores the table **only if DROP was inside the transaction**.
- `SAVE TRANSACTION` does not commit — it only creates a partial-rollback point.

## 7. Interview scenario questions

1. "Is TRUNCATE rollback-able?" → Yes, inside an explicit transaction in SQL Server. Demo with `BEGIN TRAN; TRUNCATE...; ROLLBACK;`.
2. "Table with 100M rows, need empty fast — DELETE or TRUNCATE?" → TRUNCATE (minimal logging, identity reset), if no FKs and no need for row triggers/audit.
3. "Audit trigger must capture every deleted row — which statement breaks it?" → TRUNCATE (bypasses DELETE trigger). Use DELETE or custom archival.
4. "Can I TRUNCATE a parent table referenced by FK?" → No. Drop/disable FK or DELETE child rows first.
5. "GRANT vs DENY vs REVOKE?" → GRANT allows, DENY explicitly blocks (wins over GRANT), REVOKE removes a prior GRANT/DENY.

## Cheat recap

```text
DDL → CREATE, ALTER, DROP, TRUNCATE
DML → INSERT, UPDATE, DELETE, MERGE
DQL → SELECT
DCL → GRANT, DENY, REVOKE
TCL → BEGIN TRAN, COMMIT, ROLLBACK, SAVE TRAN
TRUNCATE is DDL but rollback-able in a transaction; resets IDENTITY; skips triggers.
```
