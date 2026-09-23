# 17 — Temp Tables vs Table Variables (vs CTE)

**Goal:** Pick `#temp`, `##temp`, `@var`, or CTE — and know scope, indexes, and the `SELECT INTO` shortcut.

## Definition (say this in the interview)

**What it is:** Three short-stay homes for mid-work rows. `#temp` lives in
tempdb for your sitting only, holds loads, and takes indexes. `##temp` opens
the door to all sittings. `@var` lives just for the batch, is light and quick
for small piles, but holds no extra indexes and keeps no stats. CTE (`09`) is
not a home at all — a named step for one query.

**Why it was introduced:** Big multi-step work can't all fit one query — stage
it, index it, reuse it twice. Small piles don't earn full table cost. Each home
fits one size of work.

**What problem it resolves:** One-query-only thinking. Staging cuts monster
queries into fast indexed steps; vars skip table cost for tiny sets; picking
wrong (var for 1M rows, CTE read twice) tanks plans.

**Interview-ready answer:** *"Hash-temp lives in tempdb for my sitting, takes
indexes, fits big stage work. Double-hash opens to all sittings. At-var lives
just my batch, no extra indexes, best for small piles. A CTE is no table — one
named step for one query. Rule of thumb: big or twice-read goes hash-temp,
tiny goes at-var, one-shot readable goes CTE."*

## 1. Sample flow

```sql
CREATE TABLE #Stage (Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT);
INSERT INTO #Stage VALUES (1, 'Asha', 90000), (2, 'Dev', 80000);
CREATE INDEX IX_Stage_Sal ON #Stage (Salary);
```

Input `#Stage`:

| Id | Name | Salary |
|---:|---|---:|
| 1 | Asha | 90000 |
| 2 | Dev | 80000 |

```sql
SELECT * FROM #Stage WHERE Salary = 80000;
```

Output (1 row):

| Id | Name | Salary |
|---:|---|---:|
| 2 | Dev | 80000 |

```sql
DECLARE @Tiny TABLE (Id INT PRIMARY KEY, Name VARCHAR(50));
INSERT INTO @Tiny VALUES (1, 'Asha');
SELECT * FROM @Tiny;
```

Input `@Tiny`:

| Id | Name |
|---:|---|
| 1 | Asha |

Output (1 row): same as input.

```sql
SELECT * INTO #Copy FROM #Stage WHERE 1 = 2;
SELECT COUNT(*) AS EmptyClone FROM #Copy;
```

Input: 2-row `#Stage`, filter kills all.

Output (1 row):

| EmptyClone |
|---:|
| 0 |

## 2. Comparison

| Point (metric) | `#temp` (sitting) | `##temp` (shared) | `@var` (batch) | CTE (`09`) |
|---|---|---|---|---|
| Lives in (place) | tempdb | tempdb | memory/tempdb | nowhere (step) |
| Sees it (scope) | my sitting | all sittings | my batch/proc | one query |
| Extra indexes (yes/no) | Yes | Yes | No (inline key only) | No |
| Stats for plans (yes/no) | Yes | Yes | Thin (2019+ reads on first use) | Inlined |
| Dies when (end) | sitting ends / DROP | last sitting done | batch ends | query ends |
| Best pile (size) | big / twice-read | share-step | tiny (<1K-ish) | one-shot clear |

## 3. Query breakdown (pick logic)

Twice-read + 1M rows → `#temp` + index (plan sees stats, seeks fly).
Loop-var + 50 rows → `@var` (no create/index cost). One clear filter → CTE
(reads clean, no object). Cross-sitting handoff → `##temp`, then DROP fast
(shared doors leak if left open).

## 4. Edge cases

- `@var` in big joins = blind plans (thin stats) — 2019 first-use read helps, still test.
- `#temp` names clash in same sitting re-runs — `DROP` first or `IF OBJECT_ID` guard.
- `##temp` seen by all — name fights and leaks; DROP the blink you're done.
- `SELECT INTO` skips keys, checks, triggers, indexes (keeps IDENTITY) — add keys after.
- `@var` can't `SELECT INTO` it, can't ALTER it, dies at `GO` (batch wall).
- Temp in procs: made fresh per call — safe for same-time users.

## 5. Interview scenario questions

1. "1M-row stage read twice — home?" → `#temp` + index on link field.
2. "50-row loop var — home?" → `@var`, light and quick.
3. "Clone shape, zero rows, fast?" → `SELECT INTO ... WHERE 1 = 2`, then add keys.
4. "Share mid-work with one more sitting?" → `##temp`, DROP right after.
5. "Same CTE read twice — cost?" → Runs twice (inlined). Stage to `#temp` instead.
6. "TempDB screams mid-batch — first checks?" → `sys.dm_db_file_space_usage`:
   version-store vs internal vs user split; free stuck #temp (DROP fast),
   pre-size files, one data file per core to 8, fast disk.

## 6. TempDB ops (asked follow-ups)

- All three homes allocate in tempdb — `#temp`, `##temp`, `@var` spills,
  version store, sorts, spills from starved memory grants.
- `sys.dm_db_file_space_usage` splits use: free vs version-store vs internal
  objects (sorts/spills) vs user objects (your #temp) — `examples.sql` demo
  reads it live.
- Rules: pre-size data + log files (autogrow storms stall all), SSD-grade disk,
  one tempdb data file per CPU core up to 8 (kills allocation-page contention),
  DROP `#temp` the blink you're done (open #temp pins space).

## Cheat recap

```text
#temp sitting + indexes, big/twice | ##temp shared, DROP fast
@var batch, tiny, no extra index | CTE one query, no table
SELECT INTO WHERE 1=2 clones shape (keeps IDENTITY, skips keys)
TempDB: file-space-usage split | pre-size | 1 file/core to 8 | DROP fast
```
