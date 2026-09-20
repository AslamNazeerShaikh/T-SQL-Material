# Error Handling — TRY/CATCH, ERROR_* Readers, THROW, XACT_STATE

Companion to `README.md` (safe-call flow) and `procs-system-vs-user-usability.md`.
Runnable demos: `error-handling-examples.sql` (F5 clean).

## Definition (say this in the interview)

**What it is:** TRY holds risky steps; CATCH runs on blast. Inside CATCH,
ERROR_NUMBER/MESSAGE/SEVERITY/STATE/LINE/PROCEDURE read the blast. THROW
re-throws custom or caught errors keeping the true line. XACT_STATE says if the
open deal still seals: 1 yes, 0 none, -1 dead (roll back only).

**Interview-ready answer:** *"Risky steps sit in TRY, blasts land in CATCH
where ERROR-number and message say what broke. THROW raises mine or re-raises
caught ones with true lines. RAISERROR is the old mouth. XACT-STATE tells if
the deal seals — one yes, zero none, minus-one dead-roll-back-only. Money code
runs XACT-ABORT on so no half-deal ever seals."*

## 1. Shape + readers

```sql
BEGIN TRY
  BEGIN TRANSACTION;
    UPDATE dbo.Acct SET Bal -= 200 WHERE Id = 1;
    UPDATE dbo.Acct SET Bal += 200 WHERE Id = 2;
  COMMIT;
END TRY
BEGIN CATCH
  SELECT ERROR_NUMBER() AS Num, ERROR_SEVERITY() AS Sev, ERROR_STATE() AS St,
         ERROR_LINE() AS Ln, ERROR_PROCEDURE() AS Proc, ERROR_MESSAGE() AS Msg;
  IF XACT_STATE() <> 0 ROLLBACK;   -- seals only if sealable
  THROW;                            -- true error up, line kept
END CATCH;
```

## 2. RAISERROR vs THROW

| Point (metric) | RAISERROR (old) | THROW (new pick) |
|---|---|---|
| Custom raise (yes/no) | Yes, msg ids + printf shape | Yes, number ≥ 50000 + text + state |
| Re-raise caught (keeps line?) | No (new line) unless logged | Yes, bare `THROW;` keeps true line |
| Severity needed (yes/no) | Yes (16 = user blast) | Fixed 16 — less knobs, fewer slips |
| Ends batch past CATCH? | Continues post-CATCH | Same — both caught alike |

## 3. XACT_STATE + XACT_ABORT + @@ERROR legacy

- `XACT_STATE()`: 1 = deal seals, 0 = no deal, -1 = dead deal (blast poisoned it —
  mindmajix "uncommittable": writes barred, only ROLLBACK). Always check pre-COMMIT.
- `SET XACT_ABORT ON`: any blast voids the deal at once — money default.
- `@@ERROR` (legacy): holds last statement's code — read in the NEXT line or it
  resets; TRY/CATCH wins today (WeCP-asked, say both).

## 4. Loop construct: WHILE (cursor's set-free cousin)

```sql
DECLARE @i INT = 1;
WHILE @i <= 5
BEGIN
  IF @i = 3 BEGIN SET @i += 1; CONTINUE; END  -- skip 3
  PRINT @i;
  IF @i = 4 BREAK;                             -- stop at 4
  SET @i += 1;
END;
-- WHILE beats cursors for counters/retries; set steps beat WHILE for rows.
```

## 5. Edge cases

- Uncaught blast voids the batch tail — seal deals in CATCH, never past it.
- `THROW;` bare only inside CATCH — outside needs full number/text/state.
- Severity ≥ 20 kills the link, not just the batch — test blasts at 16.
- ERROR_* read NULL outside CATCH — readers live in CATCH only.
- Compile blasts (bad names) skip CATCH — TRY guards run-time, not typos.
- WHILE without step-up loops forever — step first, BREAK second, test with PRINT.

## 6. Interview scenario questions

1. "Custom 'pay below floor' blast?" → `THROW 50001, '...', 1;` (or RAISERROR legacy).
2. "Log blast detail, keep true line?" → CATCH reads ERROR_* + bare THROW.
3. "Deal state pre-COMMIT in CATCH?" → XACT_STATE: 1 seal, -1 roll-only, 0 none.
4. "@@ERROR vs TRY/CATCH?" → Legacy next-line code vs structured block — TRY wins.
5. "Retry 3 times, skip 3rd tick?" → WHILE + CONTINUE/BREAK demo above.

## Cheat recap

```text
TRY risky | CATCH reads ERROR_* | THROW keeps line | RAISERROR legacy
XACT_STATE 1 seal / 0 none / -1 roll-only | XACT_ABORT ON money default
@@ERROR next-line legacy | WHILE + BREAK/CONTINUE, step always
```
