# 21 — Triggers (Auto-Run Rules on Write)

**Goal:** Fire audit/business rules with AFTER vs INSTEAD OF triggers, using inserted/deleted sets.

## Definition (say this in the interview)

**What it is:** A trigger is saved SQL tied to a table that auto-runs on
INSERT, UPDATE, or DELETE. AFTER runs past the write (audit it). INSTEAD OF
runs in place of it (veto or reshape it). In it, `inserted` holds new rows and
`deleted` holds old rows — full sets, not one row.

**Why it was introduced:** Some rules must hold no count what app writes —
audit trails, no-drop pay guards, shaped writes to joined views. Constraints
can't log or reshape; apps can be skipped. Triggers sit at the gate itself.

**What problem it resolves:** Silent rule holes. Every write path — app, job,
hand query — trips the same audit and guard. Without them each writer must
mind rules alone, and one missed path corrupts past.

**Interview-ready answer:** *"A trigger is SQL tied to a table that auto-runs
on write. AFTER runs past the write — I use it to log audits. INSTEAD OF runs
in place — I use it to veto or reshape, like guarding pay cuts or writing
through joined views. Inside sit inserted and deleted sets — full sets, as one
blast can touch many rows. Care points: they hide work, so keep them slim,
set-wise, and logged."*

> Deep dive: `audit-options-temporal-tables.md` + `temporal-tables-examples.sql` — triggers vs temporal vs CDC + retention law.

## 1. Sample tables

```sql
CREATE TABLE #Emp (Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT);
CREATE TABLE #Audit (Id INT IDENTITY, Note VARCHAR(200), WhenAt DATETIME2 DEFAULT SYSUTCDATETIME());
INSERT INTO #Emp VALUES (1,'Asha',90000),(2,'Dev',80000);
```

## 2. Examples (shapes — triggers can't sit on #temp; make in test DB)

```sql
-- AFTER: log all pay shifts (set-wise — one blast, many rows, one run)
CREATE TRIGGER trg_Emp_Audit ON dbo.Emp
AFTER INSERT, UPDATE, DELETE AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.Audit (Note)
  SELECT CONCAT('ins:', i.Id) FROM inserted i
  UNION ALL
  SELECT CONCAT('del:', d.Id) FROM deleted d;
END;

-- INSTEAD OF: veto pay cuts (reshape the write, then do it yourself)
CREATE TRIGGER trg_Emp_NoCut ON dbo.Emp
INSTEAD OF UPDATE AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON d.Id = i.Id
             WHERE i.Salary < d.Salary)
  BEGIN RAISERROR('Pay cuts blocked.', 16, 1); ROLLBACK; RETURN; END;
  UPDATE e SET e.Name = i.Name, e.Salary = i.Salary
  FROM dbo.Emp e JOIN inserted i ON i.Id = e.Id;
END;
```

## 3. Query breakdown (audit AFTER)

Blast updates 50 rows → trigger runs ONCE → `inserted` holds 50 new rows,
`deleted` 50 old → one set INSERT logs all. Row-by-row minds (cursors, scalar
picks with no TOP) break or crawl here — sets only.

## 4. Edge cases

- One blast = one run — never shape single-row minds; always join inserted/deleted.
- AFTER can't stop the write cheap — to veto, INSTEAD OF (or CHECK first).
- ROLLBACK in trigger kills full batch + deal — loud veto, use rarely.
- Triggers hide work — bulk loads slow, surprises bloom; keep slim, log name.
- Nest/recursive fires (trigger trips trigger) — capped by server knobs; mind loops.
- INSTEAD OF on views makes joined views writable — stock senior answer.

## 5. Interview scenario questions

1. "Log all staff edits, all writers?" → AFTER trigger to Audit, set-wise.
2. "Block pay cuts at gate?" → INSTEAD OF + ROLLBACK on cut sniff.
3. "Write through joined view?" → INSTEAD OF splits the write per base table.
4. "Bulk load crawled past trigger day — why?" → Row-blind shape or heavy per-row work. Slim + set-wise.
5. "Trigger vs CHECK?" → CHECK for still rules; trigger for logs, cross-row checks, reshapes.

## 6. Nesting + TRIGGER_NESTLEVEL (asked follow-ups)

- Triggers can trip triggers (nest chain) — the server caps depth; loops rot.
  Recursive triggers (self-trip) stay OFF by law — keep it so.
- `TRIGGER_NESTLEVEL()` reads current trip depth (NULL past triggers) — guard chains.
- CDC (log-feed, Agent-fed) beats triggers for downstream pipes; temporal beats both
  for past-asks — full map in the deep dive above.

## Cheat recap

```text
AFTER past write = audit | INSTEAD OF in place = veto/reshape
inserted new set | deleted old set | one blast one run — sets only
Slim + logged | ROLLBACK kills batch | views writable via INSTEAD OF
```
