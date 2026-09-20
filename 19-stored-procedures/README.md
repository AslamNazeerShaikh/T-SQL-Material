# 19 — Stored Procedures (Saved Work + Params)

**Goal:** Pack multi-step work in named procs with in/out params, safe calls, and clean errors.

## Definition (say this in the interview)

**What it is:** A stored proc is a saved batch of SQL with a name, inputs
(with sane defaults), outputs, and a status code back. Apps call by name with
values — never paste SQL strings — so plans get reused and tables stay shut
behind rights.

**Why it was introduced:** Apps pasted raw SQL per click — chatty, unshared
plans, wide-open tables, and join logic rotting in five code copies. Procs pull
data work to the data: one saved truth, one plan, rights on the proc alone.

**What problem it resolves:** Rot, slowness, and holes. One proc = one hire
flow for all apps; compiled plans skip re-plan cost; callers need no table
rights; params (not pasted text) shut the injection door (see `25`).

**Interview-ready answer:** *"A stored proc is saved SQL with a name, inputs
with defaults, outputs, and a status back. Apps call by name with values, so
plans get reused, tables stay shut, and pasted-text injection dies. I keep
SET NOCOUNT ON, wrap money steps in TRY-CATCH with deals, and return rows for
reads, OUTPUT for one back-value, status code for win-or-fail."*

> Deep dive: `procs-system-vs-user-usability.md` — system vs user vs extended procs, param shapes incl. TVP, where-EXEC-allowed matrix, temp scope rules.
> Error armor: `error-handling-try-catch.md` + `error-handling-examples.sql` — TRY/CATCH, ERROR_* readers, THROW, XACT_STATE, WHILE loops.

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT, DeptId INT);
INSERT INTO #Emp VALUES (1,'Asha',90000,10),(2,'Dev',80000,10);
```

## 2. Examples (shape — run in your test DB, #temp shown for shape only)

```sql
-- Read proc: filter with default (call with or without team)
CREATE PROC usp_GetStaff @DeptId INT = NULL AS
BEGIN
  SET NOCOUNT ON;
  SELECT Id, Name, Salary FROM #Emp
  WHERE @DeptId IS NULL OR DeptId = @DeptId;
END;
-- EXEC usp_GetStaff;  EXEC usp_GetStaff @DeptId = 10;

-- Write proc: OUTPUT back-value + TRY-CATCH deal (money-safe shape)
CREATE PROC usp_Hire
  @Name VARCHAR(50), @Salary INT, @NewId INT OUTPUT AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRANSACTION;
      SELECT @NewId = ISNULL(MAX(Id),0) + 1 FROM #Emp;
      INSERT INTO #Emp (Id, Name, Salary) VALUES (@NewId, @Name, @Salary);
    COMMIT;
    RETURN 0;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;  -- keeps true error, line included
  END CATCH;
END;
```

## 3. Query breakdown (safe call flow)

App calls `usp_Hire` with values → engine reuses saved plan → TRY opens deal →
INSERT lands → COMMIT seals → OUTPUT id back, status 0. Any blast → CATCH rolls
back, THROW keeps the true error. No pasted text ever reaches the engine.

## 4. Edge cases

- `RETURN` ships ints only — rows for lists, OUTPUT for values, RETURN for status.
- Missing `SET NOCOUNT ON` spams "n rows" notes that break picky callers (EF, ORM maps).
- Defaults make params skippable — but `NULL` passed on purpose still lands NULL; guard it.
- Re-plan shocks on first-call sniff (wrong plan for next values) — test with odd inputs, fix with locals/OPTIMIZE hints.
- Cursors live here when forced: row-by-row is last resort — shape: DECLARE … CURSOR
  FAST_FORWARD, OPEN, FETCH loop, CLOSE, DEALLOCATE. Prefer set steps always.
- Rights: callers need EXEC on proc, zero table rights — the tightest app wall.

## 5. Interview scenario questions

1. "Same hire flow in web + job + import — one truth?" → `usp_Hire`, all call it.
2. "Slow first run, fast later — why?" → Plan made + reused. That's the win.
3. "Half-hire on blast — stop it?" → TRY-CATCH + deal, THROW keeps true error.
4. "Row-by-row fee fix — cursor?" → Last resort only; set UPDATE first, cursor FAST_FORWARD if truly serial.
5. "Proc vs pasted SQL for safety?" → Params kill injection; EXEC rights beat table rights.

## Cheat recap

```text
PROC name + inputs(defaults) + OUTPUT + RETURN status | call by name, values in
SET NOCOUNT ON | TRY-CATCH + deal on writes | rights: EXEC only, tables shut
Cursors last resort, FAST_FORWARD, set steps first
```
