# 22 — Transactions + ACID (Deals, Locks, Deadlocks)

**Goal:** Seal multi-step work (ACID), pick read safety (isolation + NOLOCK), and dodge deadlocks.

## Definition (say this in the interview)

**What it is:** A deal (transaction) packs steps to win-or-lose whole. ACID
names the vows: All-or-none, Clean rules kept, Solo feel mid crowd, Sealed work
lasts. Isolation rungs set how much half-work readers may see — from read-any
(dirty reads) to full solo (serial). A deadlock is two deals each clutching
what the next needs — the engine kills one (error 1205), app retries.

**Why it was introduced:** Money moves span steps; crashes and crowds strike
mid-deal. Without vows + locks, half-moves and crossed reads rot books. Deals
plus rungs let speed trade with safety per need.

**What problem it resolves:** Half-done writes, dirty reads, and stuck pairs.
Short sealed deals + right rung + same-order locks = book-safe speed.

**Interview-ready answer:** *"A deal packs steps to win or lose whole. ACID
vows: all or none, clean rules, solo feel, sealed lasts. Read rungs run from
read-any, which can show dirty half-work, up to full solo, slowest but safest.
Stuck default reads only sealed work. NOLOCK skips waits but can show dirt —
never for money counts. Deadlocks are clutch circles — engine kills one with
1205, I retry, and I stop them with short deals, right indexes, and same-order
locks."*

## 1. Sample tables

```sql
CREATE TABLE #Acct (Id INT PRIMARY KEY, Bal INT);
INSERT INTO #Acct VALUES (1, 1000), (2, 500);
```

## 2. Examples

Input `#Acct`:

| Id | Bal |
|---:|---:|
| 1 | 1000 |
| 2 | 500 |

Example 1 — money move:

```sql
SET XACT_ABORT ON;
BEGIN TRANSACTION;
UPDATE #Acct SET Bal = Bal - 200 WHERE Id = 1;
UPDATE #Acct SET Bal = Bal + 200 WHERE Id = 2;
COMMIT;
SELECT * FROM #Acct;
```

Input: 2 rows above.

Output (2 rows):

| Id | Bal |
|---:|---:|
| 1 | 800 |
| 2 | 700 |

Example 2 — read rungs:

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM #Acct WITH (NOLOCK);
```

Input: 2 rows above (no open writer).

Output (2 rows):

| Id | Bal |
|---:|---:|
| 1 | 800 |
| 2 | 700 |

```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
```

Input: needs `ALLOW_SNAPSHOT_ISOLATION ON`.

Output: no result set.

| Result |
|---|
| Commands completed successfully |

Example 3 — deadlock shape (don't run both for real):

```sql
-- Sitting A: UPDATE #Acct WHERE Id=1 ... wait ... UPDATE #Acct WHERE Id=2
-- Sitting B: UPDATE #Acct WHERE Id=2 ... wait ... UPDATE #Acct WHERE Id=1
```

Input: same 2 rows.

Output: one sitting wins, other output:

| Result |
|---|
| Msg 1205 deadlock victim, retry full deal |

## 3. Query breakdown (money move)

BEGIN opens deal → leg one drops 200 (locks row 1) → leg two adds 200 (locks
row 2) → COMMIT seals both to log (lasts crash). Any blast pre-seal with
XACT_ABORT ON voids both — books never half-move.

## 4. Edge cases

- Hang deals hold locks + pin log — most "mystery blocks" are a lost COMMIT.
- NOLOCK can show unsealed rows, moved rows twice, or skip rows — reports only.
- SNAPSHOT needs the DB flag on first — else error, not magic.
- 1205 victim is picked by cost — catch it, retry the full deal, never half-retry.
- Rungs climb: UNCOMMITTED < COMMITTED < REPEATABLE < SERIALIZABLE in safety,
  reverse in speed. Default COMMITTED fits most.
- New-row ghosts (phantoms) slip REPEATABLE — need SERIALIZABLE or SNAPSHOT.

## 5. Interview scenario questions

1. "Move 200, never half?" → One deal, XACT_ABORT ON, COMMIT at end.
2. "Report waits on writers — skip wait?" → NOLOCK for rough counts; sealed reads for money.
3. "Same read twice mid-deal shifts — rung?" → REPEATABLE READ (phantoms still slip).
4. "1205 in logs each noon — cure?" → Same-order locks, short deals, index the link fields, retry victims.
5. "ACID one line each?" → All-or-none / rules kept / solo feel / sealed lasts.
6. "Who blocks whom right now?" → `sys.dm_exec_requests WHERE blocking_session_id <> 0`
   (blocker vs blocked + wait type/resource); `DBCC OPENTRAN` sniffs the oldest open deal.
7. "Reads must never wait writers — pick?" → SNAPSHOT/RCSI (versioned, optimistic);
   write-heavy fights stay pessimistic locking.

## 6. Ladder explicit + RCSI + lock-vs-latch (asked follow-ups)

- Ladder low→high: READ UNCOMMITTED (lowest, dirt) → READ COMMITTED (default,
  sealed) → REPEATABLE READ → SERIALIZABLE (highest, solo). SNAPSHOT/RCSI sit
  apart (versioned reads, no dirt, fewer blocks).
- READ COMMITTED SNAPSHOT (RCSI): statement-level past views via row versions,
  DB flag on — readers never wait writers; writers still block writers.
- Lock = logical claim (row/table, held to seal). Latch = memory-page hug
  (blink-short, never waited on like locks). Blocking = one waits (auto-clears);
  deadlock = circle (1205 kills one) — §5 cures both.

## 7. Concurrency picks + blast severities + HA twins (asked follow-ups)

- Pessimistic vs optimistic (who pays for the fight):

| Point (metric) | Pessimistic (locks) | Optimistic (versions) |
|---|---|---|
| Shape | Lock first, ask never | Read free, check at seal |
| Rungs | UNCOMMITTED → SERIALIZABLE | SNAPSHOT / RCSI |
| Blocks (level) | Readers wait writers | Readers never wait writers |
| Best fight (case) | Hot write clashes | Read-heavy, rare clashes |

- Blast severity inside a deal (what the engine does):

| Severity (level) | Engine does (action) | Code shape (pattern) |
|---|---|---|
| 11–16 (user blasts) | CATCH catches, deal state via `XACT_STATE()` | TRY/CATCH + `IF XACT_STATE() <> 0 ROLLBACK;` |
| 17–19 (soft engine) | Deal may be dead (-1: roll-only) | Check `XACT_STATE()` pre-COMMIT, never seal blind |
| ≥ 20 (hard engine) | Link dies at once | Reconnect + retry full deal |

- Copy-vs-copy (HA/DR twins interviewers pair):

| Point (metric) | Mirroring (hot standby) | Replication (copies) | Log shipping (log replays) |
|---|---|---|---|
| Speed (freshness) | Live | Near-live per article | Lagged (job ticks) |
| Failover (auto?) | Auto (witness) | Manual | Manual |
| Best case (use) | One DB must survive | Spread reads/reports | Cheap DR across sites |

## Cheat recap

```text
Deal = win-or-lose whole | ACID all-none, clean, solo, sealed
Rungs: UNCOMMITTED < COMMITTED < SNAPSHOT < REPEATABLE < SERIALIZABLE
NOLOCK fast dirt, never money | 1205 retry full deal | short + same-order stops locks
Pessimistic locks hot writes | optimistic versions read-heavy | sev≥20 kills link
Mirror auto-hot | replication spreads | log-ship cheap DR
Mechanics: 01-statements-in-detail.md §5
```
