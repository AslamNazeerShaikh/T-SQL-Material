# Audit Options — Triggers vs Temporal Tables vs CDC

Companion to `README.md` (trigger shapes). Temporal tables auto-keep full row
past; CDC (Change Data Capture) ships change feeds via Agent jobs. Pick by need.

## Definition (say this in the interview)

**What it is:** Three past-keepers. Triggers hand-write audit rows on blasts.
Temporal auto-keeps each row version with valid-from/to stamps, asked via
FOR SYSTEM_TIME. CDC reads the log via Agent into change tables for feeds.

**Interview-ready answer:** *"Triggers hand-log what I code — slim and mine.
Temporal auto-keeps all row versions with from-to stamps, asked with FOR
SYSTEM-TIME as-of or between — zero hand code, some store cost. CDC ships log
feeds for downstream pipes but needs Agent running. I pick triggers for custom
rules, temporal for who-was-what-when, CDC for feeds."*

## 1. Temporal shape (2016+)

```sql
CREATE TABLE dbo.Emp (
  Id INT PRIMARY KEY, Salary INT,
  ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo   DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
  PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo))
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmpHist,
      DATA_CONSISTENCY_CHECK = ON));
-- Ask the past:
SELECT * FROM dbo.Emp FOR SYSTEM_TIME AS OF '2026-01-01';          -- snapshot
SELECT * FROM dbo.Emp FOR SYSTEM_TIME BETWEEN '2026-01-01' AND '2026-02-01';
SELECT * FROM dbo.Emp FOR SYSTEM_TIME ALL;                          -- past + now
-- Retention: WITH (SYSTEM_VERSIONING = ON (..., HISTORY_RETENTION_PERIOD = 6 MONTHS));
-- Existing table: ALTER ADD the two GENERATED columns + PERIOD, then SET SYSTEM_VERSIONING ON.
```

## 2. Comparison (the asked table)

| Point (metric) | AFTER triggers | Temporal | CDC |
|---|---|---|---|
| Keeps (what) | what you code (notes, old+new) | full row versions + stamps | net row shifts + op kind |
| Asks (how) | your Audit table SELECTs | FOR SYSTEM_TIME AS OF/BETWEEN/ALL | cdc.fn_* feed funcs |
| Hand code (level) | full (shape + writes) | none past create | enable + consume |
| Needs Agent (yes/no) | No | No (retention cleanup likes it) | Yes |
| Custom veto/reshape (yes/no) | Yes (INSTEAD OF) | No (keeps only) | No |
| Cost (hit) | per-blast code | store past + version writes | log read + cleanup jobs |
| Barred (limits) | hide-cost, loop risk | no TRUNCATE while on; no INSTEAD OF; schema shifts need OFF | needs enable per db/table; latency |

## 3. Edge cases

- Temporal schema shifts (ADD field) need SYSTEM_VERSIONING OFF first, then ON.
- TRUNCATE barred while versioned — OFF, truncate, ON (past wipes too).
- INSTEAD OF triggers barred on versioned tables — AFTER only.
- History grows wild sans retention — set HISTORY_RETENTION_PERIOD + cleanup.
- CDC feeds lag Agent rhythm — not live; triggers are.
- DATA_CONSISTENCY_CHECK blocks ON if past breaks vows — clean first.

## 4. Interview scenario questions

1. "Pay past per month, zero hand code?" → Temporal + BETWEEN month bounds.
2. "Feed downstream adds/edits?" → CDC (Agent on), triggers stay for vetoes.
3. "Custom 'who cut pay' note?" → AFTER trigger hand-log (temporal keeps what, not why).
4. "History table huge — trim?" → Retention period + cleanup; TRUNCATE needs OFF.
5. "Schema add on live versioned table?" → OFF → ALTER both → ON.

## Cheat recap

```text
Triggers hand-log + veto | Temporal auto-versions + FOR SYSTEM_TIME asks
CDC log-feeds via Agent | retention trims past | OFF for schema/TRUNCATE shifts
```
