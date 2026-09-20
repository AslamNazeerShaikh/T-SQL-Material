# DDL, DML, DQL, DCL, TCL — Full Detail

Companion to `README.md`. This doc explains each statement family end to end: what it is,
why and how it was introduced, what problem it solves, full demo-table examples,
comparison with the others, limitations, and interview + scenario questions.

## Demo tables (used by every example below)

```sql
CREATE TABLE Demo_Dept
(
    DeptId   INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

CREATE TABLE Demo_Emp
(
    EmpId  INT PRIMARY KEY,
    Name   VARCHAR(100) NOT NULL,
    Salary DECIMAL(18,2) NULL,
    DeptId INT NULL FOREIGN KEY REFERENCES Demo_Dept(DeptId)
);

INSERT INTO Demo_Dept VALUES (10, 'IT'), (20, 'HR');
INSERT INTO Demo_Emp VALUES (1, 'John', 80000, 10), (2, 'Sara', 90000, 10), (3, 'Mike', 45000, 20);
```

Seed state:

| EmpId | Name | Salary | DeptId |
|---:|---|---:|---:|
| 1 | John | 80000 | 10 |
| 2 | Sara | 90000 | 10 |
| 3 | Mike | 45000 | 20 |

---

## 1. DDL — Data Definition Language

| Aspect (metric) | Detail |
|---|---|
| Statements | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| Acts on (target) | Objects / structure: tables, indexes, views, procedures — not rows |
| Logging (level) | Minimal for `TRUNCATE`; schema changes logged |
| Triggers fired (yes/no) | DML triggers: no. DDL triggers (audit): can fire |
| Rollback in explicit tran (yes/no) | Yes in SQL Server (unlike Oracle, where DDL auto-commits) |
| `WHERE` clause (yes/no) | No — whole object at once |

**What it is:** DDL builds, reshapes, and removes the containers data lives in.
`CREATE` makes an object, `ALTER` reshapes it, `DROP` deletes the whole object,
`TRUNCATE` empties a table fast but keeps its shape.

**Why and how it was introduced:** Business shapes change — new fields, new tables,
old tables to drop. Early data files had fixed layouts; altering them meant
rewriting programs. The relational model split *shape* from *data*, and DDL became
the controlled way to evolve shape with one command instead of rebuilding storage by hand.

**What problem it solves:** Schema drift chaos. Without DDL every structural change
would be manual, risky, and different per tool. DDL makes shape changes
repeatable (scripts), permission-gated (only owners alter), and auditable.

**Full examples:**

```sql
-- CREATE: new table + index + view
CREATE TABLE Demo_Proj
(
    ProjId INT PRIMARY KEY,
    Title  VARCHAR(100) NOT NULL
);
CREATE NONCLUSTERED INDEX IX_Emp_Name ON Demo_Emp(Name);
CREATE VIEW vw_ITStaff AS SELECT EmpId, Name FROM Demo_Emp WHERE DeptId = 10;

-- ALTER: reshape — add column, add rule, widen type
ALTER TABLE Demo_Emp ADD JoinDate DATE NULL;
ALTER TABLE Demo_Emp ADD CONSTRAINT CK_Emp_Sal CHECK (Salary >= 0);
ALTER TABLE Demo_Emp ALTER COLUMN Name VARCHAR(150) NOT NULL;

-- TRUNCATE: empty fast, keep shape (+ identity reset, skips DELETE triggers)
TRUNCATE TABLE Demo_Proj;

-- DROP: remove object fully (blocked while FKs point at it)
DROP VIEW vw_ITStaff;
DROP TABLE Demo_Proj;
```

**Limitations:**

- `DROP` is total — data, indexes, triggers, grants on that object go with it. No undo outside a transaction.
- `TRUNCATE` needs `ALTER` rights (not just `DELETE`), takes schema locks, and fails if any FK points at the table — even when the table is empty.
- `ALTER` on big tables can lock and take time (widening types, adding NOT NULL rewrites rows).
- DDL in stored app code is a smell — shape changes belong in deploy scripts, not in per-click logic.

---

## 2. DML — Data Manipulation Language

