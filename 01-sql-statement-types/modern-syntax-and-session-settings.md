# Modern Syntax + Session Settings (T-SQL vs SQL, GO, SET Knobs)

Companion to `README.md` (statement families). The T-SQL-only surface interviewers
poke: what makes T-SQL more than SQL, re-runnable deploys, batch walls, and the
SET knobs hiding atop every proc script.

## Definition (say this in the interview)

**What it is:** T-SQL = standard SQL (sets, SELECT) + procedural teeth
(variables, IF/WHILE, TRY/CATCH, procs, funcs, triggers) + engine-locked extras
(TOP, APPLY, PIVOT, OUTPUT). Modern deploys re-run safe via CREATE OR ALTER and
DROP IF EXISTS. GO walls batches (tool word, not engine). SET knobs tune
session law (ANSI_NULLS, QUOTED_IDENTIFIER, ...).

**Interview-ready answer:** *"T-SQL is standard SQL plus procedural teeth —
variables, IF and WHILE, TRY-CATCH, procs, funcs, triggers — plus locked
extras like TOP and APPLY. I ship re-runnable with CREATE OR ALTER and DROP IF
EXISTS. GO walls batches — a tool word, not engine. And I keep ANSI-NULLS and
QUOTED-IDENTIFIER on, as indexes, views, and XML need them."*

## 1. T-SQL vs standard SQL (one table)

| Side (dialect) | Sets + SELECT (yes) | Variables/IF/WHILE (yes/no) | TRY/CATCH (yes/no) | Procs/funcs/triggers (yes/no) | Runs on (home) |
|---|---|---|---|---|---|
| Standard SQL | Yes | No | No | Varies/thin | alltown |
| T-SQL | Yes | Yes | Yes | Yes, deep | SQL Server only (trade: power for lock-in) |

## 2. Re-runnable deploys (2016+)

```sql
CREATE OR ALTER PROC dbo.usp_GetStaff AS BEGIN SET NOCOUNT ON; SELECT 1; END;
DROP TABLE IF EXISTS dbo.Stage;   -- no IF OBJECT_ID dance
DROP PROC IF EXISTS dbo.usp_Old;
```

## 3. GO + sqlcmd (tooling law)

- `GO` is a batch separator (SSMS/sqlcmd/osql), NOT T-SQL — engine never sees it.
  `GO 5` repeats the batch 5 times (seed loops). procs/views/funcs/triggers must
  lead their batch (hence GO walls round them).
- `sqlcmd`/`OSQL` (old): run scripts from shells, save results — deploy + job turf.
  `sqlcmd -S srv -d db -i deploy.sql -o log.txt`.

## 4. DECLARE: SET vs SELECT

| Point (metric) | SET (ANSI pick) | SELECT (T-SQL flex) |
|---|---|---|
| Assigns per run (count) | one var | many vars + aggregates in one pass |
| Multi-row subquery (fate) | blasts (error 512) | silent last-row win (trap!) |
| Zero-row query (fate) | keeps prior value? No — SET subquery empty = NULL | keeps PRIOR value (never NULLs!) |
| @@ROWCOUNT (touch?) | untouched | set to rows seen |

```sql
DECLARE @a INT = 1, @b INT, @c INT;
SET @a = 5;                                  -- one var, ANSI
SELECT @b = 10, @c = MAX(Id) FROM dbo.Emp;   -- many + totals, one pass
-- Trap: zero-row SELECT-assign keeps old @b (no NULL!) — seed first if it counts.
```

## 5. Session knobs (why atop proc scripts)

- `ANSI_NULLS ON`: `= NULL` never true (standard law). OFF is dead road — filtered
  indexes + persisted computed + indexed views NEED on.
- `QUOTED_IDENTIFIER ON`: `"x"` = name, `'x'` = text (brackets always names). OFF
  flips quotes loose — indexed views/XML/filtered indexes NEED on. Scripts stamp
  both ON so objects behave same alltown.
- `IMPLICIT_TRANSACTIONS OFF` (default): deals open by ask only. ON auto-opens per
  statement — silent hang-deal trap; keep OFF.
- `DATEFIRST 7` (US Sunday start; `@@DATEFIRST` reads), `DATEFORMAT mdy`,
  `LANGUAGE` — date-word parsing law; ISO text (`'20260228'`) dodges all.
- `SET ROWCOUNT n` (deprecated): old row cap incl. writes — use TOP/FETCH now.
- `SESSION_CONTEXT` (2016+ key↔value) beats legacy `CONTEXT_INFO` (128-byte blob)
  for sitting-state audit tags.

## Cheat recap

```text
T-SQL = SQL sets + procedural teeth + locked extras (TOP APPLY PIVOT OUTPUT)
CREATE OR ALTER | DROP IF EXISTS | GO walls batches (tool word, GO n repeats)
SET one ANSI (ROWCOUNT safe) | SELECT many + totals (zero-row keeps old!)
ANSI_NULLS + QUOTED_IDENTIFIER ON (indexes/views need) | IMPLICIT OFF
SESSION_CONTEXT beats CONTEXT_INFO | ISO dates dodge DATEFORMAT
```
