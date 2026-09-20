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
INSERT INTO #Acct VALUES (1,1000),(2,500);
```

## 2. Examples

```sql
-- Money move: both legs or neither (XACT_ABORT auto-rolls on blast)
SET XACT_ABORT ON;
BEGIN TRANSACTION;
  UPDATE #Acct SET Bal = Bal - 200 WHERE Id = 1;
  UPDATE #Acct SET Bal = Bal + 200 WHERE Id = 2;
COMMIT;

-- Read rungs: pick safety per need
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- default: sealed work only
SELECT * FROM #Acct WITH (NOLOCK);               -- = READ UNCOMMITTED: no wait, may show dirt
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;        -- needs ALLOW_SNAPSHOT_ISOLATION ON: past-view reads, no blocks
-- REPEATABLE READ: re-reads match mid-deal | SERIALIZABLE: full solo, max locks

-- Deadlock shape (two sittings, cross order — DON'T run both for real):
-- Sitting A: UPDATE #Acct WHERE Id=1 ... wait ... UPDATE #Acct WHERE Id=2
-- Sitting B: UPDATE #Acct WHERE Id=2 ... wait ... UPDATE #Acct WHERE Id=1
-- Fix shape: same order all town (1 then 2), short deals, retry on 1205.
```

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

## Cheat recap

```text
Deal = win-or-lose whole | ACID all-none, clean, solo, sealed
Rungs: UNCOMMITTED < COMMITTED < SNAPSHOT < REPEATABLE < SERIALIZABLE
NOLOCK fast dirt, never money | 1205 retry full deal | short + same-order stops locks
Mechanics: 01-statements-in-detail.md §5
```
