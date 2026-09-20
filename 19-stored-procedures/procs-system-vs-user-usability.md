# Procs Deep-Dive — System vs User, Params, Where-Usable Matrix

Companion to `README.md` (proc shapes + safe-call flow). Answers: whose procs
live where, param vs non, and exactly which contexts accept `EXEC`.

## Definition (say this in the interview)

**What it is:** Two families. System procs (`sp_*`) ship with the engine, live
in master, and answer admin asks (help, who, space). User procs (`usp_*`,
`dbo.*`) are your saved work in your DB. Both run EXEC-only — called, never
pasted into queries.

**Interview-ready answer:** *"System procs ship with the engine — sp-help,
sp-who, sp-tables — and I never name mine sp, as that name probes master
first. Mine live as dbo dot usp with params, outputs, and status back. Procs
run EXEC-only from apps, jobs, triggers, and procs — never inside SELECT,
views, functions, checks, or defaults."*

## 1. System vs user vs extended

| Family (prefix) | Lives in (db) | Examples | Use for (job) | Name yours so? (rule) |
|---|---|---|---|---|
| System (`sp_*`) | master (+ marked) | sp_help, sp_helptext, sp_who2, sp_tables, sp_columns, sp_databases, sp_executesql | explore, admin, safe-dynamic | NEVER `sp_` — probes master first, slower + future clash |
| Extended (`xp_*`) | engine surface | xp_cmdshell (shell calls) | OS reach-outs | Off by default — needs deliberate enable + tight rights |
| User (`usp_*`) | your DB | usp_Hire, usp_GetStaff | app work | `dbo.usp_*` + verb first |

```sql
sp_help 'dbo.Emp';        -- shape of a table (columns, keys, indexes)
sp_helptext 'dbo.usp_Hire'; -- shows saved proc text
sp_who2;                  -- who sits where, who blocks whom
sp_tables @table_type = "'TABLE'";  -- list tables
```

## 2. Parameterized vs non (param shapes)

| Shape (kind) | Looks like (form) | Best for (use) | Watch (trap) |
|---|---|---|---|
| Non (fixed job) | `CREATE PROC usp_Nightly ...` no inputs | nightly sweep, fixed report | one job one truth — params beat clones |
| Inputs (+ defaults) | `@DeptId INT = NULL` | filters, modes | passed NULL still lands NULL — guard it |
| OUTPUT back-value | `@NewId INT OUTPUT` (+ `OUTPUT` at call!) | new id, status text | forget `OUTPUT` at call → value never lands |
| RETURN status | `RETURN 0` / `RETURN @rc` | win-or-fail code | ints only — rows for lists, never IDs via RETURN |
| Table-valued (TVP) | `@Ids IdList READONLY` | bulk key lists from .NET DataTable | READONLY always — stage to #temp to shape it |

```sql
-- TVP shape: bulk ids in one call (type made once)
-- CREATE TYPE IdList AS TABLE (Id INT PRIMARY KEY);
CREATE PROC usp_GetMany @Ids IdList READONLY AS
BEGIN SET NOCOUNT ON; SELECT e.* FROM dbo.Emp e JOIN @Ids i ON i.Id = e.Id; END;
```

## 3. Where-usable matrix (the asked table)

| Context (place) | Proc call (yes/no) | How / why not |
|---|---|---|
| App / API / job step | Yes | `EXEC usp_X ...` — home turf |
| Another proc | Yes | nesting to 32 deep |
| Trigger body | Yes | allowed — mind loops + deal context |
| Ad-hoc batch (SSMS) | Yes | `EXEC` any time |
| SELECT list / WHERE / JOIN / ORDER BY | No | queries take values/funcs, never EXEC |
| View body | No | views are still SELECTs — call proc first, feed view after |
| Function body (any shape) | No | funcs can't EXEC procs (no side-work rule) |
| CTE / subquery / derived | No | still query-land — EXEC stands alone |
| CHECK / DEFAULT / computed | No | need scalar funcs (`20` detail) |
| Dynamic string | Yes, via text | `EXEC(@s)` / sp_executesql — but params beat paste (`25`) |

## 4. Temp tables + procs (nested scope rules)

- Caller-made `#temp` is seen inside the proc (shared sitting).
- Proc-made `#temp` dies at proc end — but nested procs called mid-way still see it.
- `@var` never crosses proc walls — pass TVPs or stage `#temp` instead.

## 5. Edge cases

- `sp_` tax is real: name probes master first — slower + breaks on future system names.
- 32-deep nesting cap — looped proc chains die loud; flatten or queue it.
- `RETURN` without value = 0 — callers reading status must know your code map.
- Trigger-EXEC runs in the write's deal — slow proc, slow write; keep slim.
- `SET NOCOUNT ON` missing breaks ORMs that count result sets.
- First-call sniff can mistune later values — test odd inputs pre-ship.

## 6. Interview scenario questions

1. "Mine named sp_GetX — harm?" → Master probe + clash risk. Rename `usp_GetX`.
2. "Pass 10K ids from .NET — loop calls?" → One TVP call, join inside.
3. "Call proc inside SELECT?" → No — shape as func/TVF or EXEC first into #temp.
4. "Proc-made temp seen by nested proc?" → Yes mid-flight; dies at outer end.
5. "New id back to app — RETURN or OUTPUT?" → OUTPUT (RETURN = status ints only).

## Cheat recap

```text
sp_* system (never name yours so) | xp_* gated OS reach | usp_* yours
Params: defaults, OUTPUT (+keyword at call), RETURN ints, TVP READONLY bulk
EXEC-only: apps/jobs/procs/triggers yes | SELECT/view/func/CTE/check no
Proc-made #temp dies at end, seen nested | 32-deep cap
```