| Aspect (metric) | Detail |
|---|---|
| Statements | `INSERT`, `UPDATE`, `DELETE`, `MERGE` |
| Acts on (target) | Rows inside existing tables |
| Logging (level) | Full row-level logging (bigger log use than `TRUNCATE`) |
| Triggers fired (yes/no) | Yes — INSERT/UPDATE/DELETE triggers fire |
| Rollback in explicit tran (yes/no) | Yes |
| `WHERE` clause (yes/no) | Yes for `UPDATE`/`DELETE` (`MERGE` uses `ON`) — omit it and all rows change |

**What it is:** DML puts rows in, changes rows, and takes rows out — the day-to-day
write work. `MERGE` does insert-or-update-or-delete in one pass (upsert pattern).

**Why and how it was introduced:** Once tables exist, apps must record life events:
new hire, pay rise, exit. The language needed row-level verbs with filters
(`WHERE`) so one statement could touch exactly the right rows — plus set-based
power (one `UPDATE` fixing a thousand rows, not a thousand round trips).

**What problem it solves:** Without DML every write would be full-table rewrites or
client-side loops. DML gives exact, logged, trigger-aware row changes in one
server-side step — including the classic sync case ("insert if new, update if
exists") that `MERGE` handles atomically.

**Full examples:**

```sql
-- INSERT: one row, many rows, from query
INSERT INTO Demo_Emp (EmpId, Name, Salary, DeptId) VALUES (4, 'Ravi', 60000, 20);
INSERT INTO Demo_Emp VALUES (5, 'Asha', 70000, 10), (6, 'Dev', 50000, 20);
INSERT INTO Demo_Proj (ProjId, Title) SELECT 1, 'Intranet';  -- INSERT..SELECT

-- UPDATE: exact rows via WHERE; OUTPUT shows before/after
UPDATE Demo_Emp SET Salary = Salary * 1.10 WHERE DeptId = 10;
UPDATE Demo_Emp SET Salary = 95000
OUTPUT deleted.Salary AS OldSal, inserted.Salary AS NewSal
WHERE EmpId = 2;

-- DELETE: exact rows; fires triggers; keeps shape + identity seed
DELETE FROM Demo_Emp WHERE EmpId = 6;

-- MERGE: sync Demo_Emp from a staging feed in one step
MERGE INTO Demo_Emp AS tgt
USING (SELECT 3 AS EmpId, 'Mike' AS Name, 48000 AS Salary) AS src
   ON tgt.EmpId = src.EmpId
WHEN MATCHED THEN UPDATE SET tgt.Salary = src.Salary
WHEN NOT MATCHED THEN INSERT (EmpId, Name, Salary) VALUES (src.EmpId, src.Name, src.Salary);
```

**Limitations:**

- Missing `WHERE` on `UPDATE`/`DELETE` rewrites or wipes the whole table — the most common production accident.
- Row-by-row logging means huge DML fills the transaction log and runs long; batch it (`TOP`-looped deletes/updates).
- `MERGE` has documented edge-case bugs in the engine over the years — many senior teams prefer separate `INSERT`/`UPDATE` statements for safety and clearer plans.
- Every FK, CHECK, and trigger is checked per write — safe, but bulk loads pay for it (hence staged loads + constraints you trust).

---

## 3. DQL — Data Query Language

| Aspect (metric) | Detail |
|---|---|
| Statements | `SELECT` (with `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, joins, subqueries) |
| Acts on (target) | Reads — returns rows, changes nothing |
| Logging (level) | None for data (no log writes) |
| Triggers fired (yes/no) | No |
| Rollback needed (yes/no) | No — nothing to undo |
| `WHERE` clause (yes/no) | Yes — filters rows before grouping |

**What it is:** DQL asks questions and gets result sets back. One `SELECT` can
filter, join, group, rank, and sort — pure read, zero side effects.

**Why and how it was introduced:** Storing data is pointless if every question
needs a program. The relational model made the *query* — not custom code — the
way to ask anything: English-like, set-based, and optimizable by the engine
(indexes, join order) instead of by each developer.

**What problem it solves:** Without DQL each report is a hand-written program
looping files. DQL lets anyone state *what* they want ("IT staff averages")
while the optimizer decides *how* (seek vs scan), in one round trip.

**Full examples:**

```sql
-- Plain read + filter + sort
SELECT EmpId, Name, Salary FROM Demo_Emp WHERE DeptId = 10 ORDER BY Salary DESC;

-- Join + group + group-filter (uses both WHERE and HAVING)
SELECT d.DeptName, AVG(e.Salary) AS AvgSal
FROM Demo_Emp e JOIN Demo_Dept d ON d.DeptId = e.DeptId
WHERE e.Salary > 40000
GROUP BY d.DeptName
HAVING AVG(e.Salary) > 60000;

-- Top-N per group pattern (interview favorite)
SELECT EmpId, Name, Salary,
       ROW_NUMBER() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rn
FROM Demo_Emp;
```

**Limitations:**

- Read-only by design — no writes, no DDL; reports that "fix" data inline are impossible (good).
- `SELECT *` drags unneeded columns (breaks covering indexes, wastes network) — name columns.
- Speed lives and dies by indexes and plans; a missing index turns a seek into a full scan with zero syntax warning.
- Shared locks can wait behind writers; `NOLOCK`/`READ UNCOMMITTED` skips waiting but can return dirty or moved rows — never for money counts.

---

## 4. DCL — Data Control Language

| Aspect (metric) | Detail |
|---|---|
| Statements | `GRANT`, `DENY`, `REVOKE` |
| Acts on (target) | Rights: who (principal) may do what (right) on which object (securable) |
| Logging (level) | Logged as metadata change |
| Triggers fired (yes/no) | No |
| Rollback in explicit tran (yes/no) | Yes |
| `WHERE` clause (yes/no) | No |

**What it is:** DCL hands out and takes back rights. `GRANT` gives, `DENY`
blocks outright (and beats any GRANT), `REVOKE` removes a past GRANT or DENY
(returning to neutral). Rights attach per object — e.g. `SELECT` on one table only.

**Why and how it was introduced:** Multi-user databases needed sharing without
full trust: report readers must read but never drop; app logins must write rows
but never alter schema. OS file rights were too coarse, so SQL grew its own
fine-grained, per-object right system.

**What problem it solves:** Least-rights safety. Without DCL every login is
all-or-nothing — one leaked password owns the database. DCL lets each role hold
exactly what it needs, so a breach or a bug can only reach so far.

**Full examples:**

```sql
-- Reporting role: read one table, nothing else
CREATE ROLE ReportReader;
GRANT SELECT ON Demo_Emp TO ReportReader;

-- App login: write rows, but never delete staff and never touch structure
GRANT SELECT, INSERT, UPDATE ON Demo_Emp TO AppLogin;
DENY DELETE ON Demo_Emp TO AppLogin;      -- DENY wins over any GRANT
DENY ALTER ON SCHEMA::dbo TO AppLogin;

-- Take rights back (neutral — neither granted nor denied)
REVOKE SELECT ON Demo_Emp TO ReportReader;

-- Check who can do what
SELECT * FROM fn_my_permissions('Demo_Emp', 'OBJECT');
```

**Limitations:**

- `DENY` beats `GRANT` always — one stray DENY (often via role nesting) locks out a user and is painful to trace.
- Rights are per-object and pile up; without roles the matrix becomes unmanageable — always grant to roles, never to users.
- DCL is access control, not hiding: it cannot mask columns or rows — that needs Dynamic Data Masking / Row-Level Security on top.
- Ownership chains can silently bypass checks inside procedures — convenient, but review who owns what.

---

## 5. TCL — Transaction Control Language

| Aspect (metric) | Detail |
|---|---|
| Statements | `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVE TRANSACTION` |
| Acts on (target) | Units of work: groups many statements into one all-or-nothing deal |
| Logging (level) | Defines what the log can undo/redo as a group |
| Triggers fired (yes/no) | No (but statements inside the deal still fire theirs) |
| Rollback (yes/no) | That is its whole job |
| `WHERE` clause (yes/no) | No |

**What it is:** TCL bundles statements so they win or lose together: `BEGIN`
starts the deal, `COMMIT` seals it, `ROLLBACK` cancels all of it, `SAVE`
marks a point you can roll back to without cancelling everything.

**Why and how it was introduced:** Money moves taught the lesson: debit without
credit is theft, credit without debit is magic. Single statements were already
atomic, but business deals span many statements — so the engine needed explicit
deal brackets plus ACID promises (all-or-nothing, safe, solo-feeling, lasting).

**What problem it solves:** Half-done writes. Without TCL a crash mid-transfer
leaves one account down and none up. TCL plus the log guarantees the database
is never seen half-finished — after a crash it replays sealed deals and erases
unsealed ones.

**Full examples:**

```sql
-- Money move: both legs or neither
BEGIN TRANSACTION;
    UPDATE Demo_Emp SET Salary = Salary - 5000 WHERE EmpId = 1;
    UPDATE Demo_Emp SET Salary = Salary + 5000 WHERE EmpId = 3;
COMMIT;  -- or ROLLBACK on any error

-- Savepoint: undo just the risky middle
BEGIN TRANSACTION;
    INSERT INTO Demo_Emp VALUES (7, 'Kiran', 55000, 20);
    SAVE TRANSACTION AfterInsert;
    DELETE FROM Demo_Emp WHERE DeptId = 20;      -- oops, too wide
    ROLLBACK TRANSACTION AfterInsert;            -- undo only the delete
COMMIT;

-- Guard rails used in every proc
SET XACT_ABORT ON;              -- auto-rollback on runtime errors
SELECT @@TRANCOUNT AS OpenDeals; -- >0 means a deal is still open — don't leave it hanging
```

**Limitations:**

- Open deals hold locks and pin log space — a forgotten uncommitted tran blocks users and grows the log until it bursts.
- Nested `BEGIN`s are a myth: only `@@TRANCOUNT` goes up; only the outermost `COMMIT` seals, any `ROLLBACK` cancels all — design flat, short deals.
- `SAVE TRANSACTION` never seals anything — forgetting the final `COMMIT`/`ROLLBACK` still leaves the deal open.
- Long reporting inside a write deal blocks writers — keep deals short, read with the right isolation instead.

---

## Comparison — all five side by side

| Point (metric) | DDL | DML | DQL | DCL | TCL |
|---|---|---|---|---|---|
| Full name | Data Definition | Data Manipulation | Data Query | Data Control | Transaction Control |
| Works on (target) | Shape/objects | Rows | Reads/result sets | Rights | Deals (groups of work) |
| Main verbs | CREATE, ALTER, DROP, TRUNCATE | INSERT, UPDATE, DELETE, MERGE | SELECT | GRANT, DENY, REVOKE | BEGIN, COMMIT, ROLLBACK, SAVE |
| Changes data (yes/no) | No (TRUNCATE empties, shape stays) | Yes | No | No | No — brackets other work |
| Needs `WHERE` (yes/no) | No | Yes (UPDATE/DELETE) | Yes (row filter) | No | No |
| Fires row triggers (yes/no) | No | Yes | No | No | No |
| Rollback in tran (yes/no) | Yes (SQL Server) | Yes | N/A | Yes | Is the rollback tool |
| Lock weight (level) | Heavy (schema locks) | Row/page, grows with size | Light shared (usually) | Metadata | Holds others' locks till sealed |
| Typical holder (role) | DBA / deploy | App / user | Everyone | DBA / security | App / proc |
| Classic mistake (risk) | DROP/TRUNCATE wrong table | UPDATE/DELETE minus WHERE | SELECT * in prod | Stray DENY locks all out | Open tran left hanging |

---

## DELETE vs TRUNCATE vs DROP — the trio, once more

(Full version lives in `README.md` §5; short form here since interviewers always ask it inside this topic.)

| Point (metric) | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| Takes rows (yes/no) | Yes, picked by WHERE | Yes, all | Table itself gone |
| Keeps shape (yes/no) | Yes | Yes | No |
| Kind (class) | DML | DDL | DDL |
| Rollback in tran (yes/no) | Yes | Yes | Yes |
| Fires DELETE trigger (yes/no) | Yes | No | No |
| Resets IDENTITY (yes/no) | No | Yes, mostly | N/A |
| Blocked by FK (yes/no) | Per-row check | Blocked if any FK points here | Blocked if pointed at |

---

## Interview questions (with short answers)

1. **Name the five types with two examples each.**
   DDL: CREATE, DROP. DML: INSERT, DELETE. DQL: SELECT. DCL: GRANT, REVOKE.
   TCL: BEGIN TRAN, COMMIT.
2. **Is SELECT part of DML or its own thing?**
   Many books put SELECT in DML; interviews accept DQL = SELECT. Say which one you use and stay with it.
3. **TRUNCATE — DDL or DML? Rollback-able?**
   DDL, and yes — inside an open deal in SQL Server it rolls back (unlike Oracle).
4. **DELETE without WHERE?**
   Wipes all rows, shape stays, logged, triggers fire. Always test inside `BEGIN TRAN` first.
5. **GRANT vs DENY vs REVOKE?**
   GRANT gives, DENY blocks (beats GRANT), REVOKE takes back to neutral.
6. **What does SAVE TRANSACTION do — seal the deal?**
   No. Only a mid-point mark for part-undo. Final COMMIT/ROLLBACK still a must.
7. **Who should hold DDL rights in prod?**
   Deploys/DBAs only. App logins get row rights (DML) on named tables — never ALTER/DROP.
8. **MERGE vs separate INSERT + UPDATE?**
   MERGE syncs in one pass; separate steps are clearer in plans and dodge MERGE edge bugs. Seniors pick per case.
9. **Why is my report slow though the query is "just SELECT"?**
   DQL speed rests on indexes. No index on the filter = full scan. Check the plan, not the words.
10. **@@TRANCOUNT is 2 — how many COMMITs to seal?**
    Two — only the outer seals. Better: keep deals flat and short.
11. **Can DDL fire triggers?**
    Row triggers, no. DDL audit triggers (CREATE_TABLE events), yes — used to log schema change.
12. **INSERT..SELECT vs VALUES?**
    Same family (DML). SELECT form copies sets fast; VALUES lists literals. Both logged, both checked.

## Scenario questions (say-then-show)

1. **"Empty a 100M-row stage table nightly, keep shape, reset SrNo."**
   Say TRUNCATE (fast, low log, resets seed), then show FK check first:
   `TRUNCATE TABLE Stage_X;` — blocked? Drop/disable the FK or use batched DELETE.
2. **"Clerk ran DELETE with no WHERE in prod. Now what?"**
   If inside an open deal: `ROLLBACK`. If sealed: point-in-time log restore. Lesson: test deletes as
   `BEGIN TRAN; DELETE...; SELECT...; -- ROLLBACK or COMMIT` and always write WHERE first.
3. **"Report login must see pay but never change it."**
   `GRANT SELECT ON Demo_Emp TO ReportLogin;` — no DML, no DDL. Add `DENY` on the pay column writes if rights came via roles.
4. **"Two-step fee move must never half-finish."**
   Wrap in TCL: BEGIN, both UPDATEs, COMMIT; `SET XACT_ABORT ON` so any error auto-rolls back.
5. **"Audit wants each deleted row kept."**
   DELETE (fires trigger that logs to `Emp_Audit`), never TRUNCATE — it skips row triggers by design.
6. **"New field JoinDate for all staff, old rows stay."**
   DDL ALTER, null-first: `ALTER TABLE Demo_Emp ADD JoinDate DATE NULL;` backfill, then tighten — shape change with zero row loss.

## Cheat recap

```text
DDL → shape: CREATE, ALTER, DROP, TRUNCATE | no WHERE | heavy locks | deploy-owned
DML → rows: INSERT, UPDATE, DELETE, MERGE | WHERE is life | logged + triggers | batch big sets
DQL → reads: SELECT | no side effects | speed = indexes + plan | name columns, skip *
DCL → rights: GRANT gives, DENY beats, REVOKE clears | use roles | DENY strays lock out
TCL → deals: BEGIN, COMMIT, ROLLBACK, SAVE | all-or-nothing | short + flat | XACT_ABORT ON
DELETE = DML picked rows | TRUNCATE = DDL fast empty | DROP = object gone
```
